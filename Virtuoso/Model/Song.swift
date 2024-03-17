//
//  Song.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/10/24.
//

import Foundation
import SwiftData

@Model
final class Song {
    var title: String
    var artist: String
    var details: String
    var difficulty: Int

    init(title: String, artist: String, details: String, difficulty: Int) {
        self.title = title
        self.artist = artist
        self.details = details
        self.difficulty = difficulty
    }
}
