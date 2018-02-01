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
    var deletedRecordZoneIDs : [CKRecordZoneID]
    var changedZoneIDs : [CKRecordZoneID]
    var optionsByRecordZoneID : [CKRecordZoneID: CKFetchRecordZoneChangesOptions]
    var operationError : Error?
    var serverChangeToken :CKServerChangeToken?
    
    private let cloudKitZone : CloudKitZone
    private let databaseScope : CKDatabaseScope
    
    
    init(cloudKitZone: CloudKitZone, databaseScope: CKDatabaseScope) {
        self.deletedRecordZoneIDs = []
        self.changedZoneIDs = []
        self.optionsByRecordZoneID = [:]
        self.cloudKitZone = cloudKitZone
        self.databaseScope = databaseScope
        
        
        super.init()
        self.serverChangeToken = self.getServerChangeToken(databaseScope: databaseScope, cloudKitZone: cloudKitZone, changeTokenType: .databaseChangeToken)
        self.previousServerChangeToken = self.serverChangeToken
        
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
                // populate optionsByRecordZoneID with ZoneChangeTokens on disk
                for zoneID in self.changedZoneIDs {
                    let options = CKFetchRecordZoneChangesOptions()
                    switch zoneID.zoneName {
                    case CloudKitZone.backgroundPictureZone.rawValue :
                        options.previousServerChangeToken = self.getServerChangeToken(databaseScope: self.databaseScope, cloudKitZone: .backgroundPictureZone, changeTokenType: .zoneChangeToken)
                        self.optionsByRecordZoneID[zoneID] = options
                    case CloudKitZone.dinnerItemsZone.rawValue :
                        options.previousServerChangeToken = self.getServerChangeToken(databaseScope: self.databaseScope, cloudKitZone: .dinnerItemsZone, changeTokenType: .zoneChangeToken)
                        self.optionsByRecordZoneID[zoneID] = options
                    default : break
                    }
                }                
            }
        }
        
    }
}
    extension CKDatabaseOperation {
        
        // MARK: - Change token, user defaults methods
        
        func getServerChangeToken(databaseScope : CKDatabaseScope, cloudKitZone: CloudKitZone, changeTokenType: ChangeTokenType) -> CKServerChangeToken? {
            let userDefault = UserDefaults.standard
            var serverChangeToken : CKServerChangeToken?
            if databaseScope == .private && changeTokenType == .databaseChangeToken {
                if let encodedObjectData = userDefault.object(forKey: UserDefaultKeys.privateServerChangeToken.rawValue) as? Data
                {
                    serverChangeToken = NSKeyedUnarchiver.unarchiveObject(with: encodedObjectData) as? CKServerChangeToken
                } else { serverChangeToken = nil}
            }
            if databaseScope == .private && changeTokenType == .zoneChangeToken {
                switch cloudKitZone {
                case .backgroundPictureZone:
                    if let encodedObjectData = userDefault.object(forKey: UserDefaultKeys.backgroundPicturesZoneChangeToken.rawValue) as? Data
                    {
                        serverChangeToken = NSKeyedUnarchiver.unarchiveObject(with: encodedObjectData) as? CKServerChangeToken
                    } else { serverChangeToken = nil}
                case .dinnerItemsZone:
                    if let encodedObjectData = userDefault.object(forKey: UserDefaultKeys.dinnerItemsZoneChangeToken.rawValue) as? Data
                    {
                        serverChangeToken = NSKeyedUnarchiver.unarchiveObject(with: encodedObjectData) as? CKServerChangeToken
                    } else { serverChangeToken = nil}
                }
            }
            return serverChangeToken
        }
        
        func setServerChangeToken(databaseScope : CKDatabaseScope, cloudKitZone: CloudKitZone, changeTokenType: ChangeTokenType, serverChangeToken: CKServerChangeToken?) {
            let userDefault = UserDefaults.standard
            if changeTokenType == .databaseChangeToken && databaseScope == .private {
                if let serverChangeToken = serverChangeToken {
                    let encodedObjectData = NSKeyedArchiver.archivedData(withRootObject: serverChangeToken)
                     userDefault.set(encodedObjectData, forKey: UserDefaultKeys.privateServerChangeToken.rawValue)
                }
            }
            if databaseScope == .private && changeTokenType == .zoneChangeToken {
                if let serverChangeToken = serverChangeToken {
                    let encodedObjectData = NSKeyedArchiver.archivedData(withRootObject: serverChangeToken)
                    switch cloudKitZone {
                    case .backgroundPictureZone:
                        userDefault.set(encodedObjectData, forKey: UserDefaultKeys.backgroundPicturesZoneChangeToken.rawValue)
                    case .dinnerItemsZone:
                        userDefault.set(encodedObjectData, forKey: UserDefaultKeys.dinnerItemsZoneChangeToken.rawValue)
                    }
                }
            }
    }
}


