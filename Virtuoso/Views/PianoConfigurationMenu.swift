//
//  PianoConfigurationMenu.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/18/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct PianoConfigurationMenu: View {
    @Environment(PianoManager.self) var pianoManager
    @Environment(AppState.self) var appState

    // Constants
    let supportedKeys = [25, 37, 49, 73, 88]
    let notes = ["C", "Db", "D", "Eb", "E", "F", "G", "Ab", "A", "Bb", "B"]

    var body: some View {
        @Bindable
        var bindablePianoManager = pianoManager

        VStack {
            Text("Piano Configuration")
                .font(.title)

            Form {
                Picker("Number of Keys", selection: $bindablePianoManager.numberOfKeys) {
                    ForEach(supportedKeys, id: \.self) { key in
                        Text("\(key)")
                    }
                }
            }.scrollDisabled(true)

            HStack {
                Button(action: {
                    pianoManager.stretchAnchor(stretchFactor: 0.005)
                }, label: {
                    Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                })
                Button(action: {
                    pianoManager.rotateAnchor(offset: 0.01)
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
                Button(action: {
                    pianoManager.moveAnchor(translation: simd_float3(0, 0, -0.005))
                }, label: {
                    Image(systemName: "arrowshape.up.fill")
                })
                Button(action: {
                    pianoManager.rotateAnchor(offset: -0.01)
                }, label: {
                    Image(systemName: "arrow.clockwise")
                })
            }
            HStack {
                Button("X") {}
                    .tint(.red)
                Button(action: {
                    pianoManager.moveAnchor(translation: simd_float3(-0.005, 0, 0))
                }, label: {
                    Image(systemName: "arrowshape.left.fill")
                })
                Button(action: {}, label: {
                    Image(systemName: "tortoise.fill")
                })
                Button(action: {
                    pianoManager.moveAnchor(translation: simd_float3(0.005, 0, 0))
                }, label: {
                    Image(systemName: "arrowshape.right.fill")
                })
            }
            HStack {
                Button(action: {
                    pianoManager.stretchAnchor(stretchFactor: -0.005)
                }, label: {
                    Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                })
                Button(action: {
                    pianoManager.moveAnchor(translation: simd_float3(0, 0.005, 0))
                }, label: {
                    Image(systemName: "square.3.layers.3d.top.filled")
                })
                Button(action: {
                    pianoManager.moveAnchor(translation: simd_float3(0, 0, 0.005))
                }, label: {
                    Image(systemName: "arrowshape.down.fill")
                })
                Button(action: {
                    pianoManager.moveAnchor(translation: simd_float3(0, -0.005, 0))
                }, label: {
                    Image(systemName: "square.3.layers.3d.bottom.filled")
                })
            }
            HStack {
                Button("Capture left") {
                    pianoManager.captureIndexFingerPosition(chirality: .left)
                }
                Button("Capture right") {
                    pianoManager.captureIndexFingerPosition(chirality: .right)
                }
            }
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    PianoConfigurationMenu().environment(PianoManager())
}
