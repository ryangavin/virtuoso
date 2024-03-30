//
//  PlaybackManager.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/25/24.
//

import MIKMIDI
import SwiftUI

enum SequencerScrubState {
    case reset
    case scrubStarted
    case scrubEnded(Double)
}

/// Responsible for managing the playback of the music and the synchronization of the display
@Observable
class PlaybackManager {
    // MIDI objects
    var sequence: MIKMIDISequence?
    var sequencer: MIKMIDISequencer?

    var lessonTracks: [Song.Track] = []

    // Display sync
    var targetDisplayTimestamp = 0.0

    // Expose some stuff for the transport widget
    var currentTempo = 120.0
    var currentTime = 0.0
    var maxLength = 0.0
    var isPlaying = false

    // Scrubbing
    var scrubState: SequencerScrubState = .reset {
        didSet {
            switch scrubState {
            case .reset: return
            case .scrubStarted: return
            case .scrubEnded(let seekTime): setPlaybackPosition(seekTime)
            }
        }
    }

    // Internal state
    private var timestampToResumeAt = 0.0

    init() {
        createDisplayLink()
    }

    func loadSong(_ song: Song) async {
        sequence = try! MIKMIDISequence(fileAt: Bundle.main.url(forResource: song.midiFile, withExtension: "mid")!)
        sequencer = MIKMIDISequencer(sequence: sequence!)

        // Process the tracks
        lessonTracks = []
        for track in song.midiTracks {
            // Set up the syntehsizers for the tracks using the configuration on the song
            let synth = sequencer?.builtinSynthesizer(for: sequence!.tracks[track.trackNumber])
            let url = Bundle.main.url(forResource: track.sound.rawValue, withExtension: "sf2")!
            try! synth?.loadSoundfontFromFile(at: url)

            // Identify which tracks are the actual lesson tracks
            // There can be up to two lesson tracks (one for each hand)
            if track.lessonTrack {
                lessonTracks.append(track)
            }
        }

        currentTempo = sequence!.tempo(atTimeStamp: 0.0)
        maxLength = sequence!.length
    }

    func startPlayback() {
        guard sequencer != nil else { return }
        sequencer!.startPlayback()
        sequencer!.currentTimeStamp = timestampToResumeAt
        isPlaying = true
    }

    func stopPlayback() {
        guard sequencer != nil else { return }
        sequencer!.stop()
        sequencer?.currentTimeStamp = 0
        isPlaying = false
    }

    func pausePlayback() {
        guard sequencer != nil else { return }
        timestampToResumeAt = sequencer!.currentTimeStamp
        sequencer!.stop()
        isPlaying = false
    }

    func increaseTempo() {
        guard sequencer != nil else { return }
        currentTempo += 1
        sequencer!.tempo = currentTempo
    }

    func decreaseTempo() {
        guard sequencer != nil else { return }
        currentTempo -= 1
        sequencer!.tempo = currentTempo
    }

    func resetTempo() {
        guard sequencer != nil else { return }
        currentTempo = sequence!.tempo(atTimeStamp: 0.0)
        sequencer!.tempo = currentTempo
    }

    func backFour() {
        guard sequencer != nil else { return }
        if sequencer!.currentTimeStamp < 4 {
            sequencer!.currentTimeStamp = 0
        } else {
            sequencer!.currentTimeStamp -= 4
        }
    }

    func jumpFour() {
        guard sequencer != nil else { return }
        if sequencer!.currentTimeStamp + 4 > maxLength {
            sequencer!.currentTimeStamp = maxLength
        } else {
            sequencer!.currentTimeStamp += 4
        }
    }

    func setPlaybackPosition(_ position: Double) {
        guard sequencer != nil else { return }
        sequencer!.currentTimeStamp = position
    }

    func createDisplayLink() {
        let displaylink = CADisplayLink(target: self, selector: #selector(step))
        displaylink.add(to: .current, forMode: .default)
    }

    @objc func step(displaylink: CADisplayLink) {
        targetDisplayTimestamp = displaylink.targetTimestamp
        guard sequencer != nil else { return }

        // Only update the current time if we aren't scrubbing
        switch scrubState {
        case .reset:
            currentTime = sequencer!.currentTimeStamp
        case .scrubStarted:
            // When scrubbing, the displayTime is bound to the Slider view, so
            // do not update it here.
            break
        case .scrubEnded(let seekTime):
            scrubState = .reset
            sequencer!.currentTimeStamp = seekTime
        }
    }
}
