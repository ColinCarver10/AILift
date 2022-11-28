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
                let pain = event.answer(kind: CheckIn.painItemIdentifier)
                let sleep = event.answer(kind: CheckIn.sleepItemIdentifier)

                view.instructionsLabel.text = """
                    Pain: \(Int(pain))
                    Sleep: \(Int(sleep)) hours
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
            default:
                view.instructionsLabel.text = "Unknown survey type."

            }

        } else {
            view.instructionsLabel.isHidden = true
        }
    }
}
