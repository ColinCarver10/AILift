//
//  Constants.swift
//  OCKSample
//
//  Created by Corey Baker on 11/27/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import ParseSwift

/**
 Set to **true** to sync with ParseServer, *false** to sync with iOS/watchOS.
 */
let isSyncingWithCloud = true
/**
 Set to **true** to use WCSession to notify watchOS about updates, **false** to not notify.
 A change in watchOS 9 removes the ability to use Websockets on real Apple Watches,
 preventing auto updates from the Parse Server. See the link for
 details: https://developer.apple.com/forums/thread/715024
 */
let isSendingPushUpdatesToWatch = true

enum AppError: Error {
    case couldntCast
    case couldntBeUnwrapped
    case valueNotFoundInUserInfo
    case remoteClockIDNotAvailable
    case emptyTaskEvents
    case invalidIndexPath(_ indexPath: IndexPath)
    case noOutcomeValueForEvent(_ event: OCKAnyEvent, index: Int)
    case cannotMakeOutcomeFor(_ event: OCKAnyEvent)
    case parseError(_ error: ParseError)
    case error(_ error: Error)
    case errorString(_ string: String)
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldntCast:
            return NSLocalizedString("OCKSampleError: Could not cast to required type.",
                                     comment: "Casting error")
        case .couldntBeUnwrapped:
            return NSLocalizedString("OCKSampleError: Could not unwrap a required type.",
                                     comment: "Unwrapping error")
        case .valueNotFoundInUserInfo:
            return NSLocalizedString("OCKSampleError: Could not find the required value in userInfo.",
                                     comment: "Value not found error")
        case .remoteClockIDNotAvailable:
            return NSLocalizedString("OCKSampleError: Could not get remote clock ID.",
                                     comment: "Value not available error")
        case .emptyTaskEvents: return "Task events is empty"
        case let .noOutcomeValueForEvent(event, index): return "Event has no outcome value at index \(index): \(event)"
        case .invalidIndexPath(let indexPath): return "Invalid index path \(indexPath)"
        case .cannotMakeOutcomeFor(let event): return "Cannot make outcome for event: \(event)"
        case .parseError(let error): return "\(error)"
        case .error(let error): return "\(error)"
        case .errorString(let string): return string
        }
    }
}

enum Constants {
    static let parseConfigFileName = "ParseCareKit" // -heroku
    static let iOSParseCareStoreName = "iOSParseStore"
    static let iOSLocalCareStoreName = "iOSLocalStore"
    static let watchOSParseCareStoreName = "watchOSParseStore"
    static let watchOSLocalCareStoreName = "watchOSLocalStore"
    static let noCareStoreName = "none"
    static let parseUserSessionTokenKey = "requestParseSessionToken"
    static let requestSync = "requestSync"
    static let progressUpdate = "progressUpdate"
    static let finishedAskingForPermission = "finishedAskingForPermission"
    static let shouldRefreshView = "shouldRefreshView"
    static let completedFirstSyncAfterLogin = "completedFirstSyncAfterLogin"
    static let userLoggedIn = "userLoggedIn"
    static let storeInitialized = "storeInitialized"
    static let userTypeKey = "userType"
    static let workoutTypeKey = "workoutType"
    static let card = "card"
    static let survey = "survey"
    static var workoutSetupCompleted = false
}

enum MainViewPath {
    case tabs
}

enum CareKitCard: String, CaseIterable, Identifiable {
    var id: Self { self }
    case button = "Button"
    case checklist = "Checklist"
    case featured = "Featured"
    case grid = "Grid"
    case instruction = "Instruction"
    case labeledValue = "Labeled Value"
    case link = "Link"
    case numericProgress = "Numeric Progress"
    case simple = "Simple"
    case survey = "Survey"
    case custom = "Custom" // xTODO: Should add any custom card you make to this enum.
}

enum CarePlanID: String, CaseIterable, Identifiable {
    var id: Self { self }
    case health // Add custom id's for your Care Plans, these are examples
    case checkIn
    case armDay
    case legDay
    case restDay
}

enum TaskID {
    static let doxylamine = "doxylamine"
    static let nausea = "nausea"
    static let stretch = "stretch"
    static let kegels = "kegels"
    static let steps = "steps"
    static let repetition = "repetition"
    static let warmup = "warmup"
    static let recovery = "recovery"
    static let rest = "rest"
    static let energyBurned = "energyburned"
    static let foamRoll = "foamroll"

    static var ordered: [String] {
        [Self.recovery, Self.warmup, Self.repetition]
    }
}

