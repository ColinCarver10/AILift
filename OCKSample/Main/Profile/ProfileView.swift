//
//  ProfileView.swift
//  OCKSample
//
//  Created by Corey Baker on 11/24/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import CareKitUI
import CareKitStore
import CareKit
import os.log

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @ObservedObject var loginViewModel: LoginViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("My Contact") {
                                viewModel.isPresentingContact = true
                            }
                            .sheet(isPresented: $viewModel.isPresentingContact) {
                                MyContactView()
                            }
                        }
                        ToolbarItemGroup {
                            Button {
                                viewModel.showAddTaskView = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            Button {
                                viewModel.showDeleteTaskView = true
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                        }
                    }
                VStack {
                    ProfileImageView(viewModel: viewModel)
                    Form {
                        Section(header: Text("About")) {
                            TextField("First Name", text: $viewModel.firstName)
                            TextField("Last Name", text: $viewModel.lastName)
                            DatePicker("Birthday",
                                       selection: $viewModel.birthday,
                                       displayedComponents: [DatePickerComponents.date])
                            Picker(selection: $viewModel.sex,
                                   label: Text("Sex")) {
                                Text(OCKBiologicalSex.female.rawValue).tag(OCKBiologicalSex.female)
                                Text(OCKBiologicalSex.male.rawValue).tag(OCKBiologicalSex.male)
                                Text(viewModel.sex.rawValue)
                                    .tag(OCKBiologicalSex.other(viewModel.sexOtherField))
                            }
                            TextField("Allergies", text: $viewModel.allergies[0])
                            Picker(selection: $viewModel.workoutType, label: Text("Workout Type")) {
                                Text("Body Building").tag(WorkoutType.bodybuilding)
                                Text("Power Lifting").tag(WorkoutType.powerlifting)
                                Text("Weight Lifting").tag(WorkoutType.weightlifting)
                            }
                        }
                        Section(header: Text("Contact")) {
                            TextField("Street", text: $viewModel.street)
                            TextField("City", text: $viewModel.city)
                            TextField("State", text: $viewModel.state)
                            TextField("Postal code", text: $viewModel.zipcode)
                            TextField("Email Address", text: $viewModel.emailAddresses[0].value)
                            TextField("Messaging Number", text: $viewModel.messagingNumbers[0].value)
                            TextField("Phone Number", text: $viewModel.phoneNumbers[0].value)
                            TextField("Other Contact Info", text: $viewModel.otherContactInfo[0].value)
                        }
                    }
                }

                Button(action: {
                    Task {
                            await viewModel.saveProfile()
                    }
                }, label: {
                    Text("Save Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                })
                .background(Color(.green))
                .cornerRadius(15)

                // Notice that "action" is a closure (which is essentially
                // a function as argument like we discussed in class)
                Button(action: {
                    Task {
                        await loginViewModel.logout()
                    }
                }, label: {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                })
                .background(Color(.red))
                .cornerRadius(15)
            }.sheet(isPresented: $viewModel.isPresentingImagePicker) {
                ImagePicker(image: $viewModel.profileUIImage)
            } .alert(isPresented: $viewModel.isShowingSaveAlert) {
                return Alert(title: Text("Update"),
                             message: Text(viewModel.alertMessage),
                             dismissButton: .default(Text("Ok"), action: {
                    viewModel.isShowingSaveAlert = false
                }))
            }
        } .overlay(DeleteTaskView(showDeleteTaskView: self.$viewModel.showDeleteTaskView))
            .overlay(AddTaskView(showAddTaskView: self.$viewModel.showAddTaskView))
    }

}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init(storeManager: Utility.createPreviewStoreManager()),
                    loginViewModel: .init())
            .accentColor(Color(TintColorKey.defaultValue))
    }
}
