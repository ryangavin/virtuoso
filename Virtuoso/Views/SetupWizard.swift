//
//  SetupWizard.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 4/21/24.
//

import SwiftUI

struct PianoMeasurementStep: View {
    @Environment(PianoManager.self) var pianoManager

    @Environment(\.dismiss) var dismiss

    @State var leftPosition: SIMD3<Float>? = nil
    @State var rightPosition: SIMD3<Float>? = nil

    var back: () -> Void

    var body: some View {
        VStack {
            Text("Let's find your piano in the real world!")
                .font(.title)
                .padding(.bottom, 30)

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
            }

            HStack {
                Button("Back") {
                    back()
                }

                let disabled = leftPosition == nil || rightPosition == nil
                Button("Complete Setup") {
                    // TODO: Save the positions

                    dismiss()
                }
                .padding()
                .disabled(disabled)
                .tint(disabled ? .gray : .accentColor)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct PianoInformationStep: View {
    // TODO: these need to be on app state using the user defaults
    @State var numberOfKeys: Int = 77
    @State var selectedKey: String = "F"

    var back: () -> Void
    var next: () -> Void

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
            }.frame(height: 300)

            HStack {
                Button("Back") {
                    back()
                }
                Button("Next") {
                    next()
                }.tint(.accentColor)
            }
        }
        .multilineTextAlignment(.center)
        .padding(20)
    }
}

struct WelcomeStep: View {
    @Environment(AppState.self) var appState

    var next: () -> Void

    var body: some View {
        VStack {
            Text("Welcome to Virtuoso!")
                .font(.extraLargeTitle2)
                .padding()
            Text("Let's get started by setting up your piano.")
                .font(.title)
                .padding(.bottom, 30)

            HStack {
                Button("Skip Setup") {
                    // Skip the setup
                    appState.hasCompletedSetup = true
                }

                Button("Begin Setup") {
                    next()
                }.tint(.accentColor)
            }
        }
    }
}

struct SetupWizard: View {
    @Environment(AppState.self) var appState

    @State var step = 0

    var body: some View {
        let next = {
            step += 1
            if step > 2 {
                step = 2
            }
        }

        let back = {
            step -= 1
            if step < 0 {
                step = 0
            }
        }

        switch step {
        case 0:
            WelcomeStep(next: next)
        case 1:
            PianoInformationStep(back: back, next: next)
        case 2:
            PianoMeasurementStep(back: back)
        default:
            Text("Unknown step")
        }
    }
}

#Preview {
    SetupWizard()
        .environment(PianoManager())
        .environment(AppState())
        .glassBackgroundEffect()
}
