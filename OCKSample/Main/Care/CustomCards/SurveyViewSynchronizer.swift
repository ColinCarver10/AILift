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
            /*
             TODO: You need to modify this so the instuction label shows
             correctly for each Task/Card.
             Hint - Each event (OCKAnyEvent) has a task. How can you use
             this task to determine what instruction answers should show?
             Look at how the CareViewController differentiates between
             surveys.
             */
            let pain = event.answer(kind: CheckIn.painItemIdentifier)
            let sleep = event.answer(kind: CheckIn.sleepItemIdentifier)

            view.instructionsLabel.text = """
                Pain: \(Int(pain))
                Sleep: \(Int(sleep)) hours
                """
        } else {
            view.instructionsLabel.isHidden = true
        }
    }
}
