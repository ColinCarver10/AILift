//
//  MyContactView.swift
//  OCKSample
//
//  Created by Corey Baker on 11/8/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import UIKit
import CareKit
import CareKitStore
import os.log

struct MyContactView: UIViewControllerRepresentable {
    @State var storeManager = StoreManagerKey.defaultValue

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = MyContactViewController(storeManager: storeManager)
        return UINavigationController(rootViewController: viewController)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: Context) {}
}

struct MyContactView_Previews: PreviewProvider {

    static var previews: some View {
        MyContactView(storeManager: Utility.createPreviewStoreManager())
            .accentColor(Color(TintColorKey.defaultValue))
    }
}
