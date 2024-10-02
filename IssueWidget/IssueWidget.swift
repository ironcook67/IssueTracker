//
//  IssueWidget.swift
//  IssueWidget
//
//  Created by Chon Torres on 9/29/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
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

struct IssueWidgetEntryView: View {
    var entry: Provider.Entry

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

struct IssueWidget: Widget {
    let kind: String = "IssueWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                IssueWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                IssueWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    IssueWidget()
} timeline: {
    SimpleEntry(date: .now, issues: [.example])
    SimpleEntry(date: .now, issues: [.example])
}
