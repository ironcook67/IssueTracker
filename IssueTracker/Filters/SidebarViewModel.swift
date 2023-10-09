//
//  SidebarViewModel.swift
//  IssueTracker
//
//  Created by Chon Torres on 10/8/23.
//

import Foundation
import CoreData

extension SidebarView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        var dataManager: DataManager

        private let tagsContoller: NSFetchedResultsController<Tag>
        @Published var tags = [Tag]()

        @Published var tagToRename: Tag?
        @Published var renamingTag = false
        @Published var tagName = ""

        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(id: tag.uuid, name: tag.name, icon: "tag", tag: tag)
            }
        }

        init(dataManager: DataManager) {
            self.dataManager = dataManager

            let request = Tag.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name_, ascending: true)]

            tagsContoller = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataManager.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            tagsContoller.delegate = self

            do {
                try tagsContoller.performFetch()
                tags = tagsContoller.fetchedObjects ?? []
            } catch {
                print("Failed to fetch tags")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTags = controller.fetchedObjects as? [Tag] {
                tags = newTags
            }
        }

        func delete(_ offsets: IndexSet) {
            for offset in offsets {
                let item = tags[offset]
                dataManager.delete(item)
            }
        }

        func delete(_ filter: Filter) {
            guard let tag = filter.tag else { return }
            dataManager.delete(tag)
            dataManager.save()
        }

        func rename(_ filter: Filter) {
            tagToRename = filter.tag
            tagName = filter.name
            renamingTag = true
        }

        func completeRename() {
            tagToRename?.name = tagName
            dataManager.save()
        }
    }
}
