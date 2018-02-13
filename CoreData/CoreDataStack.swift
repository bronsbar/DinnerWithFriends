//
//  CoreDataStack.swift
//  DinnerWithFriends6
//
//  Created by Bart Bronselaer on 28/12/17.
//  Copyright © 2017 Bart Bronselaer. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    init(modelName: String){
        self.modelName = modelName
    }
    
    private lazy var storeContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print ("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        
        let insertedObjects = managedContext.insertedObjects
        let modifiedObjects = managedContext.updatedObjects
        let deletedRecordIDs = managedContext.deletedObjects.flatMap { ($0 as? CloudKitManagedObject)?.cloudKitRecordID()}
        
        guard managedContext.hasChanges else {return}
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func createBackgroundManagedContext() -> NSManagedObjectContext {
        let backgroundManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundManagedObjectContext.persistentStoreCoordinator = storeContainer.persistentStoreCoordinator
        backgroundManagedObjectContext.undoManager = nil
        return backgroundManagedObjectContext
    }
    
    func fetchCloudKitManagedObjects(managedObjectContext: NSManagedObjectContext, managedObjectIDs: [NSManagedObjectID]) -> [CloudKitManagedObject] {
        var cloudKitManagedObjects : [CloudKitManagedObject] = []
        for managedObjectsID in managedObjectIDs {
            do {
                let managedObject = try managedObjectContext.existingObject(with: managedObjectsID)
                if let cloudKitManagedObject = managedObject as? CloudKitManagedObject {
                    cloudKitManagedObjects.append(cloudKitManagedObject)
                }
                
            }
            catch let error as NSError {
                print ("Error fetching from CoreData: \(error.localizedDescription)")
            }
        }
        return cloudKitManagedObjects
    }
    func saveBackgroundManagedObjectContext(backgroundManagedObjectContext: NSManagedObjectContext) {
        if backgroundManagedObjectContext.hasChanges {
            do {
                try backgroundManagedObjectContext.save()
            } catch let error as NSError {
                fatalError("CoreDataStack - save backgroundManagedObjectContext Error :  \(error.localizedDescription)")
            }
        }
    }
}

