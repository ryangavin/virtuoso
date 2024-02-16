//
//  VirtuosoApp.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftUI

@main
struct VirtuosoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            PianoContent().placementGestures(initialPosition: Point3D([0.0, 0.0, 0.0]))
        }
    }
}
