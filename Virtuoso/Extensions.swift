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
    subscript(parentMatching targetName: String) -> Entity? {
        if name.contains(targetName) {
            return self
        }

        guard let nextParent = parent else {
            return nil
        }

        return nextParent[parentMatching: targetName]
    }

    static func createDebugEntity() -> Entity {
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
