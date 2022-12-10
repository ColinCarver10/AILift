//
//  Onboarding.swift
//  OCKSample
//
//  Created by Corey Baker on 11/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
#if canImport(ResearchKit)
import ResearchKit
#endif

struct Onboard: Surveyable {
    static var surveyType: Survey {
        Survey.onboard
    }
}

#if canImport(ResearchKit)
extension Onboard {
    func createSurvey() -> ORKTask {
        // The Welcome Instruction step.
        let welcomeInstructionStep = ORKInstructionStep(
            identifier: "\(identifier()).welcome"
        )

        welcomeInstructionStep.title = "Welcome to AI Lifting!"
        welcomeInstructionStep.detailText = "Thank you for joining AI Lifting. Tap Next to start your set up."
        welcomeInstructionStep.image = UIImage(named: "welcome-image")
        welcomeInstructionStep.imageContentMode = .scaleAspectFill

        // The Informed Consent Instruction step.
        let studyOverviewInstructionStep = ORKInstructionStep(
            identifier: "\(identifier()).overview"
        )

        studyOverviewInstructionStep.title = "Set Up"
        studyOverviewInstructionStep.iconImage = UIImage(systemName: "figure.run")

        let heartBodyItem = ORKBodyItem(
            text: "AI Lifting will ask you to share some of your health data.",
            detailText: nil,
            image: UIImage(systemName: "heart.fill"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )

        let completeTasksBodyItem = ORKBodyItem(
            text: "These tasks will personalize your workout plan to best fit your needs.",
            detailText: nil,
            image: UIImage(systemName: "slider.vertical.3"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )

        let signatureBodyItem = ORKBodyItem(
            text: "Before joining, we will ask you to sign an informed consent document.",
            detailText: nil,
            image: UIImage(systemName: "signature"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )

        let secureDataBodyItem = ORKBodyItem(
            text: "Your data is kept private and secure.",
            detailText: nil,
            image: UIImage(systemName: "lock.fill"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )

        studyOverviewInstructionStep.bodyItems = [
            heartBodyItem,
            completeTasksBodyItem,
            signatureBodyItem,
            secureDataBodyItem
        ]

        // The Signature step (using WebView).
        let webViewStep = ORKWebViewStep(
            identifier: "\(identifier()).signatureCapture",
            html: informedConsentHTML
        )

        webViewStep.showSignatureAfterContent = true

        let healthKitTypesToWrite: Set<HKSampleType> = [
            .quantityType(forIdentifier: .bodyMassIndex)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            .workoutType()
        ]

        let healthKitTypesToRead: Set<HKObjectType> = [
            .characteristicType(forIdentifier: .dateOfBirth)!,
            .workoutType(),
            .quantityType(forIdentifier: .appleStandTime)!,
            .quantityType(forIdentifier: .appleExerciseTime)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]

        let healthKitPermissionType = ORKHealthKitPermissionType(
            sampleTypesToWrite: healthKitTypesToWrite,
            objectTypesToRead: healthKitTypesToRead
        )

        let notificationsPermissionType = ORKNotificationPermissionType(
            authorizationOptions: [.alert, .badge, .sound]
        )

        let motionPermissionType = ORKMotionActivityPermissionType()

        let requestPermissionsStep = ORKRequestPermissionsStep(
            identifier: "\(identifier()).requestPermissionsStep",
            permissionTypes: [
                healthKitPermissionType,
                notificationsPermissionType,
                motionPermissionType
            ]
        )

        requestPermissionsStep.title = "Health Data Request"
        requestPermissionsStep.text = "Please review the health data types below and enable sharing."

        // Completion Step
        let completionStep = ORKCompletionStep(
            identifier: "\(identifier()).completionStep"
        )

        completionStep.title = "Enrollment Complete"
        completionStep.text = "Thank you for joining AI Lifting. Your customized workout plan awaits you."

        let surveyTask = ORKOrderedTask(
            identifier: identifier(),
            steps: [
                welcomeInstructionStep,
                studyOverviewInstructionStep,
                webViewStep,
                requestPermissionsStep,
                completionStep
            ]
        )
        return surveyTask
    }

    func extractAnswers(_ result: ORKTaskResult) -> [CareKitStore.OCKOutcomeValue]? {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Utility.requestHealthKitPermissions()
        }
        return [OCKOutcomeValue(Date())]
    }
}
#endif
