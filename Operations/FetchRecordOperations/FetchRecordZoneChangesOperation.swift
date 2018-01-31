//
//  FetchRecordZoneChangesOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 27/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class FetchRecordZoneChangesOperation: CKFetchRecordZoneChangesOperation {
    var fetchOptionsByRecordZoneID: [CKRecordZoneID : CKFetchRecordZoneChangesOptions]
    var changedZoneIDs : [CKRecordZoneID]
    var serverFetchChangeToken : [CKRecordZoneID :CKServerChangeToken]
    private let cloudKitZone : CloudKitZone?
    private let databaseScope : CKDatabaseScope
    private let coreDataStack : CoreDataStack
    
    init(databaseScope: CKDatabaseScope, cloudKitZone: CloudKitZone?, coreDataStack: CoreDataStack) {
        self.databaseScope = databaseScope
        self.cloudKitZone = cloudKitZone
        self.coreDataStack = coreDataStack
        self.fetchOptionsByRecordZoneID = [:]
        self.changedZoneIDs = []
        self.serverFetchChangeToken = [:]
        super.init()
    }
    override func main() {
        print ("FetchRecordZoneChangesOperation.main()")
        setBlocks()
        super.main()
    }
    
    func setBlocks() {
        recordChangedBlock = { (record)in
            let name = record.recordID.recordName
            let request: NSFetchRequest<BackgroundPictures> = BackgroundPictures.fetchRequest()
            request.predicate = NSPredicate(format: "recordName = %@", name)
            do {
                let result = try self.coreDataStack.managedContext.fetch(request)
                if result.isEmpty {
                    let backgroundPicture = BackgroundPictures(context: self.coreDataStack.managedContext)
                    backgroundPicture.updateWithRecord(record: record)
                    try self.coreDataStack.saveContext()
                } else {
                    let backgroundPicture = result[0]
                    backgroundPicture.updateWithRecord(record: record)
                    try self.coreDataStack.saveContext()
                }
            } catch {
                print("Error in saving to CoreDataContext")
            }
        }
        recordWithIDWasDeletedBlock = {(recordID,recordType) in
            let name = recordID.recordName
            let request: NSFetchRequest<BackgroundPictures> = BackgroundPictures.fetchRequest()
            request.predicate = NSPredicate(format: "recordName = %@", name)
            do {
                let result = try self.coreDataStack.managedContext.fetch(request)
                if !result.isEmpty {
                    let backgroundPicture = result[0]
                    self.coreDataStack.managedContext.delete(backgroundPicture)
                    try self.coreDataStack.saveContext()
                }
            } catch {
                print ("error in deleting core Data object")
            }
        }
        recordZoneFetchCompletionBlock = {(zoneID, token, data, more, error) in
            self.serverFetchChangeToken[zoneID] = token
        }
        fetchRecordZoneChangesCompletionBlock = { (error) in
            if error ==  nil {
                let userDefault = UserDefaults.standard
                for zoneID in self.serverFetchChangeToken.keys {
                    let encodedObjectData = NSKeyedArchiver.archivedData(withRootObject: self.serverFetchChangeToken[zoneID]!)
                    userDefault.set(encodedObjectData, forKey: UserDefaultKeys.publicServerFetchChangeToken.rawValue)
                }
                
            }
        }
    }

}
