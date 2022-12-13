//
//  OCKStore.swift
//  OCKSample
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import Contacts
import os.log
import ParseSwift
import ParseCareKit

extension OCKStore {

    func addTasksIfNotPresent(_ tasks: [OCKTask]) async throws {
        let taskIdsToAdd = tasks.compactMap { $0.id }

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = taskIdsToAdd

        let foundTasks = try await fetchTasks(query: query)
        var tasksNotInStore = [OCKTask]()

        // Check results to see if there's a missing task
        tasks.forEach { potentialTask in
            if foundTasks.first(where: { $0.id == potentialTask.id }) == nil {
                tasksNotInStore.append(potentialTask)
            }
        }

        // Only add if there's a new task
        if tasksNotInStore.count > 0 {
            do {
                _ = try await addTasks(tasksNotInStore)
                Logger.ockStore.info("Added tasks into OCKStore!")
            } catch {
                Logger.ockStore.error("Error adding tasks: \(error.localizedDescription)")
            }
        }
    }

    func populateCarePlans(patientUUID: UUID? = nil) async throws {
        let checkInCarePlan = OCKCarePlan(id: CarePlanID.checkIn.rawValue,
                                          title: "Check in Care Plan",
                                          patientUUID: patientUUID)
        let legDayCarePlan = OCKCarePlan(id: CarePlanID.legDay.rawValue,
                                          title: "Leg Day Care Plan",
                                          patientUUID: patientUUID)
        let armDayCarePlan = OCKCarePlan(id: CarePlanID.armDay.rawValue,
                                          title: "Arm Day Care Plan",
                                          patientUUID: patientUUID)
        let restDayCarePlan = OCKCarePlan(id: CarePlanID.restDay.rawValue,
                                          title: "Rest Day Care Plan",
                                          patientUUID: patientUUID)
        try await AppDelegateKey
            .defaultValue?
            .storeManager
            .addCarePlansIfNotPresent([checkInCarePlan,
                                       legDayCarePlan,
                                       armDayCarePlan,
                                       restDayCarePlan],
                                      patientUUID: patientUUID)
    }

    @MainActor
    class func getCarePlanUUIDs() async throws -> [CarePlanID: UUID] {
        var results = [CarePlanID: UUID]()

        guard let store = AppDelegateKey.defaultValue?.store else {
            return results
        }

        var query = OCKCarePlanQuery(for: Date())
        query.ids = [CarePlanID.health.rawValue,
                     CarePlanID.checkIn.rawValue]

        let foundCarePlans = try await store.fetchCarePlans(query: query)
        // Populate the dictionary for all CarePlan's
        CarePlanID.allCases.forEach { carePlanID in
            results[carePlanID] = foundCarePlans
                .first(where: { $0.id == carePlanID.rawValue })?.uuid
        }
        return results
    }

    func addContactsIfNotPresent(_ contacts: [OCKContact]) async throws {
        let contactIdsToAdd = contacts.compactMap { $0.id }

        // Prepare query to see if contacts are already added
        var query = OCKContactQuery(for: Date())
        query.ids = contactIdsToAdd

        let foundContacts = try await fetchContacts(query: query)
        var contactsNotInStore = [OCKContact]()

        // Check results to see if there's a missing task
        contacts.forEach { potential in
            if foundContacts.first(where: { $0.id == potential.id }) == nil {
                contactsNotInStore.append(potential)
            }
        }

        // Only add if there's a new task
        if contactsNotInStore.count > 0 {
            do {
                _ = try await addContacts(contactsNotInStore)
                Logger.ockStore.info("Added contacts into OCKStore!")
            } catch {
                Logger.ockStore.error("Error adding contacts: \(error.localizedDescription)")
            }
        }
    }

