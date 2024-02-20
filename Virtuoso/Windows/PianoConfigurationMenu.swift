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
    @ObservedObject var model: AppModel

    @Environment(\.dismissWindow) private var dismissWindow

    @State var numberOfKeys = 71
    @State var bottomKey: String = "C1"

    // Constants for the notes
    let notes = ["C", "Db", "D", "Eb", "E", "F", "G", "Ab", "A", "Bb", "B"]

    var body: some View {
        VStack {
            Text("Piano Configuration")
                .font(.title)

            Text("Tell Virtuoso about your physical Piano or Keyboard")

            Form {
                LabeledContent("Number of Keys", value: String($numberOfKeys.wrappedValue))
                Stepper("Change Number of Keys", value: $numberOfKeys, in: 25 ... 88)
                Picker("Bottom Key", selection: $bottomKey) {
                    generateKeyOptions()
                }
                Toggle("Show Anchors", isOn: $model.shouldShowConfigurtionAnchors)
            }.scrollDisabled(true)

            Button("Apply Configuration") {
                dismissWindow(id: Module.pianoConfigurationMenu.name)
                model.showConfigurationMenu = false
            }.tint(.blue)

        }.padding()
    }

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
    PianoConfigurationMenu(model: AppModel())
}
