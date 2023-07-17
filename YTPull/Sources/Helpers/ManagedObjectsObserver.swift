//
//  ManagedObjectsObserver.swift
//  YTPull
//
//  Created by Huy Nguyen on 08/07/2023.
//

import Foundation
import CoreData

final class ManagedObjectsObserver<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    @Published private(set) var objects: [T] = []

    private let controller: NSFetchedResultsController<T>

    init(request: NSFetchRequest<T>,
         context: NSManagedObjectContext,
         cacheName: String? = nil) {
        self.controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: cacheName)
        super.init()

        try? controller.performFetch()
        objects = controller.fetchedObjects ?? []

        controller.delegate = self
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objects = self.controller.fetchedObjects ?? []
    }
}

extension ManagedObjectsObserver where T == VideoEntity {
    static func videos(for context: NSManagedObjectContext) -> ManagedObjectsObserver {
        let request = NSFetchRequest<VideoEntity>(entityName: "\(VideoEntity.self)")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \VideoEntity.createdAt, ascending: false)]

        return ManagedObjectsObserver(request: request, context: context, cacheName: "com.github.pulse.pins-cache")
    }
}
