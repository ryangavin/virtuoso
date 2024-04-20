//
//  Materials.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 4/18/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

// TODO: this whole setup seems like a mess but whatever
extension Entity {
    static func loadMaterial(_ material: String, from: Bundle, withFileName: String) async -> ShaderGraphMaterial {
        let url = from.url(forResource: withFileName, withExtension: "usda")!
        return try! await ShaderGraphMaterial(named: material, from: url)
    }

    static func loadRealityViewMaterials() async {
        collisionMaterial = await loadMaterial("CollisionMaterial", from: realityKitContentBundle, withFileName: "Materials")
    }
}
