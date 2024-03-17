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
        HStack {
            // Transport
            Button(action: {}, label: {
                Image(systemName: "backward")
            })
            Button(action: {
                playbackManager.stopPlayback()
            }, label: {
                Image(systemName: "stop")
            })
            Button(action: {
                playbackManager.startPlayback()
            }, label: {
                Image(systemName: "play")
            })
            Button(action: {}, label: {
                Image(systemName: "forward")
            }).padding(.trailing, 20)

            // Tempo Stuff
            Button(action: {}, label: {
                Image(systemName: "minus")
            })
            VStack {
                Text("100%")
                Text("120 BPM")
            }
            Button(action: {}, label: {
                Image(systemName: "plus")
            }).padding(.trailing, 20)

            // TODO: Looper
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
    }
}

#Preview {
    PlaybackWidget()
        .padding()
        .glassBackgroundEffect()
        .environment(PlaybackManager())
}
