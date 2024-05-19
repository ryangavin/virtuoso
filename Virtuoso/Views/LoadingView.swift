//
//  Loading View.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 4/29/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(2.0)
                .padding()
            Text("Loading...")
                .font(.title)
        }
    }
}

#Preview {
    LoadingView()
}
