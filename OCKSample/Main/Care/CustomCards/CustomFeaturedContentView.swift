//
//  CustomFeaturedContentView.swift
//  OCKSample
//
//  Created by Corey Baker on 11/29/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//
import UIKit
import CareKit
import CareKitUI

/// A simple subclass to take control of what CareKit already gives us.
class CustomFeaturedContentView: OCKFeaturedContentView {
    var url: URL?

    // Need to override so we can become delegate when the user taps on card
    override init(imageOverlayStyle: UIUserInterfaceStyle = .unspecified) {
        // See that this always calls the super
        super.init(imageOverlayStyle: imageOverlayStyle)

        self.delegate = self
    }

    // A convenience initializer to make it easier to use our custom featured content
    convenience init(url: String, imageOverlayStyle: UIUserInterfaceStyle = .unspecified) {
        self.init(imageOverlayStyle: imageOverlayStyle)
        self.url = URL(string: url)
    }
}

/// Need to conform to delegate in order to be delegated to.
extension CustomFeaturedContentView: OCKFeaturedContentViewDelegate {

    func didTapView(_ view: OCKFeaturedContentView) {
        // When tapped open a URL.
        guard let url = url else {
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
}
