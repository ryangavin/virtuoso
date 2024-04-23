//
//  HandManager.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/25/24.
//

import ARKit
import RealityKit
import SwiftUI

@Observable
class WorldManager {
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()

    init() {
        // Fingertip setup
        fingertips = [
            .left: [
                HandSkeleton.JointName.indexFingerTip: WorldManager.createFingertipEntity(),
                HandSkeleton.JointName.ringFingerTip: WorldManager.createFingertipEntity(),
                HandSkeleton.JointName.middleFingerTip: WorldManager.createFingertipEntity(),
                HandSkeleton.JointName.littleFingerTip: WorldManager.createFingertipEntity(),
                HandSkeleton.JointName.thumbTip: WorldManager.createFingertipEntity()
            ],
            .right: [
                HandSkeleton.JointName.indexFingerTip: WorldManager.createFingertipEntity(),
                HandSkeleton.JointName.ringFingerTip: WorldManager.createFingertipEntity(),
                HandSkeleton.JointName.middleFingerTip: WorldManager.createFingertipEntity(),
                HandSkeleton.JointName.littleFingerTip: WorldManager.createFingertipEntity(),
                HandSkeleton.JointName.thumbTip: WorldManager.createFingertipEntity()
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
}
