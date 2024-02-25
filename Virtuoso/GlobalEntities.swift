import ARKit
import RealityKit

/// The root entity for entities placed during the game.
let spaceOrigin = Entity()

var fingertips = [HandAnchor.Chirality: [HandSkeleton.JointName: ModelEntity]]()
