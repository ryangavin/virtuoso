//
//  PianoContent.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import RealityKit
import SwiftUI

/// The model content for the orbit module.
struct PianoContent: View {
    @State var axZoomIn: Bool = false
    @State var axZoomOut: Bool = false

    var body: some View {
        PianoRealityView().placementGestures(
            initialPosition: Point3D([0.0, 0.0, 0.0])
        )
    }
}
