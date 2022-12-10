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
                    ORKTextChoice(text: "Body Building", value: "bodybuilding" as NSString),
                    ORKTextChoice(text: "Power Lifting", value: "powerlifting" as NSString),
                    ORKTextChoice(text: "Weight Lifting", value: "weightlifting" as NSString)
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
        let maxAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: .local)

        let benchMax = ORKFormItem(identifier: Self.benchMaxIdentifier,
                                   text: "What is your bench max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: true)

        let squatMax = ORKFormItem(identifier: Self.squatMaxIdentifier,
                                   text: "What is your squat max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: true)

        let deadliftMax = ORKFormItem(identifier: Self.deadliftMaxIdentifier,
                                   text: "What is your deadlift max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: true)

        let snatchMax = ORKFormItem(identifier: Self.snatchMaxIdentifier,
                                   text: "What is your snatch max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: true)

        let cleanMax = ORKFormItem(identifier: Self.cleanMaxIdentifier,
                                   text: "What is your clean max?",
                                   answerFormat: maxAnswerFormat,
                                   optional: true)

        let maxFormStep = ORKFormStep(
            identifier: Self.maxFormIdentifier,
            title: "Maxes",
            text: "Please input your applicable maxes. Leave blank if unknown."
        )

        maxFormStep.formItems = [benchMax, squatMax, deadliftMax, snatchMax, cleanMax]
        maxFormStep.isOptional = true

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
        // Need to figure out how to extract the answer.
        guard
            let response = result.results?
                .compactMap({ $0 as? ORKStepResult })
                .first(where: { $0.identifier == Self.workoutTypeIdentifier }),
            let workoutAnswer = response
                    .results?.compactMap({ $0 as? NSString })

        else {
            assertionFailure("Failed to extract answers from check in survey!")
            return nil
        }

        // var workoutType = OCKOutcomeValue(workoutAnswer)
        return [OCKOutcomeValue(String())]
    }

}
#endif
