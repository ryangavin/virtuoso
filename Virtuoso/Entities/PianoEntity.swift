//
//  PianoEntity.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import Foundation

import RealityKit
import RealityKitContent
import SwiftUI

/// An entity that represents the entire Piano learning environment
class PianoEntity: Entity {
    // MARK: - Sub-entities
    
    /// The model that draws the piano keyboard
    private var keyboard: Entity = .init()
    
    // MARK: - Initializers
    
    /// Creates a new blank game field
    @MainActor required init() {
        super.init()
    }
    
    init(configuration: Configuration) async {
        super.init()
        
        // Load the keyboard model
        guard let keyboard = try? await Entity(named: "MainImmersive", in: realityKitContentBundle) else { return }
        self.keyboard = keyboard
        
        // Attach the model to a
        addChild(keyboard)
        
        // Configure everything for the first time
        update(configuration: configuration)
    }
    
    // MARK: - Updates
    
    func update(configuration: Configuration) {
        // Scale and position the entire entity.
        move(
            to: Transform(
                scale: SIMD3(repeating: configuration.scale),
                rotation: orientation,
                translation: configuration.position),
            relativeTo: parent)
        
        // TODO: add accessibility component
    }
}
