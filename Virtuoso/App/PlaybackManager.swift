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

        let pianoTrack = midi.noteTracks[0]

        print(midi.tempoTrack.timeSignatures)
        // [MidiParser.MidiTimeSignature(timeStamp: 0.0, numerator: 4, denominator: 2, cc: 24, bb: 8)]
        print(midi.tempoTrack.extendedTempos)
        // [MidiParser.MidiExtendedTempo(timeStamp: 0.0, bpm: 120.0)]

        // Iterate over the events
        for event in pianoTrack.makeIterator() {
            print(event)
        }
    }
}
