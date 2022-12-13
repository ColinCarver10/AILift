//
//  WorkoutSetup.swift
//  OCKSample
//
//  Created by Colin  Carver  on 12/9/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
#if canImport(ResearchKit)
import ResearchKit
#endif

struct WorkoutSetup: Surveyable {
    static var surveyType: Survey {
        Survey.workoutSetup
    }

    static var workoutTypeIdentifier: String {
        "\(Self.identifier()).workoutPlanStep"
    }

    static var maxFormIdentifier: String {
        "\(Self.identifier()).form.max"
    }

    static var benchMaxIdentifier: String {
        "\(Self.identifier()).benchMax"
    }

    static var deadliftMaxIdentifier: String {
        "\(Self.identifier()).deadliftMax"
    }

    static var squatMaxIdentifier: String {
        "\(Self.identifier()).squatMax"
    }

    static var cleanMaxIdentifier: String {
        "\(Self.identifier()).cleanMax"
    }

    static var snatchMaxIdentifier: String {
        "\(Self.identifier()).snatchMax"
    }

}

#if canImport(ResearchKit)
extension WorkoutSetup {
    // Select Workout Plan Step
    func createSurvey() -> ORKTask {
        let textChoices = [
                    ORKTextChoice(text: "Body Building", value: "Body Building" as NSString),
                    ORKTextChoice(text: "Power Lifting", value: "Power Lifting" as NSString),
                    ORKTextChoice(text: "Weight Lifting", value: "Weight Lifting" as NSString)
                ]

        let answerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)

        let workoutPlanStep = ORKQuestionStep(
            identifier: Self.workoutTypeIdentifier,
            title: "Workout Type",
            question: "What type of workouts will you be doing?",
            answer: answerFormat
        )

        workoutPlanStep.isOptional = false

        // Enter maxes
        let maxAnswerFormat = ORKAnswerFormat.integerAnswerFormat(withUnit: "lbs")

        let benchMax = ORKFormItem(identifier: Self.benchMaxIdentifier,
                                   text: "What is your bench max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: false)

        let squatMax = ORKFormItem(identifier: Self.squatMaxIdentifier,
                                   text: "What is your squat max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: false)

        let deadliftMax = ORKFormItem(identifier: Self.deadliftMaxIdentifier,
                                   text: "What is your deadlift max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: false)

        let snatchMax = ORKFormItem(identifier: Self.snatchMaxIdentifier,
                                   text: "What is your snatch max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: false)

        let cleanMax = ORKFormItem(identifier: Self.cleanMaxIdentifier,
                                   text: "What is your clean max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: false)

        let maxFormStep = ORKFormStep(
            identifier: Self.maxFormIdentifier,
            title: "Maxes",
            text: "Please input your maxes."
        )

        maxFormStep.formItems = [benchMax, squatMax, deadliftMax, snatchMax, cleanMax]
        maxFormStep.isOptional = false

        let surveyTask = ORKOrderedTask(
            identifier: identifier(),
            steps: [
                workoutPlanStep,
                maxFormStep
            ]
        )
        return surveyTask

    }

    func extractAnswers(_ result: ORKTaskResult) -> [OCKOutcomeValue]? {
        guard
            let typeResponse = result.results?
                .compactMap({ $0 as? ORKStepResult })
                .first(where: { $0.identifier == Self.workoutTypeIdentifier }),

            let typeResults = typeResponse
                .results?.compactMap({ $0 as? ORKChoiceQuestionResult })
                .first?
                .choiceAnswers?
                .first as? String,

            let maxResponses = result.results?
                .compactMap({ $0 as? ORKStepResult })
                .first(where: { $0.identifier == Self.maxFormIdentifier }),

            let scaleResults = maxResponses
                .results?.compactMap({ $0 as? ORKNumericQuestionResult }),

            let benchMaxAnswer = scaleResults
                .first(where: { $0.identifier == Self.benchMaxIdentifier })?
                .numericAnswer,

            let squatMaxAnswer = scaleResults
                .first(where: { $0.identifier == Self.squatMaxIdentifier })?
                .numericAnswer,

            let deadliftMaxAnswer = scaleResults
                .first(where: { $0.identifier == Self.deadliftMaxIdentifier })?
                .numericAnswer,

            let cleanMaxAnswer = scaleResults
                .first(where: { $0.identifier == Self.cleanMaxIdentifier })?
                .numericAnswer,

            let snatchMaxAnswer = scaleResults
                .first(where: { $0.identifier == Self.snatchMaxIdentifier })?
                .numericAnswer
        else {
            assertionFailure("Failed to extract answers from check in survey!")
            return nil
        }

        var type = OCKOutcomeValue(typeResults)
        type.kind = Self.workoutTypeIdentifier

        var benchMax = OCKOutcomeValue(Double(truncating: benchMaxAnswer))
        benchMax.kind = Self.benchMaxIdentifier

        var squatMax = OCKOutcomeValue(Double(truncating: squatMaxAnswer))
        squatMax.kind = Self.squatMaxIdentifier

        var deadliftMax = OCKOutcomeValue(Double(truncating: deadliftMaxAnswer))
        deadliftMax.kind = Self.deadliftMaxIdentifier

        var cleanMax = OCKOutcomeValue(Double(truncating: cleanMaxAnswer))
        cleanMax.kind = Self.cleanMaxIdentifier

        var snatchMax = OCKOutcomeValue(Double(truncating: snatchMaxAnswer))
        snatchMax.kind = Self.snatchMaxIdentifier

        Constants.workoutSetupCompleted = true

        return [type, benchMax, squatMax, deadliftMax, cleanMax, snatchMax]
    }

}
#endif
