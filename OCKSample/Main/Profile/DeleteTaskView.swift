//
//  DeleteTaskView.swift
//  OCKSample
//
//  Created by Colin  Carver  on 10/28/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import CareKit
import CareKitStore
import ParseCareKit

struct DeleteTaskView: View {

    @StateObject var viewModel = DeleteTaskViewModel()
    @Binding var showDeleteTaskView: Bool

    var body: some View {
        if showDeleteTaskView {
            NavigationView {
                Form {
                    general
                }
                .navigationTitle("Delete Task")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            self.showDeleteTaskView.toggle()
                        }
                    }
                }
            }
        }
    }
}

private extension DeleteTaskView {
    var general: some View {
        Section {
            Button("Run task finder") {
                viewModel.runRetrieveTasks()
            }
        }
    }
}
