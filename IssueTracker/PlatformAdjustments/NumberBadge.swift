//
//  NumberBadge.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/24.
//

import SwiftUI

extension View {
    func numberBadge(_ number: Int) -> some View {
#if os(watchOS)
        self
#else
        self.badge(number)
#endif // os(watchOS)
    }
}
