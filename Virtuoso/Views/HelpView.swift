//
//  HelpView.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 5/19/24.
//

import SwiftUI

struct AttributionItem: View {
    var title: String
    var url: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Link(url, destination: URL(string: url)!)
        }
    }
}

struct HelpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("About Virtuoso XR")
                .font(.extraLargeTitle2)
                .padding(.bottom, 30)

            // Display licenses for songs
            Text("Songs")
                .font(.title)
                .padding(.bottom, 5)
            Text("All songs are licensed under the Creative Commons license.")
                .font(.body)
                .padding(.bottom, 10)

            List {
                AttributionItem(
                    title: "Itsy Bitsy Spider",
                    url: "https://www.romwell.com/kids/nursery_rhymes/kids_midi.shtml")
                AttributionItem(
                    title: "Farmer in the Dell",
                    url: "https://www.romwell.com/kids/nursery_rhymes/kids_midi.shtml")
                AttributionItem(
                    title: "London Bridge",
                    url: "https://www.romwell.com/kids/nursery_rhymes/kids_midi.shtml")
                AttributionItem(
                    title: "Old MacDonald",
                    url: "https://www.romwell.com/kids/nursery_rhymes/kids_midi.shtml")
                AttributionItem(
                    title: "Für Elise",
                    url: "https://www.mfiles.co.uk/scores/fur-elise.htm")
                AttributionItem(
                    title: "Nocturne Op. 9 No. 2",
                    url: "https://musescore.com/user/6662591/scores/4383881")
            }

            Text("Open Source Libraries")
                .font(.title)
                .padding(.top, 20)

            List {
                AttributionItem(
                    title: "MixedInKey - MIKMIDI",
                    url: "https://github.com/mixedinkey-opensource/MIKMIDI")
                AttributionItem(
                    title: "David Steppenbeck - ObservableUserDefault",
                    url: "https://github.com/davidsteppenbeck/ObservableUserDefault")
            }

            // Dismiss
            Button("Dismiss") {
                dismiss()
            }
        }
        .padding()
        .frame(width: 1000, height: 600)
    }
}

#Preview {
    HelpView()
        .glassBackgroundEffect()
}
