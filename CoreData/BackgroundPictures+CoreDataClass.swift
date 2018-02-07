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
import UIKit

@objc(BackgroundPictures)
public class BackgroundPictures: NSManagedObject, CloudKitManagedObject {
    
    var recordType: String { return PublicDatabaseTypes.backgroundPicture.rawValue}
    
//    func managedObjectToRecord(record: CKRecord?) -> CKRecord {
//        
//    }
    
    func updateWithRecord(record: CKRecord) {
        self.pictureName = record["name"] as? String
        self.modifiedAt = record["modifiedAt"] as? NSDate
        self.recordName = record.recordID.recordName
        self.recordID = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData
        if let asset = record.object(forKey: "picture") as? CKAsset,
            let data = NSData(contentsOf: asset.fileURL) {
            self.picture = data
        }
    }
    
    var recordID: NSData?
    
    // Convert NSData to UIImage
    func convertNSDataToUIImage(from dataFormat: NSData?) -> UIImage? {
        guard let imageData = dataFormat, let image = UIImage(data: imageData as Data) else {
            return nil
        }
        return image
        
    }
    // Convert UIImage to NSData
    func convertUIImageToNSData(from image: UIImage?) -> NSData? {
        guard let image = image, let imageData = UIImageJPEGRepresentation(image, 1.0) as NSData? else {
            return nil
        }
        return imageData
    }
    

}
