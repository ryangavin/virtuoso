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

    // Piano Configuration

    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        centerAnchor = Entity()

        leftAnchor = AppState.createDebugEntity()
        rightAnchor = AppState.createDebugEntity()

        centerAnchor.addChild(leftAnchor)
        centerAnchor.addChild(rightAnchor)

        spaceOrigin.addChild(centerAnchor)
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

    func moveAnchor(translation: SIMD3<Float>) {
        centerAnchor.setPosition(translation, relativeTo: centerAnchor)
    }

    func rotateAnchor(offset: Float) {
        centerAnchor.transform.rotation *= simd_quatf(angle: offset, axis: [0, 1, 0])
    }

    func stretchAnchor(stretchFactor: Float) {
        // Move the left and right anchors a bit, and then redraw the keyboard
        leftAnchor.setPosition([-stretchFactor, 0, 0], relativeTo: leftAnchor)
        rightAnchor.setPosition([stretchFactor, 0, 0], relativeTo: rightAnchor)
        resetKeyAnchors()
    }

    func captureIndexFingerPosition(chirality: HandAnchor.Chirality) {
        let fingerTip = fingertips[chirality]![.indexFingerTip]!
        let position = fingerTip.position(relativeTo: spaceOrigin)

        var leftPosition = leftAnchor.position(relativeTo: spaceOrigin)
        var rightPosition = rightAnchor.position(relativeTo: spaceOrigin)

        if chirality == .left {
            leftPosition = position
        } else {
            rightPosition = position
        }

        // Angle between ignoring the y axis
        let angleBetween = atan2(leftPosition.z - rightPosition.z, leftPosition.x - rightPosition.x) - .pi

        // Rotate the debug anchor along the y axis to match the angle between the left and right anchors
        // The debug anchor should be facing forward in the direction of the piano
        centerAnchor.transform.rotation = simd_quatf(angle: angleBetween, axis: [0, -1, 0])

        // Move everything to the new position
        // Moving the center anchor will reposition the left and right anchors
        // so they will need to be repositioned after the center anchor is moved
        let center = (leftPosition + rightPosition) / 2
        centerAnchor.setPosition(center, relativeTo: spaceOrigin)
        leftAnchor.setPosition(leftPosition, relativeTo: spaceOrigin)
        rightAnchor.setPosition(rightPosition, relativeTo: spaceOrigin)

        resetKeyAnchors()
    }

    func resetKeyAnchors() {
        for key in keys {
            key.removeFromParent()
        }
        keys.removeAll()

        var noteIndex = noteNames.firstIndex(of: startingKey[numberOfKeys]!)!

        // Spread all the white keys evenly between the two anchors
        var whiteKeyWidth = (rightAnchor.position - leftAnchor.position) / Float(numberOfWhiteKeys[numberOfKeys]! - 1)

        // Keep track of the last white key so we can offset black keys from it
        var lastWhiteKeyPosition = leftAnchor.position
        var whiteKeyCount = 0

        for i in 0 ..< numberOfKeys {
            let noteName = noteNames[(i + noteIndex) % noteNames.count]

            // White keys
            if !noteName.contains("#"), !noteName.contains("b") {
                let position = leftAnchor.position + whiteKeyWidth * Float(whiteKeyCount)
                let key = AppState.createDebugEntity()
                lastWhiteKeyPosition = position

                keys.append(key)
                key.position = position
                centerAnchor.addChild(key)

                whiteKeyCount += 1
            }

            // Black Keys
            else {
                // For now just put the black key half way between the two white keys
                // In real life the spread is a little wider than that.
                // In the cluster of 3, the middle note is directly in the center of the two white keys
                // In the cluster of 2, each is slightly offset from the center of their respective white keys
                let blackKey = AppState.createDebugEntity()
                var blackKeyPosition = lastWhiteKeyPosition + whiteKeyWidth / 2

                // Set the black key back and up
                blackKeyPosition.z -= 0.07
                blackKeyPosition.y += 0.01

                blackKey.position = blackKeyPosition
                keys.append(blackKey)
                centerAnchor.addChild(blackKey)
            }
        }

        // Create some dummy notes attached to the keys
//        createNoteEntity(color: .systemBlue, forKey: keys[3], at: [0, 0, -0.1], length: 0.1)
//        createNoteEntity(color: .systemBlue, forKey: keys[5], at: [0, 0, -0.1], length: 0.1)
//        createNoteEntity(color: .systemBlue, forKey: keys[7], at: [0, 0, -0.1], length: 0.1)
//
//        createNoteEntity(color: .systemGreen, forKey: keys[10], at: [0, 0, -0.1], length: 0.01)
//        createNoteEntity(color: .systemGreen, forKey: keys[12], at: [0, 0, -0.11], length: 0.01)
//        createNoteEntity(color: .systemGreen, forKey: keys[14], at: [0, 0, -0.12], length: 0.01)
    }

    func createNoteEntity(color: UIColor, forKey: Entity, at: SIMD3<Float>, length: Float) {
        let box = MeshResource.generateBox(width: 0.01, height: 0.01, depth: length, cornerRadius: 0.001)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: box, materials: [material])
        entity.position = at
        forKey.addChild(entity)
    }
}
