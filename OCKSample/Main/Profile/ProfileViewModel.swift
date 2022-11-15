//
//  Profile.swift
//  OCKSample
//
//  Created by Corey Baker on 11/25/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import SwiftUI
import ParseCareKit
import os.log
import Combine
import ParseSwift

class ProfileViewModel: ObservableObject {
    // MARK: Public read, private write properties
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var birthday = Date()
    @Published var showAddTaskView = false
    @Published var showDeleteTaskView = false
    @Published var sex: OCKBiologicalSex = .other("other")
    @Published var sexOtherField = "other"
    @Published var allergies = [""]
    @Published var note = ""
    @Published var street = ""
    @Published var city = ""
    @Published var state = ""
    @Published var zipcode = ""
    @Published var messagingNumbers: [OCKLabeledValue] = [.init(label: "Messaging Numbers", value: "")]
    @Published var emailAddresses: [OCKLabeledValue] = [.init(label: "Email Addresses", value: "")]
    @Published var phoneNumbers: [OCKLabeledValue] = [.init(label: "Phone numbers", value: "")]
    @Published var otherContactInfo: [OCKLabeledValue] = [.init(label: "Other Contact Info", value: "")]
    @Published var isShowingSaveAlert = false
    @Published var isPresentingAddTask = false
    @Published var isPresentingContact = false
    @Published var isPresentingImagePicker = false
    @Published var profileUIImage = UIImage(systemName: "person.fill") {
        willSet {
            guard self.profileUIImage != newValue,
                let inputImage = newValue else {
                return
            }

            if !isSettingProfilePictureForFirstTime {
                Task {
                    guard var currentUser = User.current,
                          let image = inputImage.jpegData(compressionQuality: 0.25) else {
                        Logger.profile.error("User is not logged in or could not compress image")
                        return
                    }

                    let newProfilePicture = ParseFile(name: "profile.jpg", data: image)
                    // Use `.set()` to update ParseObject's that have already been saved before.
                    currentUser = currentUser.set(\.profilePicture, to: newProfilePicture)
                    do {
                        _ = try await currentUser.save()
                        Logger.profile.info("Saved updated profile picture successfully.")
                    } catch {
                        Logger.profile.error("Could not save profile picture: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    @Published private(set) var error: Error?

    private(set) var storeManager: OCKSynchronizedStoreManager
    private(set) var alertMessage = "All changes saved successfully!"

    // MARK: Private read/write properties

    private var patient: OCKPatient? {
         willSet {
             if let currentFirstName = newValue?.name.givenName {
                 firstName = currentFirstName
             } else {
                 firstName = ""
             }
             if let currentLastName = newValue?.name.familyName {
                 lastName = currentLastName
             } else {
                 lastName = ""
             }
             if let currentBirthday = newValue?.birthday {
                 birthday = currentBirthday
             } else {
                 birthday = Date()
             }
             if let currentAllergies = newValue?.allergies {
                 allergies = currentAllergies
             } else {
                 allergies = [""]
             }
         }
     }
    private var contact: OCKContact? {
        willSet {
            if let currentStreet = newValue?.address?.street {
                street = currentStreet
            } else {
                street = ""
            }
            if let currentCity = newValue?.address?.city {
                city = currentCity
            } else {
                city = ""
            }
            if let currentState = newValue?.address?.state {
                state = currentState
            } else {
                state = ""
            }
            if let currentZipCode = newValue?.address?.postalCode {
                zipcode = currentZipCode
            } else {
                zipcode = ""
            }
            if let currentMessagingNumbers = newValue?.messagingNumbers {
                messagingNumbers = currentMessagingNumbers
            } else {
                messagingNumbers =  [.init(label: "Messaging Numbers", value: "")]
            }
            if let currentEmailAddresses = newValue?.emailAddresses {
                emailAddresses = currentEmailAddresses
            } else {
                emailAddresses = [.init(label: "Email Addresses", value: "")]
            }
            if let currentPhoneNumber = newValue?.phoneNumbers {
                phoneNumbers = currentPhoneNumber
            } else {
                phoneNumbers = [.init(label: "Phone Numbers", value: "")]
            }
            if let currentOtherContactInfo = newValue?.otherContactInfo {
                otherContactInfo = currentOtherContactInfo
            } else {
                otherContactInfo = [.init(label: "Other Contact Info", value: "")]
            }
        }
    }
     private var isSettingProfilePictureForFirstTime = true

    private var cancellables: Set<AnyCancellable> = []

    init(storeManager: OCKSynchronizedStoreManager? = nil) {
        self.storeManager = storeManager ?? StoreManagerKey.defaultValue
        reloadViewModel()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadViewModel(_:)),
                                               // swiftlint:disable:next line_length
                                               name: Notification.Name(rawValue: Constants.completedFirstSyncAfterLogin),
                                               object: nil)
    }

    // MARK: Helpers (private)
    private func clearSubscriptions() {
        cancellables = []
    }

    @objc private func reloadViewModel(_ notification: Notification? = nil) {
        Task {
            _ = await findAndObserveCurrentProfile()
        }
    }

    @MainActor
    private func findAndObserveCurrentProfile() async {
        guard let uuid = try? Utility.getRemoteClockUUID() else {
            Logger.profile.error("Could not get remote uuid for this user.")
            return
        }
        clearSubscriptions()

        do {
            try await fetchProfilePicture()
        } catch {
            Logger.profile.error("Could not fetch profile image: \(error)")
        }

        // Build query to search for OCKPatient
        // swiftlint:disable:next line_length
        var queryForCurrentPatient = OCKPatientQuery(for: Date()) // This makes the query for the current version of Patient
        queryForCurrentPatient.ids = [uuid.uuidString] // Search for the current logged in user

        do {
            guard let appDelegate = AppDelegateKey.defaultValue,
                  let foundPatient = try await appDelegate.store?.fetchPatients(query: queryForCurrentPatient),
                  let currentPatient = foundPatient.first else {
                // swiftlint:disable:next line_length
                Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved.")
                return
            }
            self.observePatient(currentPatient)

            // Query the contact also so the user can edit
            var queryForCurrentContact = OCKContactQuery(for: Date())
            queryForCurrentContact.ids = [uuid.uuidString]
            guard let foundContact = try await appDelegate.store?.fetchContacts(query: queryForCurrentContact),
                let currentContact = foundContact.first else {
                // swiftlint:disable:next line_length
                Logger.profile.error("Error: Could not find contact with id \"\(uuid)\". It's possible they have never been saved.")
                return
            }
            self.observeContact(currentContact)

        } catch {
            // swiftlint:disable:next line_length
            Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved. Query error: \(error.localizedDescription)")
        }
    }

    @MainActor
        private func findAndObserveCurrentContact() async {
            guard let uuid = try? Utility.getRemoteClockUUID() else {
                Logger.profile.error("Could not get remote uuid for this user.")
                return
            }
            clearSubscriptions()

            // Build query to search for OCKPatient
            // swiftlint:disable:next line_length
            var queryForCurrentPatient = OCKPatientQuery(for: Date()) // This makes the query for the current version of Patient
            queryForCurrentPatient.ids = [uuid.uuidString] // Search for the current logged in user
            do {
                guard let appDelegate = AppDelegateKey.defaultValue,
                      let foundPatient = try await appDelegate.store?.fetchPatients(query: queryForCurrentPatient),
                    let currentPatient = foundPatient.first else {
                    // swiftlint:disable:next line_length
                    Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved.")
                    return
                }
                self.observePatient(currentPatient)

                // Query the contact also so the user can edit
                var queryForCurrentContact = OCKContactQuery(for: Date())
                queryForCurrentContact.ids = [uuid.uuidString]
                guard let foundContact = try await appDelegate.store?.fetchContacts(query: queryForCurrentContact),
                    let currentContact = foundContact.first else {
                    // swiftlint:disable:next line_length
                    Logger.profile.error("Error: Could not find contact with id \"\(uuid)\". It's possible they have never been saved.")
                    return
                }
                self.observeContact(currentContact)

                try? await fetchProfilePicture()
            } catch {
                // swiftlint:disable:next line_length
                Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved. Query error: \(error.localizedDescription)")
            }
        }

    @MainActor
    private func observeContact(_ contact: OCKContact) {

        storeManager.publisher(forContact: contact,
                               categories: [.add, .update, .delete])
            .sink { [weak self] in
                self?.contact = $0 as? OCKContact
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func observePatient(_ patient: OCKPatient) {
        storeManager.publisher(forPatient: patient,
                               categories: [.add, .update, .delete])
            .sink { [weak self] in
                self?.patient = $0 as? OCKPatient
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func fetchProfilePicture() async throws {

         // Profile pics are stored in Parse User.
        guard let currentUser = try await User.current?.fetch() else {
            Logger.profile.error("User is not logged in")
            return
        }

        if let pictureFile = currentUser.profilePicture {

            // Download picture from server if needed
            do {
                let profilePicture = try await pictureFile.fetch()
                guard let path = profilePicture.localURL?.relativePath else {
                    Logger.profile.error("Could not find relative path for profile picture.")
                    return
                }
                self.profileUIImage = UIImage(contentsOfFile: path)
            } catch {
                Logger.profile.error("Could not fetch profile picture: \(error.localizedDescription).")
            }
        }
        self.isSettingProfilePictureForFirstTime = false
    }

}

// MARK: User intentional behavior
extension ProfileViewModel {
    @MainActor
    func saveProfile() async {
        alertMessage = "All changes saved successfully!"
        do {
            try await savePatient()
            try await saveContact()
        } catch {
            alertMessage = "Could not save profile: \(error)"
        }
        isShowingSaveAlert = true // Make alert pop up for user.
    }

    @MainActor
    // swiftlint:disable:next cyclomatic_complexity
    func savePatient() async throws {
        if var patientToUpdate = patient {
            // If there is a currentPatient that was fetched, check to see if any of the fields changed
            var patientHasBeenUpdated = false

            if patient?.name.givenName != firstName {
                patientHasBeenUpdated = true
                patientToUpdate.name.givenName = firstName
            }

            if patient?.name.familyName != lastName {
                patientHasBeenUpdated = true
                patientToUpdate.name.familyName = lastName
            }

            if patient?.birthday != birthday {
                patientHasBeenUpdated = true
                patientToUpdate.birthday = birthday
            }

            if patient?.sex != sex {
                patientHasBeenUpdated = true
                patientToUpdate.sex = sex
            }

            if patient?.allergies != allergies {
                patientHasBeenUpdated = true
                patientToUpdate.allergies = allergies
            }

            let notes = [OCKNote(author: firstName,
                                 title: "New Note",
                                 content: note)]
            if patient?.notes != notes {
                patientHasBeenUpdated = true
                patientToUpdate.notes = notes
            }

            if patientHasBeenUpdated {
                let updated = try await storeManager.store.updateAnyPatient(patientToUpdate)
                Logger.profile.info("Successfully updated patient")
                guard let updatedPatient = updated as? OCKPatient else {
                    Logger.profile.error("Could not cast to OCKPatient")
                    return
                }
                self.patient = updatedPatient
            }

        } else {
            guard let remoteUUID = try? Utility.getRemoteClockUUID().uuidString else {
                Logger.profile.error("The user currently is not logged in")
                return
            }

            var newPatient = OCKPatient(id: remoteUUID,
                                        givenName: firstName,
                                        familyName: lastName)
            newPatient.birthday = birthday

            // This is new patient that has never been saved before
            let addedPatient = try await storeManager.store.addAnyPatient(newPatient)
            Logger.profile.info("Succesffully saved new patient")
            guard let addedOCKPatient = addedPatient as? OCKPatient else {
                Logger.profile.error("Could not cast to OCKPatient")
                return
            }
            self.patient = addedOCKPatient
            self.observePatient(addedOCKPatient)
        }
    }

    @MainActor
    // swiftlint:disable:next cyclomatic_complexity
    func saveContact() async throws {

        if var contactToUpdate = contact {
            // If a current contact was fetched, check to see if any of the fields have changed
            var contactHasBeenUpdated = false

            // Since OCKPatient was updated earlier, we should compare against this name
            if let patientName = patient?.name,
                contact?.name != patient?.name {
                contactHasBeenUpdated = true
                contactToUpdate.name = patientName
            }

            // Create a mutable temp address to compare
            let potentialAddress = OCKPostalAddress()
            potentialAddress.street = street
            potentialAddress.city = city
            potentialAddress.state = state
            potentialAddress.postalCode = zipcode

            if contact?.address != potentialAddress {
                contactHasBeenUpdated = true
                contactToUpdate.address = potentialAddress
            }

            if contact?.phoneNumbers != phoneNumbers {
                contactHasBeenUpdated = true
                contactToUpdate.phoneNumbers = phoneNumbers
            }

            if contact?.messagingNumbers != messagingNumbers {
                contactHasBeenUpdated = true
                contactToUpdate.messagingNumbers = messagingNumbers
            }

            if contact?.emailAddresses != emailAddresses {
                contactHasBeenUpdated = true
                contactToUpdate.emailAddresses = emailAddresses
            }

            if contact?.otherContactInfo != otherContactInfo {
                contactHasBeenUpdated = true
                contactToUpdate.otherContactInfo = otherContactInfo
            }

            if contactHasBeenUpdated {
                let updated = try await storeManager.store.updateAnyContact(contactToUpdate)
                Logger.profile.info("Successfully updated contact")
                guard let updatedContact = updated as? OCKContact else {
                    Logger.profile.error("Could not cast to OCKContact")
                    return
                }
                self.contact = updatedContact
            }
        } else {

            guard let remoteUUID = try? Utility.getRemoteClockUUID().uuidString else {
                Logger.profile.error("The user currently is not logged in")
                return
            }

            guard let patientName = self.patient?.name else {
                Logger.profile.info("The patient did not have a name.")
                return
            }

            // Added code to create a contact for the respective signed up user
            let newContact = OCKContact(id: remoteUUID,
                                        name: patientName,
                                        carePlanUUID: nil)

            guard let addedContact = try await storeManager.store.addAnyContact(newContact) as? OCKContact else {
                Logger.profile.error("Could not cast to OCKContact")
                return
            }
            self.contact = addedContact
            self.observeContact(addedContact)
        }

    }
}
