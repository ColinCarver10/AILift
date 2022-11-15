//
//  MyContactViewController.swift
//  OCKSample
//
//  Created by Corey Baker on 11/8/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import UIKit
import CareKitStore
import CareKitUI
import CareKit
import Contacts
import ContactsUI
import ParseSwift
import ParseCareKit
import os.log

class MyContactViewController: OCKListViewController {

    fileprivate weak var contactDelegate: OCKContactViewControllerDelegate?
    fileprivate var contacts = [OCKAnyContact]()

    /// The manager of the `Store` from which the `Contact` data is fetched.
    public let storeManager: OCKSynchronizedStoreManager

    /// Initialize using a store manager. All of the contacts in the store manager will be queried and dispalyed.
    ///
    /// - Parameters:
    ///   - storeManager: The store manager owning the store whose contacts should be displayed.
    public init(storeManager: OCKSynchronizedStoreManager) {
        self.storeManager = storeManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            try? await fetchContacts()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        Task {
            try? await fetchContacts()
        }
    }

    override func appendViewController(_ viewController: UIViewController, animated: Bool) {
        super.appendViewController(viewController, animated: animated)
        // Make sure this contact card matches app style when possible
        if let carekitView = viewController.view as? OCKView {
            carekitView.customStyle = CustomStylerKey.defaultValue
        }
    }

    @MainActor
    func fetchContacts() async throws {

        guard User.current != nil,
              let personUUIDString = try? Utility.getRemoteClockUUID().uuidString else {
            Logger.myContact.error("User not logged in")
            self.contacts.removeAll()
            return
        }

        /*
         XTODO: How would you modify this query to only fetch the contact that belongs to this device?
         
         Hint 1: There are multiple ways to do this. You can modify the query
         below which can work.
         
         Hint2: Look at the other queries in the app related to the uuid of the
         user/patient who's signed in.
         
         Hint3: You should have a warning currently, solving this properly would
         get rid of the warning without changing the line the warning is on.
         */
        var query = OCKContactQuery(for: Date())
        query.sortDescriptors.append(.familyName(ascending: true))
        query.sortDescriptors.append(.givenName(ascending: true))
        query.ids = [personUUIDString]

        self.contacts = try await storeManager.store.fetchAnyContacts(query: query)
        self.displayContacts()
    }

    @MainActor
    func displayContacts() {
        self.clear()
        for contact in self.contacts {
            let contactViewController = OCKDetailedContactViewController(contact: contact,
                                                                         storeManager: storeManager)
            contactViewController.delegate = self.contactDelegate
            self.appendViewController(contactViewController, animated: false)
        }
    }
}

extension MyContactViewController: OCKContactViewControllerDelegate {

    // swiftlint:disable:next line_length
    func contactViewController<C, VS>(_ viewController: CareKit.OCKContactViewController<C, VS>, didEncounterError error: Error) where C: CareKit.OCKContactController, VS: CareKit.OCKContactViewSynchronizerProtocol {
        Logger.myContact.error("\(error.localizedDescription)")
    }
}
