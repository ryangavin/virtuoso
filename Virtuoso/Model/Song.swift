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
    
    var favorite: Bool

    init(title: String, artist: String, details: String, difficulty: Int, favorite: Bool = false) {
        self.title = title
        self.artist = artist
        self.details = details
        self.difficulty = difficulty
        self.favorite = favorite
    }
}
