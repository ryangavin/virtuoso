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
    @State var numberOfKeys = 71
    @State var bottomKey: String = "C1"
    @State var topKey: String = "C5"

    // Positioning Config
    @State var showAnchors: Bool = false

    var body: some View {
        VStack {
            Text("Piano Configuration")
                .font(.title)

            Form {
                LabeledContent("Number of Keys", value: String($numberOfKeys.wrappedValue))
                Stepper("Change Number of Keys", value: $numberOfKeys, in: 25 ... 88)
                Picker("Bottom Key", selection: $bottomKey) {
                    generateKeyOptions()
                }
                Picker("Top Key", selection: $topKey) {
                    generateKeyOptions()
                }
                Toggle("Show Anchors", isOn: $showAnchors)
            }

            Button("Apply") {
                print("Apply")
            }

        }.padding()
    }

    let notes = ["C", "Db", "D", "Eb", "E", "F", "G", "Ab", "A", "Bb", "B"]

    // Generates strings for 5 octaves of musical notes, starting on C1
    func generateKeyOptions() -> some View {
        var keys: [String] = []
        for octave in 1 ... 5 {
            for note in notes {
                keys.append("\(note)\(octave)")
            }
        }
        return ForEach(keys, id: \.self) { key in
            Text(key)
        }
    }
}

#Preview(windowStyle: .automatic) {
    PianoConfigurationMenu()
}
