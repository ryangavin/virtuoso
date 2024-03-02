//
//  ViewModel.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import ARKit
import RealityKit
import RealityKitContent
import SwiftUI

@Observable
// TODO: This will eventually just house the actual app state
// TODO: Most of this class will become the PianoManager
class AppState {
    // MARK: Piano Configuration

    // Anchors to capture the intial positions in the world space
    private var leftAnchor: Entity
    private var rightAnchor: Entity

    // Collision bar for the notes to hit
    private var collisionBar = Entity()

    private var keys: [Entity] = []

    var numberOfKeys: Int = 73
    private let numberOfWhiteKeys = [
        73: 43
    ]
    private let startingKey = [
        73: "E"
    ]

    private let noteNames = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]

    // MARK: UI

    var showImmersiveSpace = false
    var immersiveSpaceIsShown = false

    var showConfigurationMenu = false
    var configurationMenuIsShown = false

    // Piano Configuration

    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        leftAnchor = AppState.createDebugEntity()
        rightAnchor = AppState.createDebugEntity()

        pianoAnchor.addChild(leftAnchor)
        pianoAnchor.addChild(rightAnchor)

        spaceOrigin.addChild(pianoAnchor)
    }

    func moveAnchor(translation: SIMD3<Float>) {
        pianoAnchor.setPosition(translation, relativeTo: pianoAnchor)
    }

    func rotateAnchor(offset: Float) {
        pianoAnchor.transform.rotation *= simd_quatf(angle: offset, axis: [0, 1, 0])
    }

    func stretchAnchor(stretchFactor: Float) {
        // Move the left and right anchors a bit, and then redraw the keyboard
        leftAnchor.setPosition([-stretchFactor, 0, 0], relativeTo: leftAnchor)
        rightAnchor.setPosition([stretchFactor, 0, 0], relativeTo: rightAnchor)
        redrawEnvironment()
    }

    func captureIndexFingerPosition(chirality: HandAnchor.Chirality) {
        let fingerTip = fingertips[chirality]![.indexFingerTip]!
        let measuredPosition = fingerTip.position(relativeTo: spaceOrigin)

        var leftPosition = chirality == .left ? measuredPosition : leftAnchor.position(relativeTo: spaceOrigin)
        var rightPosition = chirality == .right ? measuredPosition : rightAnchor.position(relativeTo: spaceOrigin)

        // Keep the height the same, using the height of the last selected anchor
        if chirality == .left {
            rightPosition.y = leftPosition.y
        } else {
            leftPosition.y = rightPosition.y
        }

        // Angle between ignoring the y axis
        let angleBetween = atan2(leftPosition.z - rightPosition.z, leftPosition.x - rightPosition.x) - .pi

        // Move the center to the new position
        let center = (leftPosition + rightPosition) / 2
        pianoAnchor.setPosition(center, relativeTo: spaceOrigin)

        // Rotate the center so orientation is perpendicular to the line between the left and right anchors
        pianoAnchor.transform.rotation = simd_quatf(angle: angleBetween, axis: [0, -1, 0])

        // Now that we have factored in the roll of the center anchor,
        // we can set the left and right anchors to be the same height.
        let width = simd_length(leftPosition - rightPosition)

        // The left and right positions should end up the same in world space
        // But now everything is centered to the center anchor
        leftAnchor.position = [-width / 2, 0, 0]
        rightAnchor.position = [width / 2, 0, 0]

        redrawEnvironment()
    }

    func redrawEnvironment() {
        for key in keys {
            key.removeFromParent()
        }
        keys.removeAll()
        collisionBar.removeFromParent()

        let noteIndex = noteNames.firstIndex(of: startingKey[numberOfKeys]!)!

        // Spread all the white keys evenly between the two anchors
        // We are measuring the number of gaps between keys, not the number of keys
        // This is why it's -1 in the calculation
        // This is a vector from the left anchor to the right anchor
        //
        // Without the -1, we can get the actual key width
        //
        // Both of these values are controlled by adjusting the anchors in the configuration menu
        // TODO: whiteKeySpacing can be refactored to only use the x axis because the piano is flat
        // TODO: the current implementation may be introducing slight placement rounding errors
        let whiteKeySpacing = (rightAnchor.position - leftAnchor.position) / Float(numberOfWhiteKeys[numberOfKeys]! - 1)
        let keyWidth = simd_length(rightAnchor.position - leftAnchor.position) / Float(numberOfWhiteKeys[numberOfKeys]!)
        let pianoWidth = keyWidth * Float(numberOfWhiteKeys[numberOfKeys]!)

        // The key width can be used to figure out the key height, which is about 6 times the width
        // Not sure if this holds up on micro keyboards
        // TODO: make this adjustable in the configuration menu
        let keyHeight = keyWidth * 6

        // Keep track of the last white key so we can offset black keys from it
        var lastWhiteKeyPosition = leftAnchor.position
        var whiteKeyCount = 0

        for i in 0 ..< numberOfKeys {
            let noteName = noteNames[(i + noteIndex) % noteNames.count]

            // White keys
            if !noteName.contains("#"), !noteName.contains("b") {
                let position = leftAnchor.position + whiteKeySpacing * Float(whiteKeyCount)
                let key = AppState.createDebugEntity()
                lastWhiteKeyPosition = position

                keys.append(key)
                key.position = position
                pianoAnchor.addChild(key)

                whiteKeyCount += 1
            }

            // Black Keys
            else {
                // For now just put the black key half way between the two white keys
                // In real life the spread is a little wider than that.
                // In the cluster of 3, the middle note is directly in the center of the two white keys
                // In the cluster of 2, each is slightly offset from the center of their respective white keys
                let blackKey = AppState.createDebugEntity()
                var blackKeyPosition = lastWhiteKeyPosition + whiteKeySpacing / 2

                // Set the black key back and up
                // TODO: this should be expressed as a ratio that uses the width of the white key and the number of keys
                // TODO: this way on a shorter scale keyboard, it will still be correct
                // TODO: the black key is always 2/3 of the size of the white key
                // TODO: we also need to derive the height of the white key
                blackKeyPosition.z -= 0.07
                blackKeyPosition.y += 0.01

                blackKey.position = blackKeyPosition
                keys.append(blackKey)
                pianoAnchor.addChild(blackKey)
            }
        }

        // Draw the bar that sits just behind the keys
        // TODO: the bar depth should be adjustable
        // TODO: all the keys should really be relative to the bar depth
        createCollisionBarEntity(width: pianoWidth, offset: keyHeight)
    }

    func createCollisionBarEntity(width: Float, offset: Float) {
        let box = MeshResource.generateBox(width: width, height: 0.005, depth: 0.005, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .systemBlue, isMetallic: false)
        let entity = ModelEntity(mesh: box, materials: [material])
        entity.components[GroundingShadowComponent.self] = GroundingShadowComponent(castsShadow: true)
        entity.position = [0, 0, -offset]

        collisionBar = entity
        pianoAnchor.addChild(entity)
    }

    func createNoteEntity(color: UIColor) {
        let box = MeshResource.generateBox(width: 0.01, height: 0.01, depth: 0.01, cornerRadius: 0.001)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: box, materials: [material])
        entity.components[GroundingShadowComponent.self] = GroundingShadowComponent(castsShadow: true)
    }

    private static func createDebugEntity() -> Entity {
        if debugAnchorEntity == nil {
            // Load the entity named "Debug Entity"
            guard let loadedEntity = try? Entity.load(named: "Debug Anchor", in: realityKitContentBundle) else {
                fatalError("Failed to load the Debug Anchor")
            }
            debugAnchorEntity = loadedEntity
        }

        return debugAnchorEntity!.clone(recursive: true)
    }
}
