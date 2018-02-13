//
//  CreateRecordsForNewObjectsOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 12/02/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class CreateRecordsForNewObjectsOperation: Operation {
    
    var createdRecords: [CKRecord]?
    private let insertedManagedObjectIDs : [NSManagedObjectID]
    private let coreDataManager :  CoreDataStack
    
    init(insertedManagedObjectIDs: [NSManagedObjectID], coreDataManager: CoreDataStack) {
        self.insertedManagedObjectIDs = insertedManagedObjectIDs
        self.coreDataManager = coreDataManager
        self.createdRecords = nil
        super.init()
    }
    
    override func main() {
        let managedObjectContext = coreDataManager.createBackgroundManagedContext()
        if insertedManagedObjectIDs.count > 0 {
            managedObjectContext.performAndWait {
                [unowned self] in
                let insertedCloudKitObjects = self.coreDataManager.fetchCloudKitManagedObjects(managedObjectContext: managedObjectContext, managedObjectIDs: self.insertedManagedObjectIDs)
                self.createdRecords = insertedCloudKitObjects.flatMap() {$0.cloudKitRecord(record: nil)}
                self.coreDataManager.saveBackgroundManagedObjectContext(backgroundManagedObjectContext: managedObjectContext)
            }
        }
    }

}
