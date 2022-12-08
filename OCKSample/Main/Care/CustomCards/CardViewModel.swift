//
//  CardViewModel.swift
//  OCKSample
//
//  Created by Corey Baker on 12/3/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import CareKit
import CareKitStore
import Foundation

/**
 A basic view model that can be subclassed to make more intricate view models for custom
 CareKit cards.
 */
class CardViewModel: OCKTaskController {

    // MARK: Public read/write properties
    /// The error encountered by the view model.
    @Published public var actionError: Error?

    // MARK: Public read private write properties
    private(set) var query: SynchronizedTaskQuery?

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - taskID: The ID of the task to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    convenience init(taskID: String,
                     eventQuery: OCKEventQuery,
                     storeManager: OCKSynchronizedStoreManager) {
        self.init(storeManager: storeManager)
        setQuery(.taskIDs([taskID], eventQuery))
        self.query?.perform(using: self)
    }

    /// Create an instance for the default content. The first event that matches the
    /// provided query will be fetched from the the store and
    /// published to the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - task: The task associated with the event to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    convenience init(task: OCKAnyTask,
                     eventQuery: OCKEventQuery,
                     storeManager: OCKSynchronizedStoreManager) {
        self.init(storeManager: storeManager)
        setQuery(.tasks([task], eventQuery))
        self.query?.perform(using: self)
    }

    /**
     Set the query property for this class.
     - parameter query: The query to keep in sync with this view model.
     */
    func setQuery(_ query: SynchronizedTaskQuery) {
        self.query = query
    }
}

extension CardViewModel {
    /// Creates a query that can be used to synchronize `CardViewModel`'s.
    enum SynchronizedTaskQuery {

        case taskQuery(_ taskQuery: OCKTaskQuery, _ eventQuery: OCKEventQuery)
        case taskIDs(_ taskIDs: [String], _ eventQuery: OCKEventQuery)

        static func tasks(_ tasks: [OCKAnyTask], _ eventQuery: OCKEventQuery) -> Self {
            let taskIDs = Array(Set(tasks.map { $0.id }))
            return .taskIDs(taskIDs, eventQuery)
        }

        func perform(using viewModel: CardViewModel) {
            switch self {
            case let .taskQuery(taskQuery, eventQuery):
                viewModel.fetchAndObserveEvents(forTaskQuery: taskQuery, eventQuery: eventQuery)
            case let .taskIDs(taskIDs, eventQuery):
                viewModel.fetchAndObserveEvents(forTaskIDs: taskIDs, eventQuery: eventQuery)
            }
        }
    }
}
