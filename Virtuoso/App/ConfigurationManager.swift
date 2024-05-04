//
//  ConfigurationManager.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 5/4/24.
//

import ObservableUserDefault
import SwiftUI

/**
 Manages the user defined configuration settings for the app.

 Ideally no other part of the app should be directly accessing UserDefaults.
 */
@Observable
class ConfigurationManager {
    @ObservableUserDefault(.init(key: "SETUP_WIZARD_COMPLETE", defaultValue: false, store: .standard))
    @ObservationIgnored
    var hasCompletedSetup: Bool
    var setupWizardStep: SetupWizardStep = .dismissed

    var showWelcomeStep: Bool {
        get { return setupWizardStep == .welcome && !hasCompletedSetup }
        set { if newValue {
            hasCompletedSetup = false
            setupWizardStep = .welcome
        } }
    }

    var showPianoInformationStep: Bool {
        get { setupWizardStep == .pianoInformation && !hasCompletedSetup }
        set { if newValue {
            hasCompletedSetup = false
            setupWizardStep = .pianoInformation
        } }
    }

    var showPianoMeasurementStep: Bool {
        get { setupWizardStep == .pianoMeasurement && !hasCompletedSetup }
        set { if newValue {
            hasCompletedSetup = false
            setupWizardStep = .pianoMeasurement
        } }
    }
}
