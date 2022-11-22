//
//  OCKTask+Custom.swift
//  OCKSample
//
//  Created by Corey Baker on 11/7/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore

extension OCKTask {
    var card: CareKitCard {
        get {
            guard let cardInfo = userInfo?[Constants.card],
                  let careKitCard = CareKitCard(rawValue: cardInfo) else {
                return .grid // Default card if none was saved
            }
            return careKitCard // Saved card type
        }
        set {
            if userInfo == nil {
                // Initialize userInfo with empty dictionary
                userInfo = .init()
            }
            // Set the new card type
            userInfo?[Constants.card] = newValue.rawValue
        }
    }

    var survey: Survey {
        get {
            guard let surveyInfo = userInfo?[Constants.survey],
                  let surveyType = Survey(rawValue: surveyInfo) else {
                return .checkIn // Default survey if none was saved
            }
            return surveyType // Saved survey type
        }
        set {
            if userInfo == nil {
                // Initialize userInfo with empty dictionary
                userInfo = .init()
            }
            // Set the new card type
            userInfo?[Constants.survey] = newValue.rawValue
        }
    }
}
