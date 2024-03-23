//
//  PlaybackWidget.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/25/24.
//

import SwiftUI

struct PlaybackWidget: View {
    @Environment(PlaybackManager.self) var playbackManager

    var body: some View {
        @Bindable var bindablePlaybackManager = playbackManager

        VStack {
            HStack {
                // MARK: Transport

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
                        playbackManager.stopPlayback()
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

                Spacer()

                // MARK: Tempo Stuff

                Button(action: {
                    playbackManager.decreaseTempo()
                }, label: {
                    Image(systemName: "minus")
                })
                VStack {
                    Text("100%")
                    Text("\(String(format: "%5.2f", playbackManager.currentTempo)) BPM")
                }.frame(width: 100)

                Button(action: {
                    playbackManager.increaseTempo()
                }, label: {
                    Image(systemName: "plus")
                })

                // MARK: TODO: Looper

                Spacer()

                Button(action: {}, label: {
                    Image(systemName: "gearshape")
                })
            }

            HStack {
                // Progress Beats
                Text("\((Int(playbackManager.currentTime) / 4) + 1)")
                Text(".")
                Text("\((Int(playbackManager.currentTime) % 4) + 1)")
                    .frame(width: 10)
                Text(".")
                Text("\((Int(playbackManager.currentTime * 4) % 4) + 1)")
                    .frame(width: 10)
                    .padding(.trailing, 10)

                // Progress Bar
                Slider(value: $bindablePlaybackManager.currentTime, in: 0.0 ... playbackManager.maxLength) { scrubStarted in
                    if scrubStarted {
                        playbackManager.scrubState = .scrubStarted
                    } else {
                        playbackManager.scrubState = .scrubEnded(bindablePlaybackManager.currentTime)
                    }
                }

                // Total Beats
                Text("\((Int(playbackManager.maxLength) / 4) + 1)")
                Text(".")
                Text("\((Int(playbackManager.maxLength) % 4) + 1)")
                    .frame(width: 10)
                Text(".")
                Text("\((Int(playbackManager.maxLength * 4) % 4) + 1)")
                    .frame(width: 10)
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
}
