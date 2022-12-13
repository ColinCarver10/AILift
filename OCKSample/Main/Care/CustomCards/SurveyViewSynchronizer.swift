//
//  SurveyViewSynchronizer.swift
//  OCKSample
//
//  Created by Corey Baker on 11/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import CareKit
import CareKitStore
import CareKitUI
import ResearchKit
import UIKit
import os.log

final class SurveyViewSynchronizer: OCKSurveyTaskViewSynchronizer {
    // swiftlint:disable:next cyclomatic_complexity
    override func updateView(
        _ view: OCKInstructionsTaskView,
        context: OCKSynchronizationContext<OCKTaskEvents>) {

        super.updateView(view, context: context)

        if let event = context.viewModel.first?.first, event.outcome != nil {
            view.instructionsLabel.isHidden = false

            guard let surveyTask = event.task as? OCKTask else {
                Logger.feed.error("Can't read task.")
                return
            }

            let surveyTaskType = surveyTask.survey.type().identifier()

            switch surveyTaskType {
            case "check in":
                let pain = event.answer(kind: CheckIn.recoveryItemIdentifier)
                let sleep = event.answer(kind: CheckIn.sleepItemIdentifier)
                let stress = event.answer(kind: CheckIn.stressItemIdentifier)

                view.instructionsLabel.text = """
                    Recovery: \(Int(pain))
                    Sleep: \(Int(sleep))
                    Stress: \(Int(stress))
                    """
            case "range of motion":
                let range = event.answer(kind: RangeOfMotion.rangeIdentifier)

                view.instructionsLabel.text = """
                    Range of motion: \(Int(range))
                    """
            case "onboard":
                view.instructionsLabel.text = """
                    Please complete to begin using the application.
                    """
            case "workout setup":
                let workoutType = event.outcome?.answerString(kind: WorkoutSetup.workoutTypeIdentifier).first
                let benchMax = event.answer(kind: WorkoutSetup.benchMaxIdentifier)
                let squatMax = event.answer(kind: WorkoutSetup.squatMaxIdentifier)
                let deadliftMax = event.answer(kind: WorkoutSetup.deadliftMaxIdentifier)
                let snatchMax = event.answer(kind: WorkoutSetup.snatchMaxIdentifier)
                let cleanMax = event.answer(kind: WorkoutSetup.cleanMaxIdentifier)

                // Automatically update the workoutType for the user.
                Task {
                    guard let uuid = try? Utility.getRemoteClockUUID() else {
                        Logger.profile.error("Could not get remote uuid for this user.")
                        return
                    }

                    var queryForCurrentPatient = OCKPatientQuery(for: Date())
                    // This makes the query for the current version of Patient
                    queryForCurrentPatient.ids = [uuid.uuidString] // Search for the current logged in user

                    // Fetch Current Patient
                    guard let appDelegate = AppDelegateKey.defaultValue,
                          let foundPatient = try await appDelegate.store?.fetchPatients(query: queryForCurrentPatient),
                          var currentPatient = foundPatient.first else {
                        // swiftlint:disable:next line_length
                        Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved.")
                        return
                    }

                    // Set type
                    switch workoutType {
                    case "Body Building":
                        currentPatient.workoutType = .bodybuilding
                    case "Weight Lifting":
                        currentPatient.workoutType = .weightlifting
                    case "Power Lifting":
                        currentPatient.workoutType = .powerlifting
                    default:
                        currentPatient.workoutType = .bodybuilding
                    }

                    // Update Patient
                    _ = try await appDelegate.store?.updatePatient(currentPatient)

                }
                  view.instructionsLabel.text = """
                    Workout type: \(workoutType ?? "Body Building")
                    Bench Max: \(Int(benchMax))
                    Squat Max: \(Int(squatMax))
                    Deadlift Max: \(Int(deadliftMax))
                    Snatch Max: \(Int(snatchMax))
                    Clean Max: \(Int(cleanMax))
                    """
            default:
                view.instructionsLabel.text = "Unknown survey type."

            }

        } else {
            view.instructionsLabel.isHidden = true
        }
    }
}
