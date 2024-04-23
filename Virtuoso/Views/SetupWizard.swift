//
//  SetupWizard.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 4/21/24.
//

import SwiftUI

struct PianoMeasurementStep: View {
    @State var leftPosition: SIMD3<Float>? = nil
    @State var rightPosition: SIMD3<Float>? = nil

    @State private var progress = 0.5

    var body: some View {
        VStack {
            Text("Place your left index finger on the lowermost key and your right index finger on the uppermost key.")
                .padding()

            ProgressView(value: progress)
                .padding()

            Text("Hold your fingers until the progress bar fills up.")
                .padding()

            Button("Complete Setup") {
                // Save the positions
            }
            .padding()
            .disabled(progress < 1)

            Spacer()
        }
        .navigationTitle("Piano Measurement")
        .multilineTextAlignment(.center)
        .frame(width: 500, height: 320)
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
                    .font(.title)
                    .padding()
                Text("Let's get started by setting up your piano.")
                    .padding(.bottom, 30)

                NavigationLink("Begin Setup", destination: PianoInformationStep())
            }
            .frame(width: 500, height: 220)
            .padding(20)
        }
    }
}

#Preview {
    SetupWizard()
        .glassBackgroundEffect()
}

#Preview {
    NavigationStack {
        PianoInformationStep()
    }.glassBackgroundEffect()
}

#Preview {
    NavigationStack {
        PianoMeasurementStep()
    }.glassBackgroundEffect()
}
