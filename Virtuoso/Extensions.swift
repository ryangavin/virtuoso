//
//  Extensions.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/19/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

extension Entity {
    static func createDebugEntity() -> Entity {
        if debugAnchorEntity == nil {
            // Load the entity named "Debug Entity"
            guard let loadedEntity = try? Entity.load(named: "Debug Anchor", in: realityKitContentBundle) else {
                fatalError("Failed to load the Debug Anchor")
            }
            debugAnchorEntity = loadedEntity
            debugAnchorEntity?.components[OpacityComponent.self] = .init(opacity: 0.0)
        }

        return debugAnchorEntity!.clone(recursive: true)
    }
}
