//
//  TintColorKey.swift
//  OCKSample
//
//  Created by Corey Baker on 10/16/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import SwiftUI

struct TintColorKey: EnvironmentKey {
    static var defaultValue: UIColor {
        #if os(iOS)
        return UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0.9203757644, green: 0.368465066, blue: 0.1538978517, alpha: 1) : #colorLiteral(red: 0.8012496829, green: 0.7715370059, blue: 0.7244806886, alpha: 1) }
        #else
        return #colorLiteral(red: 0.9203757644, green: 0.368465066, blue: 0.1538978517, alpha: 1)
        #endif
    }
}

extension EnvironmentValues {
    var tintColor: UIColor {
        self[TintColorKey.self]
    }
}
