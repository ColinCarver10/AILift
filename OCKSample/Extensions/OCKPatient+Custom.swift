//
//  OCKPatient+Custom.swift
//  OCKSample
//
//  Created by Colin  Carver  on 12/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import ParseSwift

extension OCKPatient {
    var workoutType: WorkoutType? {
        get {
            guard let typeString = userInfo?[Constants.userTypeKey],
                  let type = WorkoutType(rawValue: typeString) else {
                return nil
            }
            return type
        }
        set {
            guard let type = newValue else {
                userInfo?.removeValue(forKey: Constants.workoutTypeKey)
                return
            }
            if userInfo != nil {
                userInfo?[Constants.workoutTypeKey] = type.rawValue
            } else {
                userInfo = [Constants.workoutTypeKey: type.rawValue]
            }
        }
    }
}
