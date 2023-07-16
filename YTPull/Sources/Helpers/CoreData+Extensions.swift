//
//  CoreData+Extensions.swift
//  YTPull
//
//  Created by Huy Nguyen on 07/07/2023.
//

import Foundation
import CoreData

extension NSPersistentContainer {
    static var inMemoryReadonlyContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: "EmptyStore", managedObjectModel: VideoStore.model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, _ in }
        return container
    }

    func loadStore() throws {
        var loadError: Swift.Error?
        loadPersistentStores { description, error in
            if let error = error {
                debugPrint("Failed to load persistent store \(description) with error: \(error)")
                loadError = error
            }
        }
        if let error = loadError {
            throw error
        }
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
}

extension NSEntityDescription {
    convenience init<T>(class customClass: T.Type) where T: NSManagedObject {
        self.init()
        self.name = String(describing: customClass)
        self.managedObjectClassName = T.self.description()
    }
}

extension NSAttributeDescription {
    convenience init(name: String, type: NSAttributeType, _ configure: (NSAttributeDescription) -> Void = { _ in }) {
        self.init()
        self.name = name
        self.attributeType = type
        configure(self)
    }
}

extension NSManagedObjectContext {
    func fetch<T: NSManagedObject>(_ entity: T.Type, _ configure: (NSFetchRequest<T>) -> Void = { _ in }) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        configure(request)
        return try fetch(request)
    }

    func fetch<T: NSManagedObject, Value>(_ entity: T.Type, sortedBy keyPath: KeyPath<T, Value>, ascending: Bool = true,  _ configure: (NSFetchRequest<T>) -> Void = { _ in }) throws -> [T] {
        try fetch(entity) {
            $0.sortDescriptors = [NSSortDescriptor(keyPath: keyPath, ascending: ascending)]
        }
    }
}
