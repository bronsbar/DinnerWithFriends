//
//  DinnerItems+CoreDataClass.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 21/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//
//

import Foundation
import MobileCoreServices
import UIKit
import CoreData
import CloudKit

@objc(DinnerItems)
final public class DinnerItems: NSManagedObject, RootManagedObject, CloudKitManagedObject {
    var lastUpdate: NSDate?
    
    
    var recordType : String { return ModelObjectType.dinnerItems.rawValue}
    
    // func to comply with CloudKitMagnagedObject Protocol
    func managedObjectToRecord(record: CKRecord?) -> CKRecord {
        guard let name = name, let createdAt = createdAt, let modifiedAt = modifiedAt else {
            fatalError("Required Properties for record not set")
        }
        let dinnerItemRecord = cloudKitRecord(record: record)
        recordName = dinnerItemRecord.recordID.recordName
        recordID = NSKeyedArchiver.archivedData(withRootObject: dinnerItemRecord.recordID) as NSData
        dinnerItemRecord["name"] = name as NSString
        dinnerItemRecord["createdAt"] = createdAt
        dinnerItemRecord["modifiedAt"] = modifiedAt
        if let category = category {
            dinnerItemRecord["category"] = category as NSString
        }
        if let notes = notes {
            dinnerItemRecord["notes"] = notes as NSString
        }
        
        return dinnerItemRecord
    }
    // func to comply with CloudKitMagnagedObject Protocol
    func updateWithRecord(record: CKRecord) {
        self.name = record["name"] as? String
        self.modifiedAt = record["modifiedAt"] as? NSDate
        self.createdAt = record["createdAt"] as? NSDate
        self.recordName = record.recordID.recordName
        self.recordID = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData
        if let asset = record.object(forKey: "image") as? CKAsset,
            let data = NSData(contentsOf: asset.fileURL) {
            self.image = data
        }
        self.category = record["category"] as? String
        self.notes = record["notes"] as? String
        self.rating = record["rating"] as! Int64
        
        
    }
    
    
    // enum with dinnerItem Categories
    enum DinnerItemCategory: String {
        case Starter = "Starter"
        case Main = "Main Course"
        case Dessert = "Dessert"
        case Apperitive = "Apperitive"
        case Wine = "Wine"
        
    }
    // fetch the dinnerItems in Core Data
    func fetchDinnerItems(managedContext: NSManagedObjectContext ) -> [DinnerItems]? {
        let itemListFetchRequest : NSFetchRequest<DinnerItems> = DinnerItems.fetchRequest()
        itemListFetchRequest.predicate = NSPredicate(value: true)
        let coreDinnerItems:[DinnerItems]?
        do {
            coreDinnerItems = try managedContext.fetch(itemListFetchRequest)
        } catch let error as NSError {
            print ("Fetch error: \(error), description \(error.userInfo)")
            return nil
        }
        return coreDinnerItems
    }
    
    convenience init (from record : CKRecord, context managedContext: NSManagedObjectContext, description: NSEntityDescription) {
        self.init(entity: description, insertInto: managedContext)
        let name = record["name"] as! String
        let myImage = record.assetToNSData()
        self.image = myImage
        self.name = name
        if let urlString = record["url"] as? String, let url = URL(string: urlString) {
            self.url = url
        }
        self.notes = record["notes"] as? String
        self.rating = 0
        self.privateUse = true
        
    }
    
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

// extension on CKRecord to convert a property of type CKAsset into a UIImage

extension CKRecord {
    func assetToNSData () -> NSData? {
        if let imageInRecord = self["image"] as? CKAsset, let newImage =  NSData(contentsOfFile: imageInRecord.fileURL.path){
            return newImage
        } else {
            return nil
        }
        
    }
}

