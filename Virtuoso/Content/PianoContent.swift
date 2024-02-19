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
    @Environment(ViewModel.self) private var model

    var body: some View {
        PianoRealityView(pianoConfiguration: model.pianoConfiguration)
            .placementGestures(
                initialPosition: Point3D([200, 0.0, 0.0])
            )
    }
}
