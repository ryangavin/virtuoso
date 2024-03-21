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

                Button(action: {}, label: {
                    Image(systemName: "backward")
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
                Button(action: {}, label: {
                    Image(systemName: "forward")
                }).padding(.trailing, 20)

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
                }).padding(.trailing, 20)

                // MARK: TODO: Looper

                Button(action: {}, label: {
                    Image(systemName: "arrow.counterclockwise")
                })

                Divider()
                    .frame(height: 50)
                    .padding([.leading, .trailing], 5)

                Button(action: {}, label: {
                    Image(systemName: "gearshape")
                })
            }
            HStack {
                // Progress Bar
                Text("\(String(format: "%5.2f", playbackManager.currentTime))")
                    .frame(width: 60)
                Slider(value: $bindablePlaybackManager.currentTime, in: 0.0 ... playbackManager.maxLength) { scrubStarted in
                    if scrubStarted {
                        playbackManager.scrubState = .scrubStarted
                    } else {
                        playbackManager.scrubState = .scrubEnded(bindablePlaybackManager.currentTime)
                    }
                }
                Text("\(String(format: "%5.2f", playbackManager.maxLength))")
                    .frame(width: 60)
            }.frame(width: 650)
        }
    }
}

#Preview {
    PlaybackWidget()
        .padding()
        .glassBackgroundEffect()
        .environment(PlaybackManager())
}
