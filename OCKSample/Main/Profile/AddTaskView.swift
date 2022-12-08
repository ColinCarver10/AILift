//
//  AddTaskView.swift
//  OCKSample
//
//  Created by Colin  Carver  on 10/26/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import HealthKit

struct AddTaskView: View {

    @StateObject var viewModel = AddTaskViewModel()
    @State var storeManager = StoreManagerKey.defaultValue

    // Create enum for healthkit task

    var availableHealthKitTaskTypes: [HKQuantityTypeIdentifier] = [.appleSleepingWristTemperature,
        .appleExerciseTime,
        .heartRate,
        .activeEnergyBurned,
        .vo2Max,
        .stepCount]

    @Binding var showAddTaskView: Bool

    @State var selectedTaskType: TaskType = .task

    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        if showAddTaskView {
            NavigationView {
                Form {

                    general

                }
                .navigationTitle("Add New Task")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            if self.selectedTaskType == .task {
                                Task {
                                    await viewModel.addTask()
                                    resetValues()
                                }
                                self.showAddTaskView.toggle()
                            } else if self.selectedTaskType == .healthKitTask {
                                Task {
                                    await viewModel.addHealthKitTask()
                                    resetValues()
                                    viewModel.healthKitTaskType = .appleSleepingWristTemperature
                                }
                                self.showAddTaskView.toggle()
                            }
                        }
                    }
                }
            }
        }
    }
}

private extension AddTaskView {

    var general: some View {

        Section {
            Picker("Task", selection: $selectedTaskType) {
                ForEach(TaskType.allCases) { taskType in
                                            Text(taskType.rawValue.capitalized).tag(taskType)
                                        }
            } .pickerStyle(SegmentedPickerStyle())

            if selectedTaskType == .task {
                TextField("Title", text: $viewModel.title)
                TextField("Description", text: $viewModel.instructions)

                Picker("Day", selection: $viewModel.selectedDay) {
                    ForEach(Day.allCases) { day in
                                                Text(day.rawValue.capitalized).tag(day)
                                            }
                }

                DatePicker("Schedule",
                           selection: $viewModel.taskSchedule,
                           displayedComponents: [.date])

                Picker("Select asset", selection: $viewModel.selectedAsset) {
                    Text("Heart").tag("heart.fill")
                    Text("Bed").tag("bed.double.circle.fill")
                    Text("Eye").tag("eye.fill")
                    Text("Brain").tag("brain.head.profile")
                    Text("Walking").tag("figure.walk")
                    Text("Lungs").tag("lungs.fill")
                }

                Picker("Card View", selection: $viewModel.selectedCard) {
                    ForEach(CareKitCard.allCases) { item in
                        Text(item.rawValue)
                    }
                }

            } else if selectedTaskType == .healthKitTask {

                Picker("Type of HealthKit task", selection: $viewModel.healthKitTaskType) {
                    Text("Sleep Temperature")
                        .tag(HKQuantityTypeIdentifier.appleSleepingWristTemperature)
                    Text("Exercise Time")
                        .tag(HKQuantityTypeIdentifier.appleExerciseTime)
                    Text("Heart Rate")
                        .tag(HKQuantityTypeIdentifier.heartRate)
                    Text("Active Energy Burned")
                        .tag(HKQuantityTypeIdentifier.activeEnergyBurned)
                    Text("VO2Max")
                        .tag(HKQuantityTypeIdentifier.vo2Max)
                    Text("StepCount")
                        .tag(HKQuantityTypeIdentifier.stepCount)
                }

                TextField("Title", text: $viewModel.title)
                TextField("Description", text: $viewModel.instructions)

                Picker("Day", selection: $viewModel.selectedDay) {
                    ForEach(Day.allCases) { day in
                                                Text(day.rawValue.capitalized).tag(day)
                                            }
                }

                DatePicker("Schedule",
                           selection: $viewModel.taskSchedule,
                           displayedComponents: [.date])

                Picker("Select asset", selection: $viewModel.selectedAsset) {
                    Text("Heart").tag("heart.fill")
                    Text("Bed").tag("bed.double.circle.fill")
                    Text("Eye").tag("eye.fill")
                    Text("Brain").tag("brain.head.profile")
                    Text("Walking").tag("figure.walk")
                    Text("Lungs").tag("lungs.fill")
                }
            }
        } header: {
            Text("General")
        } .headerProminence(.increased)
    }
}

private extension AddTaskView {
    func handleDismissal() {
        if #available(iOS 15, *) {
            dismiss()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

private extension AddTaskView {
    func resetValues() {
        viewModel.title = ""
        viewModel.instructions = ""
        viewModel.selectedDay = .monday
        selectedTaskType = .task
        viewModel.taskSchedule = Date()
        viewModel.selectedAsset = "figure.walk"
        viewModel.selectedCard = .button
    }
}
