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
import OSLog

class AddTaskViewModel: ObservableObject {

    @Published var error: AppError?
    @Published var taskSchedule = Date()
    @Published var title: String = ""
    @Published var instructions: String = ""
    @Published var selectedCard: CareKitCard = .button

    @Published var healthKitTaskType: HKQuantityTypeIdentifier = .appleSleepingWristTemperature

    @Published var selectedAsset: String = "figure.walk"

    @Published var selectedDay: Int = 1

    // MARK: Intents

    func addTask() async {
        guard let appDelegate = AppDelegateKey.defaultValue else {
            error =  AppError.couldntBeUnwrapped
            return
        }

        let calendar = Calendar(identifier: .gregorian)
        let dayComponent = DateComponents(weekday: selectedDay)

        guard let nextDay = calendar.nextDate(after: Date().dayBefore,
                                        matching: dayComponent,
                                              matchingPolicy: .nextTimePreservingSmallerComponents) else {
            Logger.task.error("Couldn't unwrap time.")
            return
        }

        let weeklyAtDay = OCKScheduleElement(start: nextDay,
                                             end: nil,
                                             interval: DateComponents(weekOfYear: 1))
        let schedule = OCKSchedule(composing: [weeklyAtDay])

        var task = OCKTask(id: title,
                                      title: title,
                                      carePlanUUID: nil,
                                      schedule: schedule)
        task.instructions = instructions
        task.asset = selectedAsset
        task.card = selectedCard

        do {
            try await appDelegate.store?.addTasksIfNotPresent([task])
            // Notify views they should refresh tasks if needed
            NotificationCenter.default.post(.init(name: Notification.Name(rawValue: Constants.shouldRefreshView)))
        } catch {
            // swiftlint:disable:next line_length superfluous_disable_command
            self.error = AppError.errorString("Couldn't add task: \(error.localizedDescription)")
        }
    }

    func addHealthKitTask() async {

        guard let appDelegate = AppDelegateKey.defaultValue else {
            error =  AppError.couldntBeUnwrapped
            return
        }

        let calendar = Calendar(identifier: .gregorian)
        let dayComponent = DateComponents(weekday: selectedDay)

        guard let nextDay = calendar.nextDate(after: Date().dayBefore,
                                        matching: dayComponent,
                                              matchingPolicy: .nextTimePreservingSmallerComponents) else {
            Logger.task.error("Couldn't unwrap time.")
            return
        }

        let weeklyAtDay = OCKScheduleElement(start: nextDay,
                                             end: nil,
                                             interval: DateComponents(weekOfYear: 1))
        let schedule = OCKSchedule(composing: [weeklyAtDay])

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
        healthKitTask.card = selectedCard

        switch healthKitTaskType {
        case .stepCount:
            healthKitTask.healthKitLinkage.quantityType = .cumulative
            healthKitTask.healthKitLinkage.unit = .count()
        case .activeEnergyBurned:
            healthKitTask.healthKitLinkage.quantityType = .cumulative
            healthKitTask.healthKitLinkage.unit = .kilocalorie()
        case .heartRateVariabilitySDNN:
            healthKitTask.healthKitLinkage.quantityType = .discrete
            healthKitTask.healthKitLinkage.unit = .secondUnit(with: .milli)
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
            // Notify views they should refresh tasks if needed
            NotificationCenter.default.post(.init(name: Notification.Name(rawValue: Constants.shouldRefreshView)))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(.init(name: Notification.Name(rawValue: Constants.requestSync)))
                Utility.requestHealthKitPermissions()
            }
        } catch {
            // swiftlint:disable:next line_length superfluous_disable_command
            self.error = AppError.errorString("Couldn't add task: \(error.localizedDescription)")
        }
    }

}
