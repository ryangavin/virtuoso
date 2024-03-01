//
//  PlaybackManager.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/25/24.
//

import MIDIKit
import MidiParser
import SwiftUI

/// Responsible for managing the playback of the music
@Observable
class PlaybackManager {
    let midiManager = MIDIManager(
        clientName: "Virtuoso MIDI Manager",
        model: "Virtuoso",
        manufacturer: "Virtuosity"
    )

    func loadPeg() {
        let midi = MidiData()
        guard let data = try? Data(contentsOf: Bundle.main.url(forResource: "peg", withExtension: "mid")!) else {
            return assertionFailure("Peg not found!")
        }
        midi.load(data: data)

        let tempoTrack = midi.tempoTrack
        let timeResolution = tempoTrack.timeResolution

        // TODO: It might be worth keeping track of the time signature
        // TODO: Right now my understanding is that timeResolution is the number of ticks per denominator
        // TODO: ie: in 4/4 ticks is quarter notes, in 2/2 its half notes, in 7/8 its eighth notes

        // Print out all the tracks
        let pianoTrack = midi.noteTracks[1]

        // Iterate over the events
        print(pianoTrack.count)
        for i in 0 ..< pianoTrack.count {
            let event = pianoTrack[i]
            
            // Draw the events at the right key based on the note value
            // Offset the key depth based on the duration, scaling with the timeResolution
            // That's kind of it.
        }
    }
}
