//
//  OCKHealthKitPassthroughStore.swift
//  OCKSample
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import HealthKit
import os.log

extension OCKHealthKitPassthroughStore {

    func addTasksIfNotPresent(_ tasks: [OCKHealthKitTask]) async throws {
        let tasksToAdd = tasks
        let taskIdsToAdd = tasksToAdd.compactMap { $0.id }

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = taskIdsToAdd

        let foundTasks = try await fetchTasks(query: query)
        var tasksNotInStore = [OCKHealthKitTask]()

        // Check results to see if there's a missing task
        tasksToAdd.forEach { potentialTask in
            if foundTasks.first(where: { $0.id == potentialTask.id }) == nil {
                tasksNotInStore.append(potentialTask)
            }
        }

        // Only add if there's a new task
        if tasksNotInStore.count > 0 {
            do {
                _ = try await addTasks(tasksNotInStore)
                Logger.ockHealthKitPassthroughStore.info("Added tasks into HealthKitPassthroughStore!")
            } catch {
                Logger.ockHealthKitPassthroughStore.error("Error adding HealthKitTasks: \(error.localizedDescription)")
            }
        }
    }

    func populateSampleData(_ patientUUID: UUID? = nil) async throws {

        let scheduleRecovery = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: Date(), end: nil, text: "Most recent measurement",
            duration: .hours(12), targetValues: [OCKOutcomeValue(90, units: "Milliseconds")])

        let recoveryNumber = OCKHealthKitLinkage(quantityIdentifier: .heartRateVariabilitySDNN,
                                                 quantityType: .discrete,
                                                 unit: .secondUnit(with: .milli))
        var recovery = OCKHealthKitTask(id: TaskID.recovery,
                                        title: "Recovery Quotient",
                                        carePlanUUID: patientUUID,
                                        schedule: scheduleRecovery,
                                        healthKitLinkage: recoveryNumber)
        recovery.card = .numericProgress
        recovery.asset = "bolt.heart"

        let energyBurnedSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: Date(), end: nil, text: "Today",
            duration: .allDay, targetValues: [OCKOutcomeValue(800, units: "Calories")])

        let energyBurnedLinkage = OCKHealthKitLinkage(quantityIdentifier: .activeEnergyBurned,
                                                      quantityType: .cumulative,
                                                      unit: .largeCalorie())

        var energyBurned = OCKHealthKitTask(id: TaskID.energyBurned,
                                            title: "Active Calories Burned",
                                            carePlanUUID: patientUUID,
                                            schedule: energyBurnedSchedule,
                                            healthKitLinkage: energyBurnedLinkage)
        energyBurned.card = .labeledValue
        energyBurned.asset = "flame.circle"

        try await addTasksIfNotPresent([recovery, energyBurned])
    }
}
