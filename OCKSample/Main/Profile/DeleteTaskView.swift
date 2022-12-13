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
    @State private var selection = Set<String>()

    var body: some View {
        if showDeleteTaskView {
            NavigationView {
                VStack {
                    if viewModel.isLoading {
                        if viewModel.taskIDs.isEmpty {
                            Text("No data here.")
                        } else {
                            List($viewModel.taskIDs, id: \.self, selection: $selection) { _ in
                                Text("1")
                            }
                            .navigationTitle("List Selection")
                            .toolbar {
                                EditButton()
                            }
                        }
                    } else {
                        Text("Loading today's tasks...")
                    }
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
