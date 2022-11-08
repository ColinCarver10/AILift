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
    @Environment(\.tintColor) private var tintColor
    @StateObject var viewModel = ProfileViewModel()
    @ObservedObject var loginViewModel: LoginViewModel
    
    @State var firstName = ""
    @State var lastName = ""
    @State var birthday = Date()
    @State var showAddTaskView = false
    @State var showDeleteTaskView = false

    var body: some View {
        NavigationView {
            VStack {
                Text("")
                    .toolbar {
                        ToolbarItemGroup {
                            Button {
                                self.showAddTaskView = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            Button {
                                self.showDeleteTaskView = true
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                        }
                    }
                VStack(alignment: .leading) {
                    TextField("First Name", text: $firstName)
                        .padding()
                        .cornerRadius(20.0)
                        .shadow(radius: 10.0, x: 20, y: 10)

                    TextField("Last Name", text: $lastName)
                        .padding()
                        .cornerRadius(20.0)
                        .shadow(radius: 10.0, x: 20, y: 10)

                    DatePicker("Birthday", selection: $birthday, displayedComponents: [DatePickerComponents.date])
                        .padding()
                        .cornerRadius(20.0)
                        .shadow(radius: 10.0, x: 20, y: 10)
                }

                Button(action: {
                    Task {
                        do {
                            try await viewModel.saveProfile(firstName,
                                                            last: lastName,
                                                            birth: birthday)
                        } catch {
                            Logger.profile.error("Error saving profile: \(error.localizedDescription)")
                        }
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
            }.onReceive(viewModel.$patient, perform: { patient in
                if let currentFirstName = patient?.name.givenName {
                    firstName = currentFirstName
                }
                if let currentLastName = patient?.name.familyName {
                    lastName = currentLastName
                }
                if let currentBirthday = patient?.birthday {
                    birthday = currentBirthday
                }
            })
        } .overlay(DeleteTaskView(showDeleteTaskView: self.$showDeleteTaskView))
            .overlay(AddTaskView(showAddTaskView: self.$showAddTaskView))
    }

}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init(storeManager: Utility.createPreviewStoreManager()),
                    loginViewModel: .init())
            .accentColor(Color(TintColorKey.defaultValue))
    }
}
