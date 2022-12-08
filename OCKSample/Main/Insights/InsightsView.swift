//
//  InsightsView.swift
//  OCKSample
//
//  Created by Corey Baker on 12/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import SwiftUI

struct InsightsView: UIViewControllerRepresentable {
    @State var storeManager = StoreManagerKey.defaultValue

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = InsightsViewController(storeManager: storeManager)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: Context) {}
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
