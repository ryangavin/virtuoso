//
//  PianoModel.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/23/24.
//

import ARKit
import RealityKit
import RealityKitContent
import SwiftUI

@MainActor class PianoModel: ObservableObject {
    private var mainAnchor: Entity

    private var leftConfigurationAnchor: Entity? = nil
    private var rightConfigurationAnchor: Entity? = nil

    private var leftDebugAnchor: Entity? = nil
    private var rightDebugAnchor: Entity? = nil
    
    private var anchorConfigurationComplete = false

    // Initiailzer
    init() {
        mainAnchor = PianoModel.createMarkerEntity(color: .green)
        spaceOrigin.addChild(mainAnchor)
    }

    public func translate(translation: SIMD3<Float>) {}

    private static func createMarkerEntity(color: UIColor) -> Entity {
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [material])
        return entity
    }
}
