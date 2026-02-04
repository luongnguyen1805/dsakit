//
//  ViewLog.swift
//  DSAKit
//
//  Created by admin on 2/4/26.
//

import Foundation
import SwiftUI

extension View {
    func logChanges() -> some View {
        #if DEBUG
        Self._printChanges()
        #endif
        return self
    }
}
