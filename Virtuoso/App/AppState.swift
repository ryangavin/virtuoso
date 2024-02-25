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

/// Holds the global runtime state
/// These values are shared between different views
/// Some views need to react to changes
/// Some views need to make changes
@Observable
class AppState {
    // MARK: Piano Configuration

    // Anchors to capture the intial positions in the world space
    // TODO: maybe reparent these after we determine the position of the center
    // TODO: we can recalculate the positions relative to the new center and reposition
    private var leftAnchor: Entity
    private var rightAnchor: Entity

    // This is the  main anchor that all the piano anchors will be relative to
    private var centerAnchor: Entity

    private var keys: [Entity] = []

    var numberOfKeys: Int = 73
    private let numberOfWhiteKeys = [
        73: 43
    ]
    private let startingKey = [
        73: "F"
    ]

    // MARK: UI

    var showImmersiveSpace = false
    var immersiveSpaceIsShown = false
    var showConfigurationMenu = false

    // Piano Configuration

    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        centerAnchor = Entity()

        leftAnchor = AppState.createAnchorEntity()
        rightAnchor = AppState.createAnchorEntity()

        centerAnchor.addChild(leftAnchor)
        centerAnchor.addChild(rightAnchor)

        spaceOrigin.addChild(centerAnchor)
    }

    private static func createAnchorEntity() -> Entity {
        // Load the entity named "Debug Entity"
        guard let entity = try? Entity.load(named: "Debug Anchor", in: realityKitContentBundle) else {
            fatalError("Failed to load the Debug Anchor")
        }
        return entity
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

        // Ditribute the keys evenly across the width of the piano
        // Start from the left anchor and just offset from the previous key
        for i in 0 ..< numberOfWhiteKeys[numberOfKeys]! {
            let t = Float(i) / Float(numberOfWhiteKeys[numberOfKeys]! - 1)
            let position = mix(leftAnchor.position, rightAnchor.position, t: t)
            let key = AppState.createAnchorEntity()

            keys.append(key)
            centerAnchor.addChild(key)

            key.position = position
        }
    }
}
