//
//  PlaybackWidget.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/25/24.
//

import SwiftUI

struct PlaybackWidget: View {
    static let attachmentId = "PlaybackWidget"

    var body: some View {
        HStack {
            // Transport
            Button(action: {}, label: {
                Image(systemName: "backward")
            })
            Button(action: {}, label: {
                Image(systemName: "stop")
            })
            Button(action: {}, label: {
                Image(systemName: "play")
            })
            Button(action: {}, label: {
                Image(systemName: "forward")
            }).padding(.trailing, 20)

            // Tempo Stuff
            Button(action: {}, label: {
                Image(systemName: "plus")
            })
            VStack {
                Text("100%")
                Text("120 BPM")
            }
            Button(action: {}, label: {
                Image(systemName: "minus")
            }).padding(.trailing, 20)

            // TODO: Looper
            Button(action: {}, label: {
                Image(systemName: "arrow.counterclockwise")
            })
        }
    }
}

#Preview {
    PlaybackWidget()
}