    // Adds tasks and contacts into the store
    func populateSampleData(_ patientUUID: UUID? = nil) async throws {
        try await populateCarePlans(patientUUID: patientUUID)
        let carePlanUUIDs = try await Self.getCarePlanUUIDs()

        let thisMorning = Calendar.current.startOfDay(for: Date())
        guard let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: thisMorning),
              let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo)
            else {
            Logger.ockStore.error("Could not unwrap calendar. Should never hit")
            return
        }

        let mainLifts = weightlifting(carePlanUUIDs: carePlanUUIDs)
        let warmup = warmup(carePlanUUIDs: carePlanUUIDs,
                            thisMorning: thisMorning,
                            aFewDaysAgo: aFewDaysAgo,
                            beforeBreakfast: beforeBreakfast)

        let foamRollSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: Date(), end: nil, text: "Today",
            duration: .allDay)

        var foamRoll = OCKTask(id: TaskID.foamRoll,
                               title: "Foam Roll", carePlanUUID: nil,
                               schedule: foamRollSchedule)
        foamRoll.instructions = "Foam roll daily to stay healthy."
        foamRoll.card = .simple

        var tasksToAdd: [OCKTask] = []
        tasksToAdd.append(warmup)
        tasksToAdd.append(foamRoll)
        for task in mainLifts {
            tasksToAdd.append(task)
        }

        try await addTasksIfNotPresent(tasksToAdd)
        try await addOnboardTask(carePlanUUIDs[.health])
        try await addSurveyTasks(carePlanUUIDs[.checkIn])

        var contact1 = OCKContact(id: "jane", givenName: "Jane",
                                  familyName: "Daniels", carePlanUUID: nil)
        contact1.asset = "JaneDaniels"
        contact1.title = "Family Practice Doctor"
        contact1.role = "Dr. Daniels is a family practice doctor with 8 years of experience."
        contact1.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "janedaniels@uky.edu")]
        contact1.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-2000")]
        contact1.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 357-2040")]

        contact1.address = {
            let address = OCKPostalAddress()
            address.street = "2195 Harrodsburg Rd"
            address.city = "Lexington"
            address.state = "KY"
            address.postalCode = "40504"
            return address
        }()

        var contact2 = OCKContact(id: "matthew", givenName: "Matthew",
                                  familyName: "Reiff", carePlanUUID: nil)
        contact2.asset = "MatthewReiff"
        contact2.title = "OBGYN"
        contact2.role = "Dr. Reiff is an OBGYN with 13 years of experience."
        contact2.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-1000")]
        contact2.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-1234")]
        contact2.address = {
            let address = OCKPostalAddress()
            address.street = "1000 S Limestone"
            address.city = "Lexington"
            address.state = "KY"
            address.postalCode = "40536"
            return address
        }()

        try await addContactsIfNotPresent([contact1, contact2])
    }

    func addOnboardTask(_ carePlanUUID: UUID? = nil) async throws {
        let onboardSchedule = OCKSchedule.dailyAtTime(
                    hour: 0, minutes: 0,
                    start: Date(), end: nil,
                    text: "Task Due!",
                    duration: .allDay
        )

        var onboardTask = OCKTask(
            id: Onboard.identifier(),
            title: "Onboard",
            carePlanUUID: carePlanUUID,
            schedule: onboardSchedule
        )
        onboardTask.instructions = "You'll need to agree to some terms and conditions before we get started!"
        onboardTask.impactsAdherence = false
        onboardTask.card = .survey
        onboardTask.survey = .onboard

        try await addTasksIfNotPresent([onboardTask])
    }

    func addSurveyTasks(_ carePlanUUID: UUID? = nil) async throws {
        let checkInSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0,
            start: Date(), end: nil,
            text: nil
        )

        var checkInTask = OCKTask(
            id: CheckIn.identifier(),
            title: "Check In",
            carePlanUUID: carePlanUUID,
            schedule: checkInSchedule
        )
        checkInTask.card = .survey
        checkInTask.survey = .checkIn

        let workoutSetupSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0,
            start: Date(), end: nil,
            text: nil
        )

        var workoutSetupTask = OCKTask(
            id: WorkoutSetup.identifier(),
            title: "Workout Setup",
            carePlanUUID: carePlanUUID,
            schedule: workoutSetupSchedule
        )
        workoutSetupTask.card = .survey
        workoutSetupTask.survey = .workoutSetup

        try await addTasksIfNotPresent([checkInTask, workoutSetupTask])
    }

    func weightlifting(carePlanUUIDs: [CarePlanID: UUID]) -> [OCKTask] {

        var cards: [OCKTask] = []

        // Sunday
        var sundayRestDay = OCKTask(id: "SundayRestDay",
                              title: "Rest Day",
                                    carePlanUUID: carePlanUUIDs[.restDay],
                              schedule: DaySchedules.sundaySchedule)
        sundayRestDay.impactsAdherence = false
        sundayRestDay.instructions = "Take today off to recover!"
        sundayRestDay.asset = "hourglass"
        sundayRestDay.card = .instruction
        cards.append(sundayRestDay)

        var fridayRestDay = OCKTask(id: "FridayRestDay",
                              title: "Rest Day",
                              carePlanUUID: carePlanUUIDs[.restDay],
                              schedule: DaySchedules.fridaySchedule)
        fridayRestDay.impactsAdherence = false
        fridayRestDay.instructions = "Take today off to recover!"
        fridayRestDay.asset = "hourglass"
        fridayRestDay.card = .instruction
        cards.append(fridayRestDay)

        var saturdayRestDay = OCKTask(id: "SaturdayRestDay",
                              title: "Rest Day",
                              carePlanUUID: carePlanUUIDs[.restDay],
                              schedule: DaySchedules.saturdaySchedule)
        saturdayRestDay.impactsAdherence = false
        saturdayRestDay.instructions = "Take today off to recover!"
        saturdayRestDay.asset = "hourglass"
        saturdayRestDay.card = .instruction
        cards.append(saturdayRestDay)

        // Monday
        var mondayBench = OCKTask(id: "MondayBench",
                                  title: "Barbell Bench Press",
                                  carePlanUUID: carePlanUUIDs[.armDay],
                                  schedule: DaySchedules.mondaySchedule)
        mondayBench.instructions = "4x6 @ 72.5%"
        mondayBench.asset = "figure.strengthtraining.traditional"
        mondayBench.card = .custom
        cards.append(mondayBench)

        var mondayPullUp = OCKTask(id: "MondayPullUp",
                                  title: "Pull-Up",
                                  carePlanUUID: carePlanUUIDs[.armDay],
                                  schedule: DaySchedules.mondaySchedule)
        mondayPullUp.instructions = "3x8"
        mondayPullUp.asset = "figure.strengthtraining.traditional"
        mondayPullUp.card = .custom
        cards.append(mondayPullUp)

        var mondayInclinePress = OCKTask(id: "MondayInclinePress",
                                  title: "Barbell Incline Bench Press",
                                  carePlanUUID: carePlanUUIDs[.armDay],
                                  schedule: DaySchedules.mondaySchedule)
        mondayInclinePress.instructions = "2x8 @ 72.5%"
        mondayInclinePress.asset = "figure.strengthtraining.traditional"
        mondayInclinePress.card = .custom
        cards.append(mondayInclinePress)

        var mondayRow = OCKTask(id: "MondayRow",
                                  title: "Inverted Row",
                                  carePlanUUID: carePlanUUIDs[.armDay],
                                  schedule: DaySchedules.mondaySchedule)
        mondayRow.instructions = "3x10"
        mondayRow.asset = "figure.strengthtraining.traditional"
        mondayRow.card = .custom
        cards.append(mondayRow)

        // Tuesday
        var tuesdaySquat = OCKTask(id: "TuesdaySquat",
                                  title: "Barbell Squat",
                                  carePlanUUID: carePlanUUIDs[.legDay],
                                  schedule: DaySchedules.tuesdaySchedule)
        tuesdaySquat.instructions = "3x5 @ 75%"
        tuesdaySquat.asset = "figure.strengthtraining.traditional"
        tuesdaySquat.card = .custom
        cards.append(tuesdaySquat)

        var tuesdayDeadlift = OCKTask(id: "TuesdayDeadlift",
                                  title: "Stiff Leg Deadlift",
                                  carePlanUUID: carePlanUUIDs[.legDay],
                                  schedule: DaySchedules.tuesdaySchedule)
        tuesdayDeadlift.instructions = "3x10"
        tuesdayDeadlift.asset = "figure.strengthtraining.traditional"
        tuesdayDeadlift.card = .custom
        cards.append(tuesdayDeadlift)

        var tuesdayHipThrust = OCKTask(id: "TuesdayHipThrust",
                                  title: "Barbell Hip Thrust",
                                  carePlanUUID: carePlanUUIDs[.legDay],
                                  schedule: DaySchedules.tuesdaySchedule)
        tuesdayHipThrust.instructions = "3x15"
        tuesdayHipThrust.asset = "figure.strengthtraining.traditional"
        tuesdayHipThrust.card = .custom
        cards.append(tuesdayHipThrust)

        // Wednesday
        var wednesdayBench = OCKTask(id: "WednesdayBench",
                                  title: "Barbell Bench Press",
                                  carePlanUUID: carePlanUUIDs[.armDay],
                                  schedule: DaySchedules.wednesdaySchedule)
        wednesdayBench.instructions = "5x3 @ 80%"
        wednesdayBench.asset = "figure.strengthtraining.traditional"
        wednesdayBench.card = .custom
        cards.append(wednesdayBench)

        var wednesdayPulldown = OCKTask(id: "WednesdayPulldown",
                                  title: "Lat Pulldown",
                                  carePlanUUID: carePlanUUIDs[.armDay],
                                  schedule: DaySchedules.wednesdaySchedule)
        wednesdayPulldown.instructions = "4x6"
        wednesdayPulldown.asset = "figure.strengthtraining.traditional"
        wednesdayPulldown.card = .custom
        cards.append(wednesdayPulldown)

        var wednesdayPress = OCKTask(id: "WednesdayPress",
                                  title: "Barbell Pin Press",
                                  carePlanUUID: carePlanUUIDs[.armDay],
                                  schedule: DaySchedules.wednesdaySchedule)
        wednesdayPress.instructions = "2x8"
        wednesdayPress.asset = "figure.strengthtraining.traditional"
        wednesdayPress.card = .custom
        cards.append(wednesdayPress)

        var wednesdayFacePull = OCKTask(id: "WednesdayFacePull",
                                  title: "Seated Face Pull",
                                  carePlanUUID: carePlanUUIDs[.armDay],
                                  schedule: DaySchedules.wednesdaySchedule)
        wednesdayFacePull.instructions = "3x15"
        wednesdayFacePull.asset = "figure.strengthtraining.traditional"
        wednesdayFacePull.card = .custom
        cards.append(wednesdayFacePull)

        // Thursday
        var thursdayDeadlift = OCKTask(id: "ThursdayDeadlift",
                                  title: "Deadlift",
                                  carePlanUUID: carePlanUUIDs[.legDay],
                                  schedule: DaySchedules.thursdaySchedule)
        thursdayDeadlift.instructions = "4x6"
        thursdayDeadlift.asset = "figure.strengthtraining.traditional"
        thursdayDeadlift.card = .custom
        cards.append(thursdayDeadlift)

        var thursdaySquat = OCKTask(id: "ThursdaySquat",
                                  title: "Front Squat",
                                  carePlanUUID: carePlanUUIDs[.legDay],
                                  schedule: DaySchedules.thursdaySchedule)
        thursdaySquat.instructions = "3x10"
        thursdaySquat.asset = "figure.strengthtraining.traditional"
        thursdaySquat.card = .custom
        cards.append(thursdaySquat)

        var thursdayLegPress = OCKTask(id: "ThursdayLegPress",
                                  title: "Leg Press",
                                  carePlanUUID: carePlanUUIDs[.legDay],
                                  schedule: DaySchedules.thursdaySchedule)
        thursdayLegPress.instructions = "3x10"
        thursdayLegPress.asset = "figure.strengthtraining.traditional"
        thursdayLegPress.card = .custom
        cards.append(thursdayLegPress)

        var thursdayLegCurl = OCKTask(id: "ThursdayLegCurl",
                                  title: "Leg Curl",
                                  carePlanUUID: carePlanUUIDs[.legDay],
                                  schedule: DaySchedules.thursdaySchedule)
        thursdayLegCurl.instructions = "3x10"
        thursdayLegCurl.asset = "figure.strengthtraining.traditional"
        thursdayLegCurl.card = .custom
        cards.append(thursdayLegCurl)

        return cards
    }

    func bodybuilding() {
        // Need to add
    }

    func powerlifting() {
        // Need to add
    }

    func warmup(carePlanUUIDs: [CarePlanID: UUID],
                thisMorning: Date,
                aFewDaysAgo: Date,
                beforeBreakfast: Date) -> OCKTask {

        let cardio = OCKScheduleElement(start: beforeBreakfast,
                                        end: nil,
                                        interval: DateComponents(day: 1),
                                        text: "Low Intensity Cardio",
                                        duration: .minutes(5))
        let foamRoll = OCKScheduleElement(start: beforeBreakfast,
                                          end: nil,
                                          interval: DateComponents(day: 1),
                                          text: "Foam Roll",
                                          duration: .minutes(3))
        let legSwings = OCKScheduleElement(start: beforeBreakfast,
                                           end: nil,
                                           interval: DateComponents(day: 1),
                                           text: "Vertical & Horizontal Leg Swings",
                                           duration: .minutes(3))
        let gluteSqueeze = OCKScheduleElement(start: beforeBreakfast,
                                              end: nil,
                                              interval: DateComponents(day: 1),
                                              text: "Standing Glute Squeeze",
                                              duration: .seconds(30))
        let proneTrapRaise = OCKScheduleElement(start: beforeBreakfast,
                                                end: nil,
                                                interval: DateComponents(day: 1),
                                                text: "Prone Trap Raise",
                                                duration: .seconds(30))
        let cableRotation = OCKScheduleElement(start: beforeBreakfast,
                                               end: nil,
                                               interval: DateComponents(day: 1),
                                               text: "Internal & External Cable Rotation",
                                               duration: .minutes(2))
        let overheadShrug = OCKScheduleElement(start: beforeBreakfast,
                                               end: nil,
                                               interval: DateComponents(day: 1),
                                               text: "Overhead Shrug",
                                               duration: .seconds(30))

        let warmupSchedule = OCKSchedule(composing: [cardio,
                                                     foamRoll,
                                                     legSwings,
                                                     gluteSqueeze,
                                                     proneTrapRaise,
                                                     cableRotation,
                                                     overheadShrug])
        var warmup = OCKTask(id: TaskID.warmup, title: "Warm Up", carePlanUUID: nil, schedule: warmupSchedule)
        warmup.impactsAdherence = true
        warmup.asset = "figure.rolling"
        warmup.card = .checklist

        return warmup
    }

}
