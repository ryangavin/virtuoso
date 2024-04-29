//
//  DefaultSongs.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/17/24.
//

import Foundation

extension SongCollection {
    static let childrensSongs =
        SongCollection(
            title: "Children's Songs",
            details: "A collection of children's songs",
            songs: [
                Song(
                    title: "Itsy Bitsy Spider",
                    artist: "Traditional",
                    details: "A jazz arrangement of the classic nursery rhyme",
                    midiFile: "itsy_bitsy_spider",
                    midiTracks: [
                        Song.Track(trackNumber: 0, sound: .electricPiano),
                        Song.Track(trackNumber: 1, sound: .electricPiano, hand: .right, lessonTrack: true),
                        Song.Track(trackNumber: 2, sound: .electricPiano, hand: .left, lessonTrack: true),
                        Song.Track(trackNumber: 3, sound: .bass),
                        Song.Track(trackNumber: 4, sound: .brass),
                        Song.Track(trackNumber: 5, sound: .brass),
                        Song.Track(trackNumber: 6, sound: .piano),
                        Song.Track(trackNumber: 7, sound: .piano),
                        Song.Track(trackNumber: 8, sound: .drums),
                    ]),
                Song(
                    title: "Baa Baa Black Sheep",
                    artist: "Traditional",
                    details: "A piano arrangement of the classic nursery rhyme",
                    midiFile: "baabaablacksheep",
                    midiTracks: [
                        Song.Track(trackNumber: 0, sound: .piano, hand: .both, lessonTrack: true),
                    ]),
                Song(
                    title: "Farmer in the Dell",
                    artist: "Traditional",
                    details: "A piano arrangement of the classic nursery rhyme",
                    midiFile: "farmer_in_the_dell",
                    midiTracks: [
                        Song.Track(trackNumber: 1, sound: .piano, hand: .both, lessonTrack: true),
                        Song.Track(trackNumber: 2, sound: .guitar),
                        Song.Track(trackNumber: 3, sound: .brass),
                        Song.Track(trackNumber: 4, sound: .drums),
                        Song.Track(trackNumber: 5, sound: .bass),

                    ]),
            ])
}
