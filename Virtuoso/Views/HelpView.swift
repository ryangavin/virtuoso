//
//  HelpView.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 5/19/24.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Welcome to Virtuoso!")
                .font(.extraLargeTitle2)
                .padding(.bottom, 30)

            // Display licenses for songs
            Text("All songs are licensed under the Creative Commons license.")
                .font(.body)
                .padding(.bottom, 10)
            
            // Dismiss
            Button("Dismiss") {
                dismiss()
            }
            
        }
        .padding()
    }
}

#Preview {
    HelpView()
        .glassBackgroundEffect()
}
