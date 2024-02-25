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
class AppModel {
    // MARK: ARKit

    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()

    private var meshEntities = [UUID: ModelEntity]()

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
    var showAnchorMenu = false

    // Piano Configuration

    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        centerAnchor = Entity()

        leftAnchor = AppModel.createAnchorEntity()
        rightAnchor = AppModel.createAnchorEntity()

        centerAnchor.addChild(leftAnchor)
        centerAnchor.addChild(rightAnchor)

        spaceOrigin.addChild(centerAnchor)

        // Fingertip setup
        fingertips = [
            .left: [
                HandSkeleton.JointName.indexFingerTip: AppModel.createFingertipEntity(),
                HandSkeleton.JointName.ringFingerTip: AppModel.createFingertipEntity(),
                HandSkeleton.JointName.middleFingerTip: AppModel.createFingertipEntity(),
                HandSkeleton.JointName.littleFingerTip: AppModel.createFingertipEntity(),
                HandSkeleton.JointName.thumbTip: AppModel.createFingertipEntity()
            ],
            .right: [
                HandSkeleton.JointName.indexFingerTip: AppModel.createFingertipEntity(),
                HandSkeleton.JointName.ringFingerTip: AppModel.createFingertipEntity(),
                HandSkeleton.JointName.middleFingerTip: AppModel.createFingertipEntity(),
                HandSkeleton.JointName.littleFingerTip: AppModel.createFingertipEntity(),
                HandSkeleton.JointName.thumbTip: AppModel.createFingertipEntity()
            ]
        ]
    }

    func startARKitSession() async {
        do {
            if HandTrackingProvider.isSupported {
                print("ARKitSession starting.")
                try await session.run([handTracking])
            }
        } catch {
            print("ARKitSession error:", error)
        }
    }

    // MARK: Hand Tracking stuff

    @MainActor
    func handleHandTrackingUpdates() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .updated:
                let anchor = update.anchor

                // Publish updates only if the hand and the relevant joints are tracked.
                guard anchor.isTracked else { continue }

                guard
                    let indexFingerTip = update.anchor.handSkeleton?.joint(.indexFingerTip),
                    let middleFingertip = update.anchor.handSkeleton?.joint(.middleFingerTip),
                    let ringFingerTip = update.anchor.handSkeleton?.joint(.ringFingerTip),
                    let littleFingerTip = update.anchor.handSkeleton?.joint(.littleFingerTip),
                    let thumbTip = update.anchor.handSkeleton?.joint(.thumbTip),
                    indexFingerTip.isTracked,
                    middleFingertip.isTracked,
                    ringFingerTip.isTracked,
                    littleFingerTip.isTracked,
                    thumbTip.isTracked
                else { continue }

                let originFromWrist = anchor.originFromAnchorTransform

                let wristFromIndex = indexFingerTip.anchorFromJointTransform
                let originFromIndex = originFromWrist * wristFromIndex

                let wristFromMiddle = middleFingertip.anchorFromJointTransform
                let originFromMiddle = originFromWrist * wristFromMiddle

                let wristFromRing = ringFingerTip.anchorFromJointTransform
                let originFromRing = originFromWrist * wristFromRing

                let wristFromLittle = littleFingerTip.anchorFromJointTransform
                let originFromLittle = originFromWrist * wristFromLittle

                let wristFromThumb = thumbTip.anchorFromJointTransform
                let originFromThumb = originFromWrist * wristFromThumb

                fingertips[anchor.chirality]?[.indexFingerTip]?.setTransformMatrix(originFromIndex, relativeTo: spaceOrigin)
                fingertips[anchor.chirality]?[.middleFingerTip]?.setTransformMatrix(originFromMiddle, relativeTo: spaceOrigin)
                fingertips[anchor.chirality]?[.ringFingerTip]?.setTransformMatrix(originFromRing, relativeTo: spaceOrigin)
                fingertips[anchor.chirality]?[.littleFingerTip]?.setTransformMatrix(originFromLittle, relativeTo: spaceOrigin)
                fingertips[anchor.chirality]?[.thumbTip]?.setTransformMatrix(originFromThumb, relativeTo: spaceOrigin)
            default:
                break
            }
        }
    }

    static func createFingertipEntity() -> ModelEntity {
        let sphereMaterial = SimpleMaterial(color: .cyan, roughness: 0, isMetallic: false)
        let sphereResource = MeshResource.generateSphere(radius: 0.005)
        let entity = ModelEntity(mesh: sphereResource, materials: [sphereMaterial])
        spaceOrigin.addChild(entity)
        return entity
    }

    func monitorSessionEvents() async {
        for await event in session.events {
            switch event {
            case .authorizationChanged(let type, let status):
                if type == .handTracking, status != .allowed {
                    // TODO: Stop the app, ask the user to grant hand tracking authorization again in Settings.
                }
            default:
                print("Session event \(event)")
            }
        }
    }

    // MARK: Functions for interacting with the virtual piano

    // TODO: This probably needs to move to a custom PianoEntity

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
            let key = AppModel.createAnchorEntity()

            keys.append(key)
            centerAnchor.addChild(key)

            key.position = position
        }
    }
}
