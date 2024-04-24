//
//  SetupWizard.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 4/21/24.
//

import SwiftUI

struct PianoMeasurementStep: View {
    @Environment(PianoManager.self) var pianoManager

    @State var leftPosition: SIMD3<Float>? = nil
    @State var rightPosition: SIMD3<Float>? = nil

    var body: some View {
        VStack {
            Text("Let's find your piano in the real world!")
                .font(.title)
                .padding(.bottom, 30)

            Spacer()

            Form {
                Section {
                    HStack {
                        if leftPosition == nil {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        Text("Left Position")
                        Spacer()
                        Button("Capture") {
                            leftPosition = pianoManager.captureIndexFingerPosition(chirality: .left)
                        }
                    }
                    HStack {
                        if rightPosition == nil {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        Text("Right Position")
                        Spacer()
                        Button("Capture") {
                            rightPosition = pianoManager.captureIndexFingerPosition(chirality: .right)
                        }
                    }
                }
            }.frame(height: 140)

            let disabled = leftPosition == nil || rightPosition == nil
            Button("Complete Setup") {
                // Save the positions
            }
            .padding()
            .disabled(disabled)
            .tint(disabled ? .gray : .accentColor)
        }
        .navigationTitle("Piano Measurement")
        .multilineTextAlignment(.center)
        .frame(width: 500, height: 500)
        .padding()
    }
}

struct PianoInformationStep: View {
    @State var numberOfKeys: Int = 77
    @State var selectedKey: String = "F"

    let allowedKeys: [Int] = [25, 37, 73, 77, 88]
    let allowedNotes: [String] = ["C", "Db", "D", "Eb", "E", "F", "G", "Ab", "A", "Bb", "B"]

    var body: some View {
        VStack {
            Text("How many keys does your piano have?")
                .font(.title)
                .padding(.bottom, 30)

            Form {
                // Dropdown for number of keys
                Picker("Number of Keys", selection: $numberOfKeys) {
                    ForEach(allowedKeys, id: \.self) { key in
                        Text("\(key) Keys")
                    }
                }

                // Bottom key picker
                Picker("Bottom Note", selection: $selectedKey) {
                    ForEach(allowedNotes, id: \.self) { note in
                        Text(note)
                    }
                }
            }

            NavigationLink("Next", destination: PianoMeasurementStep())
                .tint(.accentColor)
        }
        .navigationTitle("Piano Information")
        .multilineTextAlignment(.center)
        .frame(width: 500, height: 320)
        .padding(20)
    }
}

struct SetupWizard: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Virtuoso!")
                    .font(.extraLargeTitle2)
                    .padding()
                Text("Let's get started by setting up your piano.")
                    .font(.title)
                    .padding(.bottom, 30)

                NavigationLink("Begin Setup", destination: PianoInformationStep())
                    .tint(.accentColor)
            }
            .frame(width: 500, height: 220)
            .padding(20)
        }
    }
}

#Preview {
    SetupWizard()
        .environment(PianoManager())
        .glassBackgroundEffect()
}

#Preview {
    NavigationStack {
        PianoInformationStep()
            .environment(PianoManager())
    }.glassBackgroundEffect()
}

#Preview {
    NavigationStack {
        PianoMeasurementStep()
            .environment(PianoManager())
    }.glassBackgroundEffect()
}
