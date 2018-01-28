//
//  BackgroundPictures+CoreDataClass.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 21/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(BackgroundPictures)
public class BackgroundPictures: NSManagedObject, CloudKitManagedObject {
    var lastUpdated: NSDate?
    
    var recordType: String { return PublicDatabaseTypes.backgroundPicture.rawValue}
    
//    func managedObjectToRecord(record: CKRecord?) -> CKRecord {
//        
//    }
    
    func updateWithRecord(record: CKRecord) {
        self.pictureName = record["name"] as? String
        self.lastUpdated = record["lastUpdate"] as? NSDate
        self.recordName = record.recordID.recordName
        self.recordID = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData
        // still to assign the picture to the managed object
    }
    
    var recordID: NSData?
    

}
