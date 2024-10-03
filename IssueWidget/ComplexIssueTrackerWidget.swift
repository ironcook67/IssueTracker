//
//  ComplexIssueTrackerWidget.swift
//  IssueWidgetExtension
//
//  Created by Chon Torres on 10/3/24.
//

import WidgetKit
import SwiftUI

struct ComplexProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplexEntry {
        ComplexEntry(date: Date.now, issues: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplexEntry) -> Void) {
        let entry = ComplexEntry(date: .now, issues: loadIssues())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = ComplexEntry(date: .now, issues: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    func loadIssues() -> [Issue] {
        let dataManager = DataManager()
        let request = dataManager.fetchRequestForTopIssues(count: 7)
        return dataManager.results(for: request)
    }
}

struct ComplexEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct ComplexIssueWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var entry: ComplexProvider.Entry

    var issues: ArraySlice<Issue> {
        let issueCount: Int

        switch widgetFamily {
        case .systemSmall:
            issueCount = 1
        case .systemLarge, .systemExtraLarge:
            if (dynamicTypeSize < .xxLarge) {
                issueCount = 6
            } else {
                issueCount = 5
            }
        default:
            if (dynamicTypeSize < .xLarge) {
                issueCount = 3
            } else {
                issueCount = 2
            }
        }

        return entry.issues.prefix(issueCount)
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(issues) { issue in
                Link(destination: issue.objectID.uriRepresentation()) {
                    VStack(alignment: .leading) {
                        Text(issue.title)
                            .font(.headline)
                            .layoutPriority(1)

                        if issue.tags.isEmpty == false {
                            Text(issue.tagsList)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct ComplexIssueWidget: Widget {
    let kind: String = "ComplexIssueWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplexProvider()) { entry in
            if #available(iOS 17.0, *) {
                ComplexIssueWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ComplexIssueWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up next…")
        .description("Your most important issues.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemSmall) {
    ComplexIssueWidget()
} timeline: {
    ComplexEntry(date: .now, issues: [.example])
    ComplexEntry(date: .now, issues: [.example])
}
