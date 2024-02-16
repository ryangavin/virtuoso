import RealityKit
import RealityKitContent
import SwiftUI

struct PianoRealityView: View {
    var pianoConfiguration: PianoEntity.Configuration = .init()

    @State private var pianoEntity: PianoEntity?

    var body: some View {
        RealityView { content in
            // Create the piano entity in a default state
            let pianoEntity = await PianoEntity(configuration: pianoConfiguration)
            content.add(pianoEntity)

            // Store for later updates
            self.pianoEntity = pianoEntity
        } update: { _ in
            pianoEntity?.update(configuration: pianoConfiguration)
        }
    }
}

#Preview {
    PianoRealityView(pianoConfiguration: PianoEntity.Configuration(
        scale: 0.4,
        position: [0, 0, 0]
    ))
}
