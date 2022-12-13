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
        return UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 0.1551532447, green: 0.1678296328, blue: 0.1861946285, alpha: 1) : #colorLiteral(red: 0.1529504359, green: 0.1473429799, blue: 0.1385854781, alpha: 1) }
        #else
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        #endif
    }
}

extension EnvironmentValues {
    var tintColor: UIColor {
        self[TintColorKey.self]
    }
}
