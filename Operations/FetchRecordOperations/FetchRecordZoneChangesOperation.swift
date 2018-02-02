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
    var changedRecords : [CKRecord]
    var deletedRecords : [CKRecordID]
    var serverFetchChangeToken : [CKRecordZoneID :CKServerChangeToken]
    var serverChangeToken : CKServerChangeToken?
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
        self.serverChangeToken = nil
        self.changedRecords = []
        self.deletedRecords = []
        super.init()
    }
    override func main() {
        print ("FetchRecordZoneChangesOperation.main()")
        self.recordZoneIDs = self.changedZoneIDs
        self.optionsByRecordZoneID = self.fetchOptionsByRecordZoneID
        setBlocks()
        super.main()
    }
    
    func setBlocks() {
        recordChangedBlock = { (record) in
            self.changedRecords.append(record)
            print("changedRecord name:\(record.recordID.recordName)")
            //
        }
        recordWithIDWasDeletedBlock = {(recordID,recordType) in
            self.deletedRecords.append(recordID)
            print("records to delete : \(recordID.recordName)")
           
        }
        recordZoneChangeTokensUpdatedBlock = { (zoneId, token, data) in
            // flush record changes and deletions for this zone to disk
            self.flushRecordChangesToDisk(zoneId: zoneId)
            self.flushDeletionsToDisk(zoneId: zoneId)
            // write the new zone change token to disk
            self.setServerChangeToken(databaseScope: self.databaseScope, cloudKitZone: CloudKitZone(rawValue: zoneId.zoneName)!, changeTokenType: .zoneChangeToken, serverChangeToken: token)
        }
        recordZoneFetchCompletionBlock = {(zoneID, token, data, more, error) in
            if let error = error {
                print ("Error fetching zone changes for \(zoneID.zoneName): ", error)
                return
            }
            // flush record changes and deletion for this zone to disk
            self.flushRecordChangesToDisk(zoneId: zoneID)
            self.flushDeletionsToDisk(zoneId: zoneID)
            //write the new zone change token to disk
            self.setServerChangeToken(databaseScope: self.databaseScope, cloudKitZone: CloudKitZone(rawValue: zoneID.zoneName)!, changeTokenType: .zoneChangeToken, serverChangeToken: token)
        }
        fetchRecordZoneChangesCompletionBlock = { (error) in
            if error ==  nil {
                
                // send a notification that an update is available
                let center = NotificationCenter.default
                let name = Notification.Name("Update Interface")
                center.post(name: name, object: nil, userInfo: nil)
                
            }
            if error != nil {
                print ("error in fetch record zone changes completion block: \(error)")
            }
        }
    }
    
}
// MARK: - Helper functions
extension FetchRecordZoneChangesOperation {
    func flushRecordChangesToDisk(zoneId :CKRecordZoneID) {
        for record in changedRecords {
            switch record.recordID.zoneID.zoneName {
            case CloudKitZone.backgroundPictureZone.rawValue :
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
                // still to implement changes with other zoneIDs
            default: break
            }
        }
        changedRecords = []
    }
    func flushDeletionsToDisk(zoneId : CKRecordZoneID) {
        for recordID in deletedRecords {
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
       deletedRecords = []
    }
}
