//
//  PlaybackManager.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/25/24.
//

import MIKMIDI
import SwiftUI

/// Responsible for managing the playback of the music
@Observable
class PlaybackManager {
    let sequence: MIKMIDISequence
    let sequencer: MIKMIDISequencer

    init() {
        sequence = try! MIKMIDISequence(fileAt: Bundle.main.url(forResource: "peg", withExtension: "mid")!)
        sequencer = MIKMIDISequencer(sequence: sequence)
        
        // Draw the sequence to the screen
        
    }

    func startPlayback() {
        sequencer.startPlayback()
    }

    func stopPlayback() {
        sequencer.stop()
    }
}
