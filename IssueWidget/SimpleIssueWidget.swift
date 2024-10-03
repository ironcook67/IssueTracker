//
//  IssueWidget.swift
//  IssueWidget
//
//  Created by Chon Torres on 9/29/24.
//

import WidgetKit
import SwiftUI

struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date.now, issues: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: .now, issues: loadIssues())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: .now, issues: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    func loadIssues() -> [Issue] {
        let dataManager = DataManager()
        let request = dataManager.fetchRequestForTopIssues(count: 1)
        return dataManager.results(for: request)
    }
 }

struct SimpleEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct SimpleIssueWidgetEntryView: View {
    var entry: SimpleProvider.Entry

    var body: some View {
        VStack {
            Text("Up next…")
                .font(.title)

            if let issue = entry.issues.first {
                Text(issue.title)
            } else {
                Text("Nothing!")
            }
        }
    }
}

struct SimpleIssueWidget: Widget {
    let kind: String = "SimpleIssueWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            if #available(iOS 17.0, *) {
                SimpleIssueWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SimpleIssueWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up next…")
        .description("Your #1 top-priority issue.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    SimpleIssueWidget()
} timeline: {
    SimpleEntry(date: .now, issues: [.example])
    SimpleEntry(date: .now, issues: [.example])
}
