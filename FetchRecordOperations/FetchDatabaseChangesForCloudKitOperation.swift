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
    var operationError : Error?
    private let cloudKitZone : CloudKitZone
    private let databaseScope : CKDatabaseScope
    
    init(cloudKitZone: CloudKitZone, databaseScope: CKDatabaseScope) {
        self.changedRecords = []
        self.deletedRecordZoneIDs = []
        self.changedZoneIDs = []
        self.cloudKitZone = cloudKitZone
        self.databaseScope = databaseScope

        super.init()
        self.previousServerChangeToken = getServerChangeToken(databaseScope: databaseScope, cloudKitZone: cloudKitZone)
        }
    override func main() {
        print ("FetchDatabaseChangesForCloudKitOperation.main()")
        setBlocks()
        super.main()
    }
    func setBlocks() {
        recordZoneWithIDChangedBlock = { [unowned self] (zoneId) in
            self.changedZoneIDs.append(zoneId)
        }
        recordZoneWithIDWasDeletedBlock = { [unowned self] (zoneID) in
            self.deletedRecordZoneIDs.append(zoneID)
        }
        changeTokenUpdatedBlock = { (token) in
            // flush zone deletions for this database to disk
            // write this new database change token to memory
        }
        fetchDatabaseChangesCompletionBlock = { [unowned self] (token, moreComing, error) in
            if let error = error {
                print ("FetchDatabaseChangesForCloudKitOperation resulted in error : \(error)")
                self.operationError = error
            }
            else {
                self.setServerChangeToken(databaseScope: self.databaseScope, cloudKitZone: self.cloudKitZone, serverChangeToken: token)
                
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
    }
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
