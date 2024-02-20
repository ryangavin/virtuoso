//
//  Extensions.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/19/24.
//

import RealityKit
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
}
