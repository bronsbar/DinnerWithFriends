//
//  BackgroundPictures+CoreDataProperties.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 21/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//
//

import Foundation
import CoreData


extension BackgroundPictures {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BackgroundPictures> {
        return NSFetchRequest<BackgroundPictures>(entityName: "BackgroundPictures")
    }

    @NSManaged public var ckChangeTag: NSData?
    @NSManaged public var ckDatabase: NSData?
    @NSManaged public var ckZone: NSData?
    @NSManaged public var created: NSDate?
    @NSManaged public var metaData: NSData?
    @NSManaged public var modified: NSDate?
    @NSManaged public var picture: NSData?
    @NSManaged public var pictureName: String?
    @NSManaged public var recordName: String?
    @NSManaged public var recordType: String?

}
