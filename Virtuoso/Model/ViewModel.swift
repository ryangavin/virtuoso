//
//  ViewModel.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/15/24.
//

import SwiftUI

/// The data that the app uses to configure its views.
@Observable
class ViewModel {
    var pianoConfiguration: PianoEntity.Configuration = .init(scale: 0.4, position: [0.0, 0.0, 0.0])

    var showImmersiveSpace = false
    var immersiveSpaceIsShown = false
    var showConfigurationMenu = false
}
