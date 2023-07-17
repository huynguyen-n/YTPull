//
//  VideoStore.swift
//  YTPull
//
//  Created by Huy Nguyen on 03/07/2023.
//

import Foundation
import CoreData

let databaseFilename = "YTPull.sqlite"

final class VideoStore {

    let storeURL: URL

    let container: NSPersistentContainer

    let backgroundContext: NSManagedObjectContext

    private var isSaveScheduled = false

    private let queue = DispatchQueue(label: "com.github.huynguyen-n.YTPull.video-store")

    private let databaseURL: URL

    static var shared = VideoStore.makeDefault()

    var viewContext: NSManagedObjectContext { container.viewContext }

    init(storeURL: URL) throws {
        var isDirectory: ObjCBool = ObjCBool(false)
        let fileExists = Files.fileExists(atPath: storeURL.path, isDirectory: &isDirectory)
        let isArchive = fileExists && !isDirectory.boolValue
        self.storeURL = storeURL

        if !isArchive {
            self.databaseURL = storeURL.appending(filename: databaseFilename)
            if !Files.fileExists(atPath: storeURL.path) {
                try Files.createDirectory(at: storeURL, withIntermediateDirectories: false)
            }
        } else {
            self.databaseURL = URL.temp.appending(filename: databaseFilename)
        }
        self.container = VideoStore.makeContainer(databaseURL: databaseURL)
        try container.loadStore()
        self.backgroundContext = container.newBackgroundContext()
    }

    private static func makeDefault() -> VideoStore {
        let storeURL = URL.logs.appending(directory: "current.YTPull")
        guard let store = try? VideoStore(storeURL: storeURL) else {
            return VideoStore(inMemoryStore: storeURL) // Should never happen
        }
        return store
    }

    private static func makeContainer(databaseURL: URL) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: databaseURL.lastPathComponent, managedObjectModel: Self.model)
        let store = NSPersistentStoreDescription(url: databaseURL)
        store.setValue("DELETE" as NSString, forPragmaNamed: "journal_mode")
        container.persistentStoreDescriptions = [store]
        return container
    }

    init(inMemoryStore storeURL: URL) {
        self.storeURL = storeURL
        self.databaseURL = storeURL.appending(directory: databaseFilename)
        self.container = .inMemoryReadonlyContainer
        self.backgroundContext = container.newBackgroundContext()
    }
}

// MARK: - VideoStore (Accessing)

extension VideoStore {

    /// Returns all recorded videos, least recent videos come first.
    func allVideos() throws -> [VideoEntity] {
        try viewContext.fetch(VideoEntity.self, sortedBy: \.createdAt, ascending: false)
    }

    /// Stores the given video.
    /// - Parameters:
    ///   - createdAt: default is current date time
    ///   - id: video id
    ///   - title: video title
    ///   - channel: channel of video
    ///   - url: download url of video
    ///   - thumbnail: thumbnail
    ///   - type: media type, audio/video
    ///   - storedURL: media file location
    func storeVideo(createdAt: Date = .now, id: String, title: String, channel: String, url: String, thumbnail: String, type: MediaType, storedURL: String = "") {
        perform { _ in
            let video = VideoEntity(context: self.backgroundContext)
            video.createdAt = createdAt
            video.id = id
            video.title = title
            video.channel = channel
            video.url = url
            video.thumbnail = thumbnail
            video.type = Int16(type.rawValue)
            video.storedURL = storedURL
        }
    }

    /// Update `storedURL` when video finished download or extract
    /// - Parameters:
    ///   - storedURL: media file location
    ///   - video: video entity
    func update(storedURL: String, for video: VideoEntity) {
        perform {
            guard let video = $0.object(with: video.objectID) as? VideoEntity else { return }
            video.storedURL = storedURL
        }
    }

    /// Removes all of the previously recorded videos.
    func removeAllVideos() {
        perform { _ in
            (try? self.allVideos())?.forEach { if let url = URL(string: $0.storedURL) { try? Files.removeItem(at: url) } }
            try? self.deleteEntities(for: VideoEntity.fetchRequest())
        }
    }

    /// Removes a specific video.
    func removeVideo(_ video: VideoEntity) {
        perform { _ in
            guard let url = URL(string: video.storedURL) else { return }
            do {
                try self._removeVideos(withIDs: [video.id])
                try Files.removeItem(at: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func _removeVideos(withIDs videoIDs: Set<String>) throws {
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoEntity")
        let predicate = NSPredicate(format: "id IN %@", videoIDs)
        deleteRequest.predicate = predicate
        try deleteEntities(for: deleteRequest)
    }

    private func deleteEntities(for fetchRequest: NSFetchRequest<NSFetchRequestResult>) throws {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        let result = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
        guard let ids = result?.result as? [NSManagedObjectID] else { return }

        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [backgroundContext])

        viewContext.perform {
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [self.viewContext])
        }
    }

    private func perform(_ changes: @escaping (NSManagedObjectContext) -> Void) {
        backgroundContext.perform {
            changes(self.backgroundContext)
            self.setNeedsSave()
        }
    }

    private func setNeedsSave() {
        guard !isSaveScheduled else { return }
        isSaveScheduled = true
        queue.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
            self?.flush()
        }
    }

    private func flush() {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            if self.isSaveScheduled, Files.fileExists(atPath: self.storeURL.path) {
                self.saveAndReset()
                self.isSaveScheduled = false
            }
        }
    }

    private func saveAndReset() {
        do {
            try backgroundContext.save()
        } catch {
            debugPrint(error)
        }
        backgroundContext.reset()
    }
}
