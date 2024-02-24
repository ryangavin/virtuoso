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

    // Constants
    let supportedKeys = [25, 37, 49, 73, 88]
    let notes = ["C", "Db", "D", "Eb", "E", "F", "G", "Ab", "A", "Bb", "B"]

    var body: some View {
        VStack {
            Text("Piano Configuration")
                .font(.title)

            Form {
                Picker("Number of Keys", selection: $model.numberOfKeys) {
                    ForEach(supportedKeys, id: \.self) { key in
                        Text("\(key)")
                    }
                }
            }.scrollDisabled(true)

            HStack {
                Button(action: /*@START_MENU_TOKEN@*/ {}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                })
                Button(action: /*@START_MENU_TOKEN@*/ {}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
                Button(action: {
                    model.moveAway()
                }, label: {
                    Image(systemName: "arrowshape.up.fill")
                })
                Button(action: /*@START_MENU_TOKEN@*/ {}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "arrow.clockwise")
                })
            }
            HStack {
                Button("X") {}
                    .tint(.red)
                Button(action: {
                    model.moveLeft()
                }, label: {
                    Image(systemName: "arrowshape.left.fill")
                })
                Button(action: /*@START_MENU_TOKEN@*/ {}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "tortoise.fill")
                })
                Button(action: {
                    model.moveRight()
                }, label: {
                    Image(systemName: "arrowshape.right.fill")
                })
            }
            HStack {
                Button(action: {}, label: {
                    Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                })
                Button(action: {
                    model.moveUp()
                }, label: {
                    Image(systemName: "square.3.layers.3d.top.filled")
                })
                Button(action: {
                    model.moveClose()
                }, label: {
                    Image(systemName: "arrowshape.down.fill")
                })
                Button(action: {
                    model.moveDown()
                }, label: {
                    Image(systemName: "square.3.layers.3d.bottom.filled")
                })
            }

        }.padding()
    }
}

#Preview(windowStyle: .automatic) {
    PianoConfigurationMenu(model: AppModel())
}
