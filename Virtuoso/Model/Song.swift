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
    @Model
    final class Track {
        enum Hand: Codable {
            case left
            case right
            case both
        }

        enum Sound: String, CaseIterable, Codable {
            case piano
            case electricPiano
            case guitar
            case bass
            case drums
            case strings
            case synthesizer
            case brass
            case vocals
        }

        var trackNumber: Int
        var lessonTrack: Bool
        var hand: Hand
        var sound: Sound

        init(trackNumber: Int, sound: Sound = .piano, hand: Hand = .both, lessonTrack: Bool = false) {
            self.trackNumber = trackNumber
            self.lessonTrack = lessonTrack
            self.hand = hand
            self.sound = sound
        }
    }

    var belongsToUser: Bool

    var title: String
    var artist: String
    var details: String
    var difficulty: Int

    var favorite: Bool

    var midiFile: String
    var midiTracks: [Track]

    init(
        belongsToUser: Bool = false,
        title: String = "",
        artist: String = "",
        details: String = "",
        difficulty: Int = 1,
        favorite: Bool = false,
        midiFile: String = "",
        midiTracks: [Track] = []
    ) {
        self.belongsToUser = belongsToUser
        self.title = title
        self.artist = artist
        self.details = details
        self.difficulty = difficulty
        self.favorite = favorite
        self.midiFile = midiFile
        self.midiTracks = midiTracks
    }
}
