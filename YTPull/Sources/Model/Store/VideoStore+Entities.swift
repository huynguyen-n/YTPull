//
//  VideoStore+Entities.swift
//  YTPull
//
//  Created by Huy Nguyen on 07/07/2023.
//

import Foundation
import CoreData

final class VideoEntity: NSManagedObject {
    @NSManaged public var createdAt: Date
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var channel: String
    @NSManaged public var url: String
    @NSManaged public var thumbnail: String
    @NSManaged public var type: Int16
    @NSManaged public var storedURL: String
}

extension VideoStore {

    /// Returns Core Data model used by the store.
    static let model: NSManagedObjectModel = {
        typealias Entity = NSEntityDescription
        typealias Attribute = NSAttributeDescription

        let video = Entity(class: VideoEntity.self)

        video.properties = [
            Attribute(name: "id", type: .stringAttributeType),
            Attribute(name: "createdAt", type: .dateAttributeType),
            Attribute(name: "title", type: .stringAttributeType),
            Attribute(name: "channel", type: .stringAttributeType),
            Attribute(name: "url", type: .stringAttributeType),
            Attribute(name: "thumbnail", type: .stringAttributeType),
            Attribute(name: "type", type: .integer16AttributeType),
            Attribute(name: "storedURL", type: .stringAttributeType)
        ]

        let model = NSManagedObjectModel()
        model.entities = [video]
        return model
    }()
}
