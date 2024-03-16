//
//  Song.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/10/24.
//

import Foundation

struct Song: Codable, Identifiable {
    var id: String
    var title: String
    var artist: String
    var description: String
    var difficulty: Int
}
