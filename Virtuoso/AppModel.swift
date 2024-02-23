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
@MainActor class AppModel: ObservableObject {
    // MARK: ARKit

    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()

    private let fingerEntities: [HandAnchor.Chirality: [HandSkeleton.JointName: ModelEntity]] = [
        .left: [
            HandSkeleton.JointName.indexFingerTip: createFingertipEntity(),
            HandSkeleton.JointName.ringFingerTip: createFingertipEntity(),
            HandSkeleton.JointName.middleFingerTip: createFingertipEntity(),
            HandSkeleton.JointName.littleFingerTip: createFingertipEntity(),
            HandSkeleton.JointName.thumbTip: createFingertipEntity()
        ],
        .right: [
            HandSkeleton.JointName.indexFingerTip: createFingertipEntity(),
            HandSkeleton.JointName.ringFingerTip: createFingertipEntity(),
            HandSkeleton.JointName.middleFingerTip: createFingertipEntity(),
            HandSkeleton.JointName.littleFingerTip: createFingertipEntity(),
            HandSkeleton.JointName.thumbTip: createFingertipEntity()
        ]
    ]

    private var meshEntities = [UUID: ModelEntity]()

    // MARK: Piano Configuration

    private var leftAnchor: Entity = createAnchorEntity(color: .blue)
    private var rightAnchor: Entity = createAnchorEntity(color: .blue)
    private var centerAnchor: Entity = createAnchorEntity(color: .green)

    private var width: Float = 0.0
    private var angle: Float = 0.0

    @Published var numberOfKeys: Int = 73

    // MARK: UI

    @Published var showImmersiveSpace = false
    @Published var immersiveSpaceIsShown = false
    @Published var showConfigurationMenu = false
    @Published var showAnchorMenu = false

    // Piano Configuration

    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        Task { @MainActor in
        }
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

                fingerEntities[anchor.chirality]?[.indexFingerTip]?.setTransformMatrix(originFromIndex, relativeTo: spaceOrigin)
                fingerEntities[anchor.chirality]?[.middleFingerTip]?.setTransformMatrix(originFromMiddle, relativeTo: spaceOrigin)
                fingerEntities[anchor.chirality]?[.ringFingerTip]?.setTransformMatrix(originFromRing, relativeTo: spaceOrigin)
                fingerEntities[anchor.chirality]?[.littleFingerTip]?.setTransformMatrix(originFromLittle, relativeTo: spaceOrigin)
                fingerEntities[anchor.chirality]?[.thumbTip]?.setTransformMatrix(originFromThumb, relativeTo: spaceOrigin)
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
                if type == .handTracking && status != .allowed {
                    // TODO: Stop the app, ask the user to grant hand tracking authorization again in Settings.
                }
            default:
                print("Session event \(event)")
            }
        }
    }

    // MARK: Functions for interacting with the virtual piano

    // TODO: This probably needs to move to a custom PianoEntity

    static func createAnchorEntity(color: UIColor) -> Entity {
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [material])
        spaceOrigin.addChild(entity)
        return entity
    }

    func moveUp() {
        let newPosition = centerAnchor.position + [0, 0.01, 0]
        centerAnchor.position = newPosition
    }

    func moveDown() {
        let newPosition = centerAnchor.position + [0, -0.01, 0]
        centerAnchor.position = newPosition
    }

    func moveLeft() {
        // Move the center anchor towards the left anchor

        let newPosition = centerAnchor.position + [-0.01, 0, 0]
        centerAnchor.position = newPosition
    }

    func moveRight() {
        let newPosition = centerAnchor.position + [0.01, 0, 0]
        centerAnchor.position = newPosition
    }

    func captureIndexFingerPosition(chirality: HandAnchor.Chirality) {
        print("Updating fingertip position")
        let fingerTip = fingerEntities[chirality]![.indexFingerTip]!
        var position = fingerTip.position(relativeTo: spaceOrigin)
        if chirality == .left {
            leftAnchor.setPosition(position, relativeTo: spaceOrigin)
        } else {
            // Force the right anchor to be at the same height as the left anchor
            position.y = leftAnchor.position.y
            rightAnchor.setPosition(position, relativeTo: spaceOrigin)
        }

        // Find the center between the two anchors
        let center = (leftAnchor.position + rightAnchor.position) / 2
        centerAnchor.setPosition(center, relativeTo: spaceOrigin)
    }
}
