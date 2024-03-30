//
//  DefaultSongs.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/17/24.
//

import Foundation

extension SongCollection {
    static let classicRockSongs =
        SongCollection(
            title: "Classic Rock",
            details: "A collection of classic rock songs",
            songs: [
                Song(
                    title: "Peg",
                    artist: "Steely Dan",
                    details: "From the album Aja",
                    midiFile: "peg",
                    midiTracks: [
                        Song.Track(trackNumber: 1, sound: .electricPiano, lessonTrack: true),
                        Song.Track(trackNumber: 2, sound: .guitar),
                        Song.Track(trackNumber: 3, sound: .bass),
                        Song.Track(trackNumber: 4, sound: .guitar),
                        Song.Track(trackNumber: 5, sound: .guitar),
                        Song.Track(trackNumber: 6, sound: .brass),
                        Song.Track(trackNumber: 7, sound: .brass),
                        Song.Track(trackNumber: 8, sound: .brass),
                        Song.Track(trackNumber: 9, sound: .brass),
                        Song.Track(trackNumber: 10, sound: .drums),
                    ]),
            ])

    static let peg = classicRockSongs.songs[0]
}
