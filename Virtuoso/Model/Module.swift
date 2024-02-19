//
//  Module.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/19/24.
//

import Foundation

enum Module: String, Identifiable, CaseIterable, Equatable {
    case mainMenu, pianoConfigurationMenu, immersiveSpace

    var id: Self { self }
    var name: String { rawValue.capitalized }
}
