//
//  Dinners+CoreDataProperties.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 21/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//
//

import Foundation
import CoreData


extension Dinners {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dinners> {
        return NSFetchRequest<Dinners>(entityName: "Dinners")
    }

    @NSManaged public var added: String?
    @NSManaged public var dinnerDate: NSDate?
    @NSManaged public var friends: NSObject?
    @NSManaged public var image: NSData?
    @NSManaged public var lastUpdated: NSDate?
    @NSManaged public var metaData: NSData?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var rating: Int16
    @NSManaged public var recordID: NSData?
    @NSManaged public var recordName: String?
    @NSManaged public var dinnerItems: NSSet?

}

// MARK: Generated accessors for dinnerItems
extension Dinners {

    @objc(addDinnerItemsObject:)
    @NSManaged public func addToDinnerItems(_ value: DinnerItems)

    @objc(removeDinnerItemsObject:)
    @NSManaged public func removeFromDinnerItems(_ value: DinnerItems)

    @objc(addDinnerItems:)
    @NSManaged public func addToDinnerItems(_ values: NSSet)

    @objc(removeDinnerItems:)
    @NSManaged public func removeFromDinnerItems(_ values: NSSet)

}
