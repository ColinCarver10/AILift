//
//  DeleteTaskViewModel.swift
//  OCKSample
//
//  Created by Colin  Carver  on 10/28/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import SwiftUI
import ParseCareKit
import os.log

class DeleteTaskViewModel: ObservableObject {

    @Published var error: AppError?
    @Published var taskIDs: [String] = []
    var tasks: [OCKAnyTask] = []
    @Published var isLoading: Bool = false
    var storeManager = StoreManagerKey.defaultValue

    init() {
        self.isLoading = true
        fetchTasks(on: Date())

    }

    func fetchTasks(on date: Date) {
        var query = OCKTaskQuery(for: date)
        query.excludesTasksWithNoEvents = true
        storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { result in
            do {
                try self.tasks.append(contentsOf: result.get())
            } catch {
                Logger.feed.error("\(error.localizedDescription, privacy: .public)")
            }
        }

        for task in tasks {
            taskIDs.append(task.id)
        }

    }
}
