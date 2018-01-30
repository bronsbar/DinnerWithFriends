//
//  FetchDatabaseChangesForCloudKitOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 26/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class FetchDatabaseChangesForCloudKitOperation: CKFetchDatabaseChangesOperation {
    var changedRecords: [CKRecord]
    var deletedRecordZoneIDs : [CKRecordZoneID]
    var changedZoneIDs : [CKRecordZoneID]
    var optionsByRecordZoneID : [CKRecordZoneID: CKFetchRecordZoneChangesOptions]
    var operationError : Error?
    var serverChangeToken :CKServerChangeToken!
    var serverFetchChangeToken : [CKRecordZoneID :CKServerChangeToken]
    private let cloudKitZone : CloudKitZone
    private let databaseScope : CKDatabaseScope
    private let coreDataStack : CoreDataStack
    
    init(cloudKitZone: CloudKitZone, databaseScope: CKDatabaseScope, coreDataStack:CoreDataStack) {
        self.changedRecords = []
        self.deletedRecordZoneIDs = []
        self.changedZoneIDs = []
        self.optionsByRecordZoneID = [:]
        self.cloudKitZone = cloudKitZone
        self.databaseScope = databaseScope
        self.coreDataStack = coreDataStack
        self.serverFetchChangeToken = [:]

        super.init()
        
    }
    override func main() {
        print ("FetchDatabaseChangesForCloudKitOperation.main()")
        setBlocks()
        super.main()
    }
    func setBlocks() {
        recordZoneWithIDChangedBlock = { [unowned self] (zoneId) in
            self.changedZoneIDs.append(zoneId)
            if let cloudKitZone = CloudKitZone(rawValue: zoneId.zoneName), let serverFetchToken = self.getServerChangeToken(databaseScope: self.databaseScope, cloudKitZone: cloudKitZone) {
                self.serverFetchChangeToken[zoneId] = serverFetchToken
            }
            
        }
        recordZoneWithIDWasDeletedBlock = { [unowned self] (zoneID) in
            self.deletedRecordZoneIDs.append(zoneID)
        }
        changeTokenUpdatedBlock = { [unowned self] (token) in
            // flush zone deletions for this database to disk
            // write this new database change token to memory
            self.serverChangeToken = token
        }
        fetchDatabaseChangesCompletionBlock = { [unowned self] (token, moreComing, error) in
            if let error = error {
                print ("FetchDatabaseChangesForCloudKitOperation resulted in error : \(error)")
                self.operationError = error
            }
            else {
                guard let token = token else {
                    print (" no token in completionblock")
                    return
                }
                self.serverChangeToken = token
                for zoneID in self.changedZoneIDs {
                    let options = CKFetchRecordZoneChangesOptions()
                    options.previousServerChangeToken = self.serverFetchChangeToken[zoneID]
                    self.optionsByRecordZoneID[zoneID] = options
                }
                let fetchOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: self.changedZoneIDs, optionsByRecordZoneID: self.optionsByRecordZoneID)
                fetchOperation.recordChangedBlock = {(record) in }
                
                
            }
        }
        
    }
    
// MARK: - Change token, user defaults methods

func getServerChangeToken(databaseScope : CKDatabaseScope, cloudKitZone: CloudKitZone) -> CKServerChangeToken? {
    let userDefault = UserDefaults.standard
    var serverChangeToken : CKServerChangeToken?
    if databaseScope == .public {
        if let encodedObjectData = userDefault.object(forKey: UserDefaultKeys.publicServerChangeToken.rawValue) as? Data
        {
            serverChangeToken = NSKeyedUnarchiver.unarchiveObject(with: encodedObjectData) as? CKServerChangeToken
        } else { serverChangeToken = nil}
    } else {
        serverChangeToken = nil
    }// implement the return of the serverchange token for non public database
        return serverChangeToken
}

func setServerChangeToken(databaseScope : CKDatabaseScope, cloudKitZone: CloudKitZone, serverChangeToken: CKServerChangeToken?) {
    let userDefault = UserDefaults.standard
    if let serverChangeToken = serverChangeToken {
        let encodedObjectData = NSKeyedArchiver.archivedData(withRootObject: serverChangeToken)
        userDefault.set(encodedObjectData, forKey: UserDefaultKeys.publicServerChangeToken.rawValue)
        
    }
    else {
        userDefault.set(nil, forKey: UserDefaultKeys.publicServerChangeToken.rawValue)
    }
    
}
}
