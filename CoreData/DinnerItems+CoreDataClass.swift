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
final public class DinnerItems: NSManagedObject {
    
    // enum with dinnerItem Categories
    enum DinnerItemCategory: String {
        case Starter = "Starter"
        case Main = "Main Course"
        case Dessert = "Dessert"
        case Apperitive = "Apperitive"
        case White = "White Wine"
        case Red = "Red Wine"
        case Amuse = "Amuse"
        
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

