//
//  DinnerItems+CoreDataProperties.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 11/02/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//
//

import Foundation
import CoreData


extension DinnerItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DinnerItems> {
        return NSFetchRequest<DinnerItems>(entityName: "DinnerItems")
    }

    @NSManaged public var category: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var imageTumbnail: NSData?
    @NSManaged public var metaData: NSData?
    @NSManaged public var modifiedAt: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var privateUse: Bool
    @NSManaged public var rating: Int64
    @NSManaged public var recordID: NSData?
    @NSManaged public var recordName: String?
    @NSManaged public var url: URL?
    @NSManaged public var imageUrl: URL?
    @NSManaged public var dinners: NSSet?

}

// MARK: Generated accessors for dinners
extension DinnerItems {

    @objc(addDinnersObject:)
    @NSManaged public func addToDinners(_ value: Dinners)

    @objc(removeDinnersObject:)
    @NSManaged public func removeFromDinners(_ value: Dinners)

    @objc(addDinners:)
    @NSManaged public func addToDinners(_ values: NSSet)

    @objc(removeDinners:)
    @NSManaged public func removeFromDinners(_ values: NSSet)

}
