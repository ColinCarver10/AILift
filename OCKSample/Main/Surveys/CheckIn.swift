//
//  CheckIn.swift
//  OCKSample
//
//  Created by Corey Baker on 11/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
#if canImport(ResearchKit)
import ResearchKit
#endif

struct CheckIn: Surveyable {
    static var surveyType: Survey {
        Survey.checkIn
    }

    static var formIdentifier: String {
        "\(Self.identifier()).form"
    }

    static var recoveryItemIdentifier: String {
        "\(Self.identifier()).form.recovery"
    }

    static var sleepItemIdentifier: String {
        "\(Self.identifier()).form.sleep"
    }

    static var stressItemIdentifier: String {
        "\(Self.identifier()).form.stress"
    }
}

#if canImport(ResearchKit)
extension CheckIn {
    func createSurvey() -> ORKTask {

        let recoveryAnswerFormat = ORKAnswerFormat.scale(
            withMaximumValue: 10,
            minimumValue: 0,
            defaultValue: 0,
            step: 1,
            vertical: false,
            maximumValueDescription: "Very well recovered",
            minimumValueDescription: "Poorly recovered"
        )

        let recoveryItem = ORKFormItem(
            identifier: Self.recoveryItemIdentifier,
            text: "How would you rate your recovery since your last lifting session?",
            answerFormat: recoveryAnswerFormat
        )
        recoveryItem.isOptional = false

        let sleepAnswerFormat = ORKAnswerFormat.scale(
            withMaximumValue: 10,
            minimumValue: 0,
            defaultValue: 0,
            step: 1,
            vertical: false,
            maximumValueDescription: nil,
            minimumValueDescription: nil
        )

        let sleepItem = ORKFormItem(
            identifier: Self.sleepItemIdentifier,
            text: "How was the quality of your sleep last night?",
            answerFormat: sleepAnswerFormat
        )
        sleepItem.isOptional = false

        let stressAnswerFormat = ORKAnswerFormat.scale(
            withMaximumValue: 10,
            minimumValue: 0,
            defaultValue: 0,
            step: 1,
            vertical: false,
            maximumValueDescription: "Very stressed",
            minimumValueDescription: "Not stressed at all"
        )

        let stressItem = ORKFormItem(
            identifier: Self.stressItemIdentifier,
            text: "How would you rate your stress levels?",
            answerFormat: stressAnswerFormat
        )
        stressItem.isOptional = false

        let formStep = ORKFormStep(
            identifier: Self.formIdentifier,
            title: "Check In",
            text: "Please answer the following questions."
        )
        formStep.formItems = [recoveryItem, sleepItem, stressItem]
        formStep.isOptional = false

        let surveyTask = ORKOrderedTask(
            identifier: identifier(),
            steps: [formStep]
        )
        return surveyTask
    }

    func extractAnswers(_ result: ORKTaskResult) -> [OCKOutcomeValue]? {

        guard
            let response = result.results?
                .compactMap({ $0 as? ORKStepResult })
                .first(where: { $0.identifier == Self.formIdentifier }),

            let scaleResults = response
                .results?.compactMap({ $0 as? ORKScaleQuestionResult }),

            let recoveryAnswer = scaleResults
                .first(where: { $0.identifier == Self.recoveryItemIdentifier })?
                .scaleAnswer,

            let sleepAnswer = scaleResults
                .first(where: { $0.identifier == Self.sleepItemIdentifier })?
                .scaleAnswer,

            let stressAnswer = scaleResults
                .first(where: {$0.identifier == Self.stressItemIdentifier })?
                .scaleAnswer
        else {
            assertionFailure("Failed to extract answers from check in survey!")
            return nil
        }

        var recoveryValue = OCKOutcomeValue(Double(truncating: recoveryAnswer))
        recoveryValue.kind = Self.recoveryItemIdentifier

        var sleepValue = OCKOutcomeValue(Double(truncating: sleepAnswer))
        sleepValue.kind = Self.sleepItemIdentifier

        var stressValue = OCKOutcomeValue(Double(truncating: stressAnswer))
        stressValue.kind = Self.stressItemIdentifier

        return [recoveryValue, sleepValue, stressValue]
    }
}
#endif
