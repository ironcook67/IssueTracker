//
//  IssueWidgetBundle.swift
//  IssueWidget
//
//  Created by Chon Torres on 9/29/24.
//

import WidgetKit
import SwiftUI

@main
struct IssueWidgetBundle: WidgetBundle {
    var body: some Widget {
        SimpleIssueWidget()
        ComplexIssueWidget()
    }
}
