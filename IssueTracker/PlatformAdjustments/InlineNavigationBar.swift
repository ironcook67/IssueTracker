//
//  InlineNavigationBar.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/3/24.
//

import SwiftUI

extension View {
    func inlineNavigationBar() -> some View {
#if os(macOS)
        self
#else
        self.navigationBarTitleDisplayMode(.inline)
#endif
    }
}
