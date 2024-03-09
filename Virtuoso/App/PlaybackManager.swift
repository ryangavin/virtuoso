//
//  PlaybackManager.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/25/24.
//

import MIKMIDI
import SwiftUI

/// Responsible for managing the playback of the music and the synchronization of the display
@Observable
class PlaybackManager {
    // MIDI objects
    var sequence: MIKMIDISequence?
    var sequencer: MIKMIDISequencer?

    // Transport Controls
    var isPlaying = false

    // Display sync
    var targetDisplayTimestamp = 0.0

    init() {
        createDisplayLink()
    }

    func loadSequence() async {
        sequence = try! MIKMIDISequence(fileAt: Bundle.main.url(forResource: "peg", withExtension: "mid")!)
        sequencer = MIKMIDISequencer(sequence: sequence!)
    }

    func startPlayback() {
        guard sequencer != nil else { return }
        sequencer!.startPlayback()
        isPlaying = true
    }

    func stopPlayback() {
        sequencer!.stop()
        isPlaying = false
    }

    func createDisplayLink() {
        let displaylink = CADisplayLink(target: self, selector: #selector(step))
        displaylink.add(to: .current, forMode: .default)
    }

    @objc func step(displaylink: CADisplayLink) {
        targetDisplayTimestamp = displaylink.targetTimestamp
    }
}
