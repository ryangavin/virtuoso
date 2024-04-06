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

struct PlaybackWidget: View {
    @Environment(PlaybackManager.self) var playbackManager
    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var bindablePlaybackManager = playbackManager

        VStack {
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

                Button(action: {
                    appState.showImmersiveSpace = false
                    appState.showTrainerWindow = false
                    appState.showBrowserWindow = true
                }, label: {
                    Image(systemName: "pip.exit")
                })
            }

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
        .padding([.leading, .trailing], 10)
        .frame(width: 800)
    }
}

#Preview {
    PlaybackWidget()
        .padding()
        .glassBackgroundEffect()
        .environment(PlaybackManager())
        .environment(AppState())
}
