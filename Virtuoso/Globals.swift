import ARKit
import RealityKit

let propertyListEncoder = PropertyListEncoder()
let propertyListDecoder = PropertyListDecoder()

/// The root entity for entities placed during the game.
let spaceOrigin = Entity()

var fingertips = [HandAnchor.Chirality: [HandSkeleton.JointName: ModelEntity]]()

var pianoAnchor = Entity()

// MARK: Preloaded entities to be reused

var debugAnchorEntity: Entity?
