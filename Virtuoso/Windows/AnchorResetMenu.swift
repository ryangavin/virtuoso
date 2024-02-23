//
//  AnchorResetMenu.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/22/24.
//

import SwiftUI

struct AnchorResetMenu: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack {
            Text("Anchor Reset").font(.title)
            Text("Put a video here explaining how to reset the anchors.")

            HStack {
                Button("Capture left") {
                    model.captureIndexFingerPosition(chirality: .left)
                }
                Button("Capture right") {
                    model.captureIndexFingerPosition(chirality: .right)
                }
            }.padding(.top, 10)

            Button("Confirm Positioning") {}
                .tint(.blue)
                .padding(.top, 5)
        }
    }
}

#Preview {
    AnchorResetMenu(model: .init())
}
