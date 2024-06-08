//
//  DefaultSongs.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/17/24.
//

import Foundation

extension SongCollection {
    static let classicalSongs =
        SongCollection(
            title: "Classical Songs",
            details: "A collection of classical songs",
            songs: [
                // Done
                Song(
                    title: "Für Elise",
                    artist: "Ludwig van Beethoven",
                    details: "Bagatelle No. 25 in A minor",
                    difficulty: 3,
                    midiFile: "fur_elise",
                    midiTracks: [
                        Song.Track(trackNumber: 1, sound: .piano, hand: .right, lessonTrack: true),
                        Song.Track(trackNumber: 2, sound: .piano, hand: .left, lessonTrack: true),
                    ]),

                // Done
                Song(
                    title: "Moonlight Sonata",
                    artist: "Ludwig van Beethoven",
                    details: "Piano Sonata No. 14 in C-sharp minor",
                    difficulty: 3,
                    midiFile: "moonlight_sonata",
                    midiTracks: [
                        Song.Track(trackNumber: 2, sound: .piano, hand: .right, lessonTrack: true),
                        Song.Track(trackNumber: 3, sound: .piano, hand: .left, lessonTrack: true),
                    ]),
                // Done
                Song(
                    title: "Canon in D",
                    artist: "Johann Pachelbel",
                    details: "Canon and Gigue in D major",
                    difficulty: 3,
                    midiFile: "canon_in_d",
                    midiTracks: [
                        Song.Track(trackNumber: 1, sound: .brass),
                        Song.Track(trackNumber: 2, sound: .piano, hand: .right, lessonTrack: true),
                        Song.Track(trackNumber: 3, sound: .strings),
                        Song.Track(trackNumber: 4, sound: .piano, hand: .left, lessonTrack: true),
                    ]),
                // Done
                Song(
                    title: "Prelude in C Major",
                    artist: "Johann Sebastian Bach",
                    details: "BWV 846",
                    difficulty: 2,
                    midiFile: "prelude_in_c_major",
                    midiTracks: [
                        Song.Track(trackNumber: 1, sound: .piano, hand: .right, lessonTrack: true),
                        Song.Track(trackNumber: 2, sound: .piano, hand: .left, lessonTrack: true),
                    ]),
                // Done
                Song(
                    title: "Minuet in G Major",
                    artist: "Johann Sebastian Bach",
                    details: "BWV Anh. 114",
                    difficulty: 2,
                    midiFile: "minuet_in_g_major",
                    midiTracks: [
                        Song.Track(trackNumber: 1, sound: .piano, hand: .right, lessonTrack: true),
                        Song.Track(trackNumber: 2, sound: .piano, hand: .left, lessonTrack: true),
                    ]),
                // Done
                Song(
                    title: "Nocturne Op. 9 No. 2",
                    artist: "Frédéric Chopin",
                    details: "Nocturne in E-flat major",
                    difficulty: 3,
                    midiFile: "chopin_nocturne_op9_no2",
                    midiTracks: [
                        Song.Track(trackNumber: 0, sound: .piano, hand: .right, lessonTrack: true),
                        Song.Track(trackNumber: 1, sound: .piano, hand: .left, lessonTrack: true),
                    ]),
            ])
}
