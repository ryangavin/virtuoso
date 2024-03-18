//
//  DefaultSongs.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/17/24.
//

import Foundation

extension SongCollection {
    static let childrensSongs = SongCollection(title: "Children's Songs", details: "A collection of songs to get you started", difficulty: 1, songs: [
        Song(title: "Twinkle, Twinkle, Little Star", artist: "Unknown", details: "A classic children's song", difficulty: 1),
        Song(title: "Mary Had a Little Lamb", artist: "Unknown", details: "Another classic children's song", difficulty: 1),
        Song(title: "The Wheels on the Bus", artist: "Unknown", details: "Yet another classic children's song", difficulty: 1),
        Song(title: "Old MacDonald Had a Farm", artist: "Unknown", details: "A classic children's song", difficulty: 1),
        Song(title: "The Itsy Bitsy Spider", artist: "Unknown", details: "A classic children's song", difficulty: 1),
        Song(title: "Baa, Baa, Black Sheep", artist: "Unknown", details: "A classic children's song", difficulty: 1),
        Song(title: "Row, Row, Row Your Boat", artist: "Unknown", details: "A classic children's song", difficulty: 1),
        Song(title: "London Bridge", artist: "Unknown", details: "A classic children's song", difficulty: 1)])

    static let classicRockSongs = SongCollection(title: "Classic Rock", details: "A collection of classic rock songs", difficulty: 3, songs: [
        Song(title: "Stairway to Heaven", artist: "Led Zeppelin", details: "A classic rock song", difficulty: 4),
        Song(title: "Bohemian Rhapsody", artist: "Queen", details: "Another classic rock song", difficulty: 4),
        Song(title: "Hotel California", artist: "The Eagles", details: "A classic rock song", difficulty: 3),
        Song(title: "Sweet Child O' Mine", artist: "Guns N' Roses", details: "A classic rock song", difficulty: 3),
        Song(title: "Free Bird", artist: "Lynyrd Skynyrd", details: "A classic rock song", difficulty: 3),
        Song(title: "Dream On", artist: "Aerosmith", details: "A classic rock song", difficulty: 3),
        Song(title: "More Than a Feeling", artist: "Boston", details: "A classic rock song", difficulty: 3),
        Song(title: "Carry on Wayward Son", artist: "Kansas", details: "A classic rock song", difficulty: 3)])

    static let classicalSongs = SongCollection(title: "Classical", details: "A collection of classical songs", difficulty: 5, songs: [
        Song(title: "Symphony No. 5", artist: "Beethoven", details: "A classic classical song", difficulty: 5),
        Song(title: "The Four Seasons", artist: "Vivaldi", details: "Another classic classical song", difficulty: 5),
        Song(title: "Symphony No. 9", artist: "Beethoven", details: "A classic classical song", difficulty: 5),
        Song(title: "Canon in D", artist: "Pachelbel", details: "A classic classical song", difficulty: 5),
        Song(title: "The Magic Flute", artist: "Mozart", details: "A classic classical song", difficulty: 5),
        Song(title: "The Planets", artist: "Holst", details: "A classic classical song", difficulty: 5),
        Song(title: "The Nutcracker Suite", artist: "Tchaikovsky", details: "A classic classical song", difficulty: 5),
        Song(title: "Ride of the Valkyries", artist: "Wagner", details: "A classic classical song", difficulty: 5)])
}
