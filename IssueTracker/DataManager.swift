//
//  DataManager.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/5/23.
//

import CoreData
import StoreKit
import SwiftUI
import WidgetKit

enum SortType: String {
    case dateCreated = "creationDate_"
    case dateModified = "modificationDate_"
}

enum Status {
    case all, open, closed
}

/// An environment singleton responsible for managing our Core Data stack, including
/// handling saving, counting fetch requests, and dealing with sample data.
class DataManager: ObservableObject {

    /// The lone CloudKit container used to store all of our data
    let container: NSPersistentCloudKitContainer

    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?

    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?

    @Published var filterText = ""
    @Published var filterTokens = [Tag]()

    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortOldestFirst = false

    /// The UserDefaults suite where we;re saving user data
    let defaults: UserDefaults

    /// The StoreKit products we'veloaded for the store.
    @Published var products = [Product]()

    private var storeTask: Task<Void, Never>?
    private var saveTask: Task<Void, Error>?

    static var preview: DataManager = {
        let dataManager = DataManager(inMemory: true)
        dataManager.createSampleData()
        return dataManager
    }()

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }

        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name_ CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }

    /// Initializes a data controller, either in memory (for testing use such as previewing),
    /// or in permanent storage (for use in regular app runs).
    ///
    /// Defautls to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        storeTask = Task {
            await monitorTransactions()
        }

        // For testing and previewing purposes, create a temporary, in-memory database
        // in /dev/null so the database is destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        } else {
            let groupID = "group.com.chontorres.issuetracker"

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appending(path: "Main.sqlite")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )

        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )

        // Make sure that we watch iCloud for all changes to ensure the local UI is in sync
        // when a remote change happenes.
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )

        container.loadPersistentStores { [weak self] _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            if let description = self?.container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

                if let coordinator = self?.container.persistentStoreCoordinator {
                    self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(
                        forStoreWith: description,
                        coordinator: coordinator
                    )

                    self?.spotlightDelegate?.startSpotlightIndexing()
                }
            }

#if DEBUG
            // Used for UI Testing. Delete all of the data to start with a clean slate
            // and turn off aninmation for faster tests.
            if CommandLine.arguments.contains("enable-testing") {
                self?.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
#endif  // DEBUG
        }
    }

    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    /// Saves our Core Data context iff there are changes, this silently ignores
    /// any errors cause by saving. This should be fine because all of our
    /// attributes are optional.
    func save() {
        saveTask?.cancel()

        if container.viewContext.hasChanges {
            try? container.viewContext.save()

            // Force the widget to update and stay in sync with the app.
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    // Batch up changes to avoid spamming save.
    func queueSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        // Important: When performing a batch delete, we need to make sure we read the
        // result back then merge all the changes back into our live view context so
        // that the two stay in sync.
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)

        save()
    }

    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.tags)

        return difference.sorted()
    }

    /// Runs a fetch request with various predicates that filter the user's issues based on
    /// tag, title, and content text, search tokens, priority, and completion status.
    /// - Returns: An array of all matching issues.
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()

        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags_ CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate_ > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }

        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title_ CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content_ CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate]
            )
            predicates.append(combinedPredicate)
        }

        if filterTokens.isEmpty == false {
            let tokenPredicate = NSPredicate(format: "ANY tags_ in %@", filterTokens)
            predicates.append(tokenPredicate)
        }

        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityFilter)
            }

            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }

        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortOldestFirst)]

        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues
    }

    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = NSLocalizedString("New issue", comment: "Create a new issue.")
        issue.creationDate = .now
        issue.priority = 1

        // If a tag is currently selected, create the new issue with that tag.
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }

        save()

        selectedIssue = issue
    }

    func newTag() -> Bool {
        var shouldCreate = fullVersionUnlocked

        // Allow up to three tags before prompting the user for a purchase.
        if shouldCreate == false {
            shouldCreate = count(for: Tag.fetchRequest()) < 3
        }

        guard shouldCreate else { return false }

        let tag = Tag(context: container.viewContext)
        tag.uuid = UUID()
        tag.name = NSLocalizedString("New tag", comment: "Create a new tag.")
        save()

        return true
    }
}

extension DataManager {
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    func issue(with uniqueIdentifier: String) -> Issue? {
        guard let url = URL(string: uniqueIdentifier) else { return nil }
        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Issue
    }
}

extension DataManager {
    func fetchRequestForTopIssues(count: Int) -> NSFetchRequest<Issue> {
        let request = Issue.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Issue.priority, ascending: false)
        ]

        request.fetchLimit = count
        return request
    }

    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
}

extension DataManager {
    func createSampleData() {
        let viewContext = container.viewContext

        for tagIndex in 1...5 {
            let tag = Tag(context: viewContext)
            tag.uuid = UUID()
            tag.name = "Tag \(tagIndex)"

            for issueIndex in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagIndex)-\(issueIndex)"
                issue.content = "Description goes here."
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues_(issue)
            }
        }

        try? viewContext.save()
    }
}
