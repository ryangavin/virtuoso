//
//  PianoEntity+Configuration.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftUI

extension PianoEntity {
    /// Configuration information for Earth entities.
    struct Configuration {
        var scale: Float = 0.6
        var position: SIMD3<Float> = .zero
    }
}
