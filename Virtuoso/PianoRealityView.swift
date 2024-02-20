import RealityKit
import RealityKitContent
import SwiftUI

/// A view that manages all the entities for the piano experience
/// World interactions are managed here and updates are passed down to the entities
struct PianoRealityView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        RealityView { content in
            content.add(spaceOrigin)
        }

        // MARK: Respond to changes in the model

        update: { _ in
            if model.shouldShowConfigurtionAnchors {
                print("Adding anchors")
                spaceOrigin.addChild(leftAnchor)
                spaceOrigin.addChild(rightAnchor)
            } else {
                print("Removing anchors")
                // Remove both anchors so they aren't being rendered
                leftAnchor.removeFromParent()
                rightAnchor.removeFromParent()
            }
        }

        .task {
            await model.startARKitSession()
        }

        // MARK: Gesture for the configuration anchors

        .gesture(DragGesture(minimumDistance: 0.0)
            .targetedToAnyEntity()
            .onChanged { @MainActor drag in
                let entity = drag.entity
                guard entity[parentMatching: "Anchor"] != nil else { return }

                // TODO: This is somewhat incomplete but it's working enough to demonstrate
                entity.position = drag.convert(drag.translation3D, from: .local, to: spaceOrigin)

                print("Dragging Anchor")
            })
    }
}
