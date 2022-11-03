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

class DeleteTaskViewModel: ObservableObject {

    @Published var error: AppError?
    @State var availableTasks: [OCKTask]? = []

    func retrieveTasks() async {

        guard let appDelegate = AppDelegateKey.defaultValue else {
            error =  AppError.couldntBeUnwrapped
            return
        }

        do {
            availableTasks = try await appDelegate.store?.fetchTasks(query: OCKTaskQuery(for: Date()))
            guard let tasks = availableTasks else {
                return
            }

            for task in tasks {

                print("This is a task \(task)")
            }
        } catch {
            // swiftlint:disable:next line_length superfluous_disable_command
            self.error = AppError.errorString("Couldn't add task: \(error.localizedDescription)")
        }
    }

    func runRetrieveTasks() {
        Task {
            await retrieveTasks()
        }
    }
}
