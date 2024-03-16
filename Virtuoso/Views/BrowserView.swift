//
//  BrowserView.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 3/10/24.
//

import SwiftUI

struct BrowserListItem: View {
    @Environment(AppState.self) var appState

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "star")
            Spacer()
            Text("Lesson Title")
                .font(.title3)
            Text("Lesson Subtitle")
                .font(.callout)
        }
        .padding(20)
        .frame(width: 300, height: 200, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct BrowserSection: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .padding(.bottom, 10)
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    BrowserListItem()
                    BrowserListItem()
                    BrowserListItem()
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct BrowserListView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var appStateBindable = appState

        ScrollView {
            BrowserSection(title: "Beginner")
            BrowserSection(title: "Intermediate")
            BrowserSection(title: "Advanced")

            Spacer()
        }
        .navigationTitle("Lessons")
        .padding(25)

        // Popover centered in the middle of the screen
        .sheet(isPresented: $appStateBindable.libraryDetailShown) {
            VStack {
                HStack {
                    Text("Lesson Title")
                        .font(.title)
                    Spacer()
                    Button(action: { appState.libraryDetailShown.toggle() }, label: {
                        Image(systemName: "xmark")
                    })
                }
                Spacer()
            }
            .padding(20)
            .frame(minWidth: 500, minHeight: 300, alignment: .leading)
            .background {
                Image("Placeholder")
                    .resizable()
                    .blur(radius: 50)
            }
        }
    }
}

struct BrowserView: View {
    var body: some View {
        NavigationSplitView {
            List {
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "graduationcap.fill")
                        Text("Lessons")
                    }
                })
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "music.note.list")
                        Text("Songs")
                    }
                })
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "brain.filled.head.profile")
                        Text("Exercises")
                    }
                })
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "chart.bar")
                        Text("Stats")
                    }
                })
                Button(action: {}, label: {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                })
            }.navigationTitle("Virtuoso")
        }
        detail: {
            BrowserListView()
        }
    }
}

#Preview {
    BrowserView().environment(AppState())
}
