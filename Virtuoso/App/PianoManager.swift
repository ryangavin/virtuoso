//
//  PianoModel.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 2/23/24.
//

import ARKit
import MIKMIDI
import RealityKit
import RealityKitContent
import SwiftUI

@Observable
class PianoManager {
    // MARK: Piano Configuration

    // Anchors to capture the intial positions in the world space
    private var leftAnchor: Entity
    private var rightAnchor: Entity

    // Collision bar for the notes to hit
    private var collisionBar = Entity()

    // The anchors for the actual piano keys
    private var keys: [Entity] = []

    // The notes drawn from the sequence
    private var notes: [MIKMIDINoteEvent: Entity] = [:]

    // The main anchor for the notes
    private var noteAnchor = Entity()

    var numberOfKeys: Int = 73

    private let NUMBER_OF_WHITE_KEYS = [
        73: 43
    ]
    private let STARTING_KEYS = [
        73: "E"
    ]
    private let STARTING_MIDI_NOTE = [
        73: 28
    ]

    private let NOTE_NAMES = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]

    init() {
        leftAnchor = Entity.createDebugEntity()
        rightAnchor = Entity.createDebugEntity()

        pianoAnchor.addChild(leftAnchor)
        pianoAnchor.addChild(rightAnchor)
        pianoAnchor.addChild(noteAnchor)

        // TODO: this will need to be more dynamic to handle changes to number of keys
        createKeyAnchors()

        // Load the saved positions
        // TODO: there is a new macro to clean this up
        if let leftPosition = UserDefaults.standard.value(forKey: "leftAnchorSavedPosition") as? Data,
           let rightPosition = UserDefaults.standard.value(forKey: "rightAnchorSavedPosition") as? Data
        {
            let leftPositionData = try? propertyListDecoder.decode(SIMD3<Float>.self, from: leftPosition)
            let rightPositionData = try? propertyListDecoder.decode(SIMD3<Float>.self, from: rightPosition)
            repositionAnchors(leftPosition: leftPositionData!, rightPosition: rightPositionData!)
        }
        else {
            repositionAnchors(leftPosition: [-0.4, 0.9, -0.3], rightPosition: [0.4, 0.9, -0.3])
        }
    }

    func moveAnchor(translation: SIMD3<Float>) {
        pianoAnchor.setPosition(translation, relativeTo: pianoAnchor)
    }

    func rotateAnchor(offset: Float) {
        pianoAnchor.transform.rotation *= simd_quatf(angle: offset, axis: [0, 1, 0])
    }

    func stretchAnchor(stretchFactor: Float) {
        // Move the left and right anchors a bit, and then redraw the keyboard
        leftAnchor.setPosition([-stretchFactor, 0, 0], relativeTo: leftAnchor)
        rightAnchor.setPosition([stretchFactor, 0, 0], relativeTo: rightAnchor)
        redrawKeys()
    }

    func captureIndexFingerPosition(chirality: HandAnchor.Chirality) -> SIMD3<Float> {
        let fingerTip = fingertips[chirality]![.indexFingerTip]!
        let measuredPosition = fingerTip.position

        var leftPosition = chirality == .left ? measuredPosition : leftAnchor.position(relativeTo: spaceOrigin)
        var rightPosition = chirality == .right ? measuredPosition : rightAnchor.position(relativeTo: spaceOrigin)

        // Keep the height the same, using the height of the last selected anchor
        if chirality == .left {
            rightPosition.y = leftPosition.y
        }
        else {
            leftPosition.y = rightPosition.y
        }

        let leftPositionData = try? propertyListEncoder.encode(leftPosition)
        let rightPositionData = try? propertyListEncoder.encode(rightPosition)

        UserDefaults.standard.set(leftPositionData, forKey: "leftAnchorSavedPosition")
        UserDefaults.standard.set(rightPositionData, forKey: "rightAnchorSavedPosition")

        repositionAnchors(leftPosition: leftPosition, rightPosition: rightPosition)

        return chirality == .left ? leftPosition : rightPosition
    }

    func repositionAnchors(leftPosition: SIMD3<Float>, rightPosition: SIMD3<Float>) {
        // Angle between ignoring the y axis
        let angleBetween = atan2(leftPosition.z - rightPosition.z, leftPosition.x - rightPosition.x) - .pi

        // Move the center to the new position
        let center = (leftPosition + rightPosition) / 2
        pianoAnchor.setPosition(center, relativeTo: spaceOrigin)

        // Rotate the center so orientation is perpendicular to the line between the left and right anchors
        pianoAnchor.transform.rotation = simd_quatf(angle: angleBetween, axis: [0, -1, 0])

        // Now that we have factored in the roll of the center anchor,
        // we can set the left and right anchors to be the same height.
        let width = simd_length(leftPosition - rightPosition)

        // The left and right positions should end up the same in world space
        // But now everything is centered to the center anchor
        leftAnchor.position = [-width / 2, 0, 0]
        rightAnchor.position = [width / 2, 0, 0]

        redrawKeys()
        reconfigureMaterials()
    }

    func reconfigureMaterials() {
        let value = MaterialParameters.Value.float(collisionBar.position(relativeTo: spaceOrigin).z)
        try! collisionMaterial?.setParameter(name: "WorldClipThreshold", value: value)
    }

    private func createKeyAnchors() {
        // Remove the old entities
        // TODO: don't recreate the entities every time, just move them
        // TODO: only change the entities when we change the number of keys
        for key in keys {
            key.removeFromParent()
        }
        keys.removeAll()

        // TODO: move this into a hash of MIDI note number to entity
        for _ in 0 ..< numberOfKeys {
            let key = Entity.createDebugEntity()
            key.components[OpacityComponent.self] = .init(opacity: 0.0)
            keys.append(key)
            pianoAnchor.addChild(key)
        }
    }

    func setKeyAnchorVisiblity(_ visible: Bool) {
        for key in keys {
            key.components[OpacityComponent.self] = .init(opacity: visible ? 1 : 0.0)
        }
    }

    private func keyWidth() -> Float {
        return simd_length(rightAnchor.position - leftAnchor.position) / Float(NUMBER_OF_WHITE_KEYS[numberOfKeys]!)
    }

    private func redrawKeys() {
        let noteIndex = NOTE_NAMES.firstIndex(of: STARTING_KEYS[numberOfKeys]!)!

        // Spread all the white keys evenly between the two anchors
        // We are measuring the number of gaps between keys, not the number of keys
        // This is why it's -1 in the calculation
        // This is a vector from the left anchor to the right anchor
        //
        // Without the -1, we can get the actual key width
        //
        // Both of these values are controlled by adjusting the anchors in the configuration menu
        // TODO: whiteKeySpacing can be refactored to only use the x axis because the piano is flat
        // TODO: the current implementation may be introducing slight placement rounding errors
        let whiteKeySpacing = (rightAnchor.position - leftAnchor.position) / Float(NUMBER_OF_WHITE_KEYS[numberOfKeys]! - 1)
        let keyWidth = keyWidth()
        let pianoWidth = keyWidth * Float(NUMBER_OF_WHITE_KEYS[numberOfKeys]!)

        // The key width can be used to figure out the key height, which is about 6 times the width
        // Not sure if this holds up on micro keyboards
        // TODO: make this adjustable in the configuration menu
        let keyHeight = keyWidth * 6

        // Keep track of the last white key so we can offset black keys from it
        var lastWhiteKeyPosition = leftAnchor.position
        var whiteKeyCount = 0

        for i in 0 ..< numberOfKeys {
            let keyAnchor = keys[i]
            let noteName = NOTE_NAMES[(i + noteIndex) % NOTE_NAMES.count]

            // White keys
            if !noteName.accidentalNote() {
                let position = leftAnchor.position + whiteKeySpacing * Float(whiteKeyCount)
                lastWhiteKeyPosition = position
                keyAnchor.position = position
                whiteKeyCount += 1
            }

            // Black Keys
            else {
                // For now just put the black key half way between the two white keys
                // In real life the spread is a little wider than that.
                // In the cluster of 3, the middle note is directly in the center of the two white keys
                // In the cluster of 2, each is slightly offset from the center of their respective white keys
                var blackKeyPosition = lastWhiteKeyPosition + whiteKeySpacing / 2

                // Set the black key back and up
                // TODO: this should be expressed as a ratio that uses the width of the white key and the number of keys
                // TODO: this way on a shorter scale keyboard, it will still be correct
                // TODO: the black key is always 2/3 of the size of the white key
                // TODO: we also need to derive the height of the white key
                blackKeyPosition.z -= 0.07
                blackKeyPosition.y += 0.01
                keyAnchor.position = blackKeyPosition
            }
        }

        // Redraw the collison bar with the correct width
        collisionBar.removeFromParent()
        collisionBar = createCollisionBarEntity(width: pianoWidth, offset: keyHeight)
        pianoAnchor.addChild(collisionBar)

        // The note anchor is the parent for all the notes
        // It has the same origin as the collision bar, but it's not parented to the collision bar
        // This is because we have to replace the bar from time to time
        noteAnchor.setPosition([0.0, 0.0, 0.0], relativeTo: collisionBar)
    }

    @MainActor
    func clearTrack() {
        for (_, entity) in notes {
            entity.removeFromParent()
        }
        notes.removeAll()
    }

    @MainActor
    func drawTrack(track: MIKMIDITrack, targetTimestamp: MusicTimeStamp, color: UIColor) {
        // Figure out which notes in the sequence we need to draw
        // We want to see 16 bars ahead, as well as whatever is currently playing (4 bars behind)
        var fromTimeStamp = targetTimestamp - 4
        if fromTimeStamp < 0 {
            fromTimeStamp = 0
        }
        let trackNotes = track.notes(fromTimeStamp: fromTimeStamp, toTimeStamp: targetTimestamp + 16)

        // Pre compute note widths for creating new notes
        // TODO: adjust the widths by some percantage based padding so they don't overlap
        let whiteNoteWidth = keyWidth() * 0.8
        let blackNoteWidth = whiteNoteWidth * (2 / 3) * 0.8

        var notesSeen = [Entity]()
        for trackNote in trackNotes {
            let noteIndex = Int(trackNote.note) - STARTING_MIDI_NOTE[numberOfKeys]!

            // Skip notes that are out of range
            if noteIndex < 0 || noteIndex >= keys.count {
                continue
            }

            // Track depth up front so it can be used to create the note if necessary
            // It will get used again later to offset the positions of the notes further
            // This is because the center of the note is the anchor point
            // So we need to move things by the depth/2 to get the notes to line up
            let depth = trackNote.duration / 10

            // TODO: adding these entities is expensive, we should add them in an async task
            // TODO: they won't be available in this draw cycle, but they'll be available shortly
            if notes[trackNote] == nil {
                let noteWidth = trackNote.noteLetter.accidentalNote() ? blackNoteWidth : whiteNoteWidth
                let noteEntity = createNoteEntity(depth: depth, width: noteWidth, note: trackNote.noteLetter, color: color)
                notes[trackNote] = noteEntity
                noteAnchor.addChild(noteEntity)
            }

            let noteEntity = notes[trackNote]!

            // Position the note above the right key
            // Get the key position relative to the main anchor
            // TODO: this calculation is probably expensive to do every time
            // TODO: we should have a chache of x offsets
            let keyAnchorPosition = keys[noteIndex].position(relativeTo: noteAnchor)

            // Move the note anchor relative to the main anchor
            let durationOffset = Float(trackNote.timeStamp - targetTimestamp) / 10
            let zOffset = durationOffset + (depth / 2)
            let targetPosition = SIMD3<Float>(keyAnchorPosition.x, 0, -zOffset)
            noteEntity.setPosition(targetPosition, relativeTo: noteAnchor)

            notesSeen.append(noteEntity)
        }

        // Remove any entities that we haven't seen
        for note in notes {
            // TODO: make sure not to remove anything that's still playing
            if note.key.timeStamp + Double(note.key.duration) < targetTimestamp, !notesSeen.contains(note.value) {
                note.value.removeFromParent()
                notes.removeValue(forKey: note.key)
            }
        }
    }

    private func createCollisionBarEntity(width: Float, offset: Float) -> Entity {
        // The mesh for the visual bar and it's material
        let box = MeshResource.generateBox(width: width, height: 0.01, depth: 0.01, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .systemGray6, isMetallic: false)

        // Main visual bar entity
        let entity = ModelEntity(mesh: box, materials: [material])
        entity.components[GroundingShadowComponent.self] = GroundingShadowComponent(castsShadow: true)
        entity.position = [0, 0.01, -offset]

        return entity
    }

    private func createNoteEntity(depth: Float, width: Float, note: String, color: UIColor) -> Entity {
        // Generate the main note model, a colored box with slight corner radius
        let box = MeshResource.generateBox(width: width, height: 0.01, depth: depth, cornerRadius: 0.001)

        // Build up the actual entity - attaching the materials and the mesh
        // Also attach a GroundingShadowComponent so the notes cast shadows
        let material = SimpleMaterial(color: .systemBlue, isMetallic: false)
        let entity = ModelEntity(mesh: box, materials: [material])
        entity.components[GroundingShadowComponent.self] = GroundingShadowComponent(castsShadow: true)

        // Set the note name
        let textMesh = MeshResource.generateText(note, extrusionDepth: 0.005, font: .boldSystemFont(ofSize: 0.007))
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])

        // Position the text above the note towards the front of the note
        textEntity.position = [textMesh.bounds.max.x / -2, 0.004, (depth / 2) - 0.004]

        // rotate 90 degress up
        textEntity.transform.rotation = simd_quatf(angle: .pi / -2, axis: [1, 0, 0])

        // Anchor to the note
        entity.addChild(textEntity)

        return entity
    }
}
