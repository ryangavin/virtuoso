//
//  PlaybackWidget.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/25/24.
//

import SwiftUI

struct TransportControls: View {
    @Environment(PlaybackManager.self) var playbackManager

    var body: some View {
        HStack {
            Button(action: {
                playbackManager.backFour()
            }, label: {
                Image(systemName: "arrow.counterclockwise")
            })
            Button(action: {
                playbackManager.stopPlayback()
            }, label: {
                Image(systemName: "stop")
            })
            Button(action: {
                if playbackManager.isPlaying {
                    playbackManager.pausePlayback()
                } else {
                    playbackManager.startPlayback()
                }
            }, label: {
                Image(systemName: playbackManager.isPlaying ? "pause" : "play")
            })
            Button(action: {
                playbackManager.jumpFour()
            }, label: {
                Image(systemName: "arrow.clockwise")
            })
        }
    }
}

struct TempoControls: View {
    @Environment(PlaybackManager.self) var playbackManager

    var body: some View {
        HStack {
            Button(action: {
                playbackManager.decreaseTempo()
            }, label: {
                Image(systemName: "minus")
            })

            Text("\(String(format: "%5.2f", playbackManager.currentTempo))")
                .frame(width: 80)
                .font(.title3)

            Button(action: {
                playbackManager.increaseTempo()
            }, label: {
                Image(systemName: "plus")
            })
        }
    }
}

struct ScrubWidget: View {
    @Environment(PlaybackManager.self) var playbackManager
    @Environment(PianoManager.self) var pianoManager

    var body: some View {
        @Bindable var bindablePlaybackManager = playbackManager

        HStack {
            // Progress Beats
            Group {
                Text("\((Int(playbackManager.currentTime) / 4) + 1)")
                Text(".")
                Text("\((Int(playbackManager.currentTime) % 4) + 1)")
                    .frame(width: 10)
                Text(".")
                Text("\((Int(playbackManager.currentTime * 4) % 4) + 1)")
                    .frame(width: 10)
                    .padding(.trailing, 10)
            }.font(.title3)

            // Progress Bar
            Slider(value: $bindablePlaybackManager.currentTime, in: 0.0 ... playbackManager.maxLength) { scrubStarted in
                if scrubStarted {
                    playbackManager.scrubState = .scrubStarted
                } else {
                    playbackManager.scrubState = .scrubEnded(bindablePlaybackManager.currentTime)
                    pianoManager.clearTrack()
                }
            }

            // Total Beats
            Group {
                Text("\((Int(playbackManager.maxLength) / 4) + 1)")
                Text(".")
                Text("\((Int(playbackManager.maxLength) % 4) + 1)")
                    .frame(width: 10)
                Text(".")
                Text("\((Int(playbackManager.maxLength * 4) % 4) + 1)")
                    .frame(width: 10)
            }.font(.title3)
        }
    }
}

struct PlaybackWidget: View {
    @Environment(PlaybackManager.self) var playbackManager
    @Environment(AppState.self) var appState
    @Environment(PianoManager.self) var pianoManager

    var body: some View {
        @Bindable var bindablePlaybackManager = playbackManager

        VStack {
            HStack {
                // Song details
                if let loadedSong = appState.loadedSong {
                    Text("\(loadedSong.title) - \(loadedSong.artist)")
                        .font(.title)
                } else {
                    Text("No Song Selected")
                        .font(.title)
                }
            }

            HStack {
                TempoControls()

                Spacer()

                TransportControls()

                Spacer()

                // The tint is not working when the widget is embedded
                Button(action: {
                    appState.showConfigurationMenu.toggle()
                }, label: {
                    Image(systemName: "gearshape")
                }).tint(appState.showConfigurationMenu ? .accentColor : .none)
            }

            ScrubWidget()
        }
        .padding(10)
        .frame(width: 800, height: 140)
    }
}

struct PlaybackWidget_Previews: PreviewProvider {
    static var previews: some View {
        return PlaybackWidget()
            .padding()
            .glassBackgroundEffect()
            .environment(PlaybackManager())
            .environment(PianoManager())
            .environment(AppState())
    }
}
