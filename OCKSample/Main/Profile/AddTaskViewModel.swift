//
//  AddTaskViewModel.swift
//  OCKSample
//
//  Created by Colin  Carver  on 10/27/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import SwiftUI
import ParseCareKit
import HealthKit

class AddTaskViewModel: ObservableObject {

    @Published var error: AppError?

    // MARK: Intents

    func addTask(title: String,
                 instructions: String,
                 taskSchedule: Date,
                 selectedAsset: String) async {
        guard let appDelegate = AppDelegateKey.defaultValue else {
            error =  AppError.couldntBeUnwrapped
            return
        }

        let scheduleElement = OCKScheduleElement(start: taskSchedule,
                                                 end: nil,
                                                 interval: DateComponents(day: 1))
        let schedule = OCKSchedule(composing: [scheduleElement])

        var task = OCKTask(id: title,
                                      title: title,
                                      carePlanUUID: nil,
                                      schedule: schedule)
        task.instructions = instructions
        task.asset = selectedAsset

        do {
            try await appDelegate.store?.addTasksIfNotPresent([task])
        } catch {
            // swiftlint:disable:next line_length superfluous_disable_command
            self.error = AppError.errorString("Couldn't add task: \(error.localizedDescription)")
        }
    }

    func addHealthKitTask(title: String,
                          instructions: String,
                          taskSchedule: Date,
                          healthKitTaskType: HKQuantityTypeIdentifier,
                          selectedAsset: String) async {

        guard let appDelegate = AppDelegateKey.defaultValue else {
            error =  AppError.couldntBeUnwrapped
            return
        }

        let schedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: taskSchedule, end: nil, text: nil)

        var healthKitTask = OCKHealthKitTask(id: title,
                                    title: title,
                                    carePlanUUID: nil,
                                    schedule: schedule,
                                    healthKitLinkage: OCKHealthKitLinkage(
                                    quantityIdentifier: healthKitTaskType,
                                    quantityType: .discrete,
                                    unit: .degreeFahrenheit()))

        healthKitTask.instructions = instructions
        healthKitTask.asset = selectedAsset

        switch healthKitTaskType {
        case .vo2Max:
            healthKitTask.healthKitLinkage.quantityType = .discrete
            healthKitTask.healthKitLinkage.unit = HKUnit(from: "ml/kg*min")
        case .stepCount:
            healthKitTask.healthKitLinkage.quantityType = .cumulative
            healthKitTask.healthKitLinkage.unit = .count()
        case .activeEnergyBurned:
            healthKitTask.healthKitLinkage.quantityType = .cumulative
            healthKitTask.healthKitLinkage.unit = .kilocalorie()
        case .heartRate:
            healthKitTask.healthKitLinkage.quantityType = .discrete
            healthKitTask.healthKitLinkage.unit = HKUnit(from: "count/min")
        case .appleExerciseTime:
            healthKitTask.healthKitLinkage.quantityType = .cumulative
            healthKitTask.healthKitLinkage.unit = .minute()
        case .appleSleepingWristTemperature:
            healthKitTask.healthKitLinkage.quantityType = .discrete
            healthKitTask.healthKitLinkage.unit = .degreeFahrenheit()
        default:
            return
        }

        do {
            try await appDelegate.healthKitStore?.addTasksIfNotPresent([healthKitTask])
        } catch {
            // swiftlint:disable:next line_length superfluous_disable_command
            self.error = AppError.errorString("Couldn't add task: \(error.localizedDescription)")
        }
    }

}