enum UserType: String, Codable {
    case patient                           = "Patient"
    case none                              = "None"

    // Return all types as an array, make sure to maintain order above
    func allTypesAsArray() -> [String] {
        return [UserType.patient.rawValue,
                UserType.none.rawValue]
    }
}

enum WorkoutType: String, Codable {
    case bodybuilding, powerlifting, weightlifting

    func allTypesAsArray() -> [String] {
        return [WorkoutType.bodybuilding.rawValue,
                WorkoutType.powerlifting.rawValue,
                WorkoutType.weightlifting.rawValue]
    }
}

enum InstallationChannel: String {
    case global
}

enum TaskType: String, CaseIterable, Identifiable {
    case task, healthKitTask
    var id: String { self.rawValue }
}

enum Day: Int, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { self.rawValue }
}

enum DaySchedules {
    private static let calendar = Calendar(identifier: .gregorian)

    private static let sunday = DateComponents(weekday: Day.sunday.id)
    private static let monday = DateComponents(weekday: Day.monday.id)
    private static let tuesday = DateComponents(weekday: Day.tuesday.id)
    private static let wednesday = DateComponents(weekday: Day.wednesday.id)
    private static let thursday = DateComponents(weekday: Day.thursday.id)
    private static let friday = DateComponents(weekday: Day.friday.id)
    private static let saturday = DateComponents(weekday: Day.saturday.id)

    private static let nextSunday = calendar.nextDate(after: Date().dayBefore,
                                    matching: sunday,
                                          matchingPolicy: .nextTimePreservingSmallerComponents)
    private static let nextMonday = calendar.nextDate(after: Date().dayBefore,
                                    matching: monday,
                                          matchingPolicy: .nextTimePreservingSmallerComponents)
    private static let nextTuesday = calendar.nextDate(after: Date().dayBefore,
                                    matching: tuesday,
                                          matchingPolicy: .nextTimePreservingSmallerComponents)
    private static let nextWednesday = calendar.nextDate(after: Date().dayBefore,
                                    matching: wednesday,
                                          matchingPolicy: .nextTimePreservingSmallerComponents)
    private static let nextThursday = calendar.nextDate(after: Date().dayBefore,
                                    matching: thursday,
                                          matchingPolicy: .nextTimePreservingSmallerComponents)
    private static let nextFriday = calendar.nextDate(after: Date().dayBefore,
                                    matching: friday,
                                          matchingPolicy: .nextTimePreservingSmallerComponents)
    private static let nextSaturday = calendar.nextDate(after: Date().dayBefore,
                                    matching: saturday,
                                          matchingPolicy: .nextTimePreservingSmallerComponents)

    private static let weeklyAtSunday = OCKScheduleElement(start: nextSunday ?? Date(),
                                         end: nil,
                                         interval: DateComponents(weekOfYear: 1))
    private static let weeklyAtMonday = OCKScheduleElement(start: nextMonday ?? Date(),
                                         end: nil,
                                         interval: DateComponents(weekOfYear: 1))
    private static let weeklyAtTuesday = OCKScheduleElement(start: nextTuesday ?? Date(),
                                         end: nil,
                                         interval: DateComponents(weekOfYear: 1))
    private static let weeklyAtWednesday = OCKScheduleElement(start: nextWednesday ?? Date(),
                                         end: nil,
                                         interval: DateComponents(weekOfYear: 1))
    private static let weeklyAtThursday = OCKScheduleElement(start: nextThursday ?? Date(),
                                         end: nil,
                                         interval: DateComponents(weekOfYear: 1))
    private static let weeklyAtFriday = OCKScheduleElement(start: nextFriday ?? Date(),
                                         end: nil,
                                         interval: DateComponents(weekOfYear: 1))
    private static let weeklyAtSaturday = OCKScheduleElement(start: nextSaturday ?? Date(),
                                         end: nil,
                                         interval: DateComponents(weekOfYear: 1))

    static let sundaySchedule = OCKSchedule(composing: [weeklyAtSunday])
    static let mondaySchedule = OCKSchedule(composing: [weeklyAtMonday])
    static let tuesdaySchedule = OCKSchedule(composing: [weeklyAtTuesday])
    static let wednesdaySchedule = OCKSchedule(composing: [weeklyAtWednesday])
    static let thursdaySchedule = OCKSchedule(composing: [weeklyAtThursday])
    static let fridaySchedule = OCKSchedule(composing: [weeklyAtFriday])
    static let saturdaySchedule = OCKSchedule(composing: [weeklyAtSaturday])
}
