//
//  ConfigurationManager.swift
//  Virtuoso
//
//  Created by Ryan Gavin on 5/4/24.
//

import ObservableUserDefault
import SwiftUI

@Observable
class ConfigurationManager {
    @ObservableUserDefault(.init(key: "HAS_COMPLETED_SETUP", defaultValue: false, store: .standard))
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
            setupWizardStep = .welcome
        } }
    }

    var showPianoMeasurementStep: Bool {
        get { setupWizardStep == .pianoMeasurement && !hasCompletedSetup }
        set { if newValue {
            hasCompletedSetup = false
            setupWizardStep = .welcome
        } }
    }
}
