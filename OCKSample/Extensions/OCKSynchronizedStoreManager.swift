//
//  OCKSynchronizedStoreManager.swift
//  OCKSample
//
//  Created by Corey Baker on 11/7/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import CareKitUI
import os.log

extension OCKSynchronizedStoreManager {

    /**
      Adds an `OCKAnyCarePlan`*asynchronously*  to `OCKStore` if it has not been added already.

      - parameter carePlans: The array of `OCKAnyCarePlan`'s to be added to the `OCKStore`.
      - parameter patientUUID: The uuid of the `OCKPatient` to tie to the `OCKCarePlan`. Defaults to nil.
      - throws: An error if there was a problem adding the missing `OCKAnyCarePlan`'s.
      - note: `OCKAnyCarePlan`'s that have an existing `id` will not be added and will not cause errors to be thrown.
     */
    func addCarePlansIfNotPresent(_ carePlans: [OCKAnyCarePlan], patientUUID: UUID? = nil) async throws {
        let carePlanIdsToAdd = carePlans.compactMap { $0.id }

        // Prepare query to see if Care Plan are already added
        var query = OCKCarePlanQuery(for: Date())
        query.ids = carePlanIdsToAdd
        let foundCarePlans = try await store.fetchAnyCarePlans(query: query)
        var carePlanNotInStore = [OCKAnyCarePlan]()
        // Check results to see if there's a missing Care Plan
        carePlans.forEach { potentialCarePlan in
            if foundCarePlans.first(where: { $0.id == potentialCarePlan.id }) == nil {
                // Check if can be casted to OCKCarePlan to add patientUUID
                guard var mutableCarePlan = potentialCarePlan as? OCKCarePlan else {
                    carePlanNotInStore.append(potentialCarePlan)
                    return
                }
                mutableCarePlan.patientUUID = patientUUID
                carePlanNotInStore.append(mutableCarePlan)
            }
        }

        // Only add if there's a new Care Plan
        if carePlanNotInStore.count > 0 {
            do {
                _ = try await store.addAnyCarePlans(carePlanNotInStore)
                Logger.ockSynchronizedStoreManager.info("Added Care Plans into OCKStore!")
            } catch {
                Logger.ockSynchronizedStoreManager.error("Error adding Care Plans: \(error.localizedDescription)")
            }
        }
    }

    func addTasksIfNotPresent(_ tasks: [OCKAnyTask]) async throws {
        let taskIdsToAdd = tasks.compactMap { $0.id }

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = taskIdsToAdd

        let foundTasks = try await store.fetchAnyTasks(query: query)
        var tasksNotInStore = [OCKAnyTask]()

        // Check results to see if there's a missing task
        tasks.forEach { potentialTask in
            if foundTasks.first(where: { $0.id == potentialTask.id }) == nil {
                tasksNotInStore.append(potentialTask)
            }
        }

        // Only add if there's a new task
        if tasksNotInStore.count > 0 {
            do {
                _ = try await store.addAnyTasks(tasksNotInStore)
                Logger.ockSynchronizedStoreManager.info("Added tasks into OCKSynchronizedStoreManager!")
            } catch {
                Logger.ockSynchronizedStoreManager.error("Error adding tasks: \(error.localizedDescription)")
            }
        }
    }

    func addContactsIfNotPresent(_ contacts: [OCKAnyContact], carePlanUUID: UUID? = nil) async throws {
        let contactIdsToAdd = contacts.compactMap { $0.id }

        // Prepare query to see if contacts are already added
        var query = OCKContactQuery(for: Date())
        query.ids = contactIdsToAdd

        let foundContacts = try await store.fetchAnyContacts(query: query)
        var contactsNotInStore = [OCKAnyContact]()

        // Check results to see if there's a missing task
        contacts.forEach { potential in
            if foundContacts.first(where: { $0.id == potential.id }) == nil {
                // Check if can be casted to OCKCarePlan to add patientUUID
                guard var mutableContact = potential as? OCKContact else {
                    contactsNotInStore.append(potential)
                    return
                }
                mutableContact.carePlanUUID = carePlanUUID
                contactsNotInStore.append(mutableContact)
            }
        }

        // Only add if there's a new task
        if contactsNotInStore.count > 0 {
            do {
                _ = try await store.addAnyContacts(contactsNotInStore)
                Logger.ockSynchronizedStoreManager.info("Added contacts into OCKSynchronizedStoreManager!")
            } catch {
                Logger.ockSynchronizedStoreManager.error("Error adding contacts: \(error.localizedDescription)")
            }
        }
    }
}
