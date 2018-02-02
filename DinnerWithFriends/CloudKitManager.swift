//
//  CloudKitManager.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 23/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import Foundation
import CloudKit


class CloudKitManager {
    var container : CKContainer = {
        return CKContainer(identifier: "iCloud.bart.bronselaer-me.com.DinnerWithFriends")
    }()
    let operation = OperationQueue()
    
    // MARK: - Initialisation Operation:
    func initialisationOperation() {
        
        print("initialisation operation started")
        
        // create an operation that returns all the record zones in the current database
        let fetchAllRecordZonesOperation = FetchAllRecordZonesOperation.fetchAllRecordZonesOperation()
        
        // create an operatoin to process the returned zones and create arrays for zones that need creation and those that need deletion
        let processServerRecordZonesOperation = ProcessServerRecordZonesOperation()
        // create an operation to modify the existing zones on the server
        let modifyRecordZonesOperation = self.createModifyRecordZoneOperation(recordZonesToSave: nil, recordZoneIDsToDelete: nil)
        // create an operation to transfer data from one operation to another
        let transferFetchedZonesOperation = BlockOperation {
            [unowned fetchAllRecordZonesOperation, unowned processServerRecordZonesOperation] in
            if let fetchRecordZones = fetchAllRecordZonesOperation.fetchedRecordZones {
                processServerRecordZonesOperation.preProcessRecordZoneIDs = Array(fetchRecordZones.keys)
            }
            print("TransferFetchedZonesOperation Blockoperation executed")
        }
        // create an operation to transfer data from one operation to another
        let transferProcessedZonesOperation = BlockOperation {
            [unowned modifyRecordZonesOperation, unowned processServerRecordZonesOperation] in
            modifyRecordZonesOperation.recordZonesToSave = processServerRecordZonesOperation.postProcessRecordZonesToCreate
            modifyRecordZonesOperation.recordZoneIDsToDelete = processServerRecordZonesOperation.postProcessRecordZonesToDelete
        }
        
        // add dependencies
        
        transferFetchedZonesOperation.addDependency(fetchAllRecordZonesOperation)
        processServerRecordZonesOperation.addDependency(transferFetchedZonesOperation)
        transferProcessedZonesOperation.addDependency(processServerRecordZonesOperation)
        modifyRecordZonesOperation.addDependency(transferProcessedZonesOperation)
        modifyRecordZonesOperation.addDependency(fetchAllRecordZonesOperation)
        
       //add operations
        operation.addOperation(fetchAllRecordZonesOperation)
        operation.addOperation(transferFetchedZonesOperation)
        operation.addOperation(processServerRecordZonesOperation)
        operation.addOperation(transferProcessedZonesOperation)
        operation.addOperation(modifyRecordZonesOperation)
        
        // wait until these operations have finished before the queue can launch next set of operations ( subscriptions)
        modifyRecordZonesOperation.waitUntilFinished()
        
        print ("initialisation operation Finished")
        }
    

    // helper function for initialisation Operation
    private func createModifyRecordZoneOperation(recordZonesToSave: [CKRecordZone]?, recordZoneIDsToDelete: [CKRecordZoneID]?) -> CKModifyRecordZonesOperation {
        
        let modifyRecordZonesOperation = CKModifyRecordZonesOperation(recordZonesToSave: recordZonesToSave, recordZoneIDsToDelete: recordZoneIDsToDelete)
        // completionBlock
        modifyRecordZonesOperation.modifyRecordZonesCompletionBlock = { (modifiedRecordZones, deletedRecordZonesIDs , error) in
            print ("CKModifyRecordZonesOperation.completionBlock Start:")
            if let error = error {
                print("createModifyRecordZoneOperation ERROR: \(error)")
                return
            }
            if let modifiedRecordZones = modifiedRecordZones {
                for recordZone in modifiedRecordZones {
                    print("Modified recordZone : \(recordZone)")
                }
            }
            if let deletedRecordZoneIDs = deletedRecordZonesIDs {
                for recordZoneID in deletedRecordZoneIDs {
                    print ("Deleted recordZoneIDs \(recordZoneID)")
                }
            }
            print ("CKModifyRecordZonesOperation.completionBlock End:")
        }
        return modifyRecordZonesOperation
    }
}
// MARK - Create database zone subscriptions
extension CloudKitManager {
    
    func subscribeToDatabaseZones() {
        
        // check if already subscribed flag is set to true
        let userDefault = UserDefaults.standard
        guard !userDefault.exists(key: UserDefaultKeys.subscribedToDatabaseChanges.rawValue) else {
            print("subscriptions to databaseChanges do already exist")
            return
        }
        // continue the subscription to the databaseZones
        print("Subscribe to databaseZones process: Start")
        // 1. fetch all subscriptions
        // 2. process those that need to be created and those that need to be deleted
        // 3. Make the adjustment in the Cloud
        
        // create an operation to fetch all the zonesubscriptions from the server
        let fetchAllSubscriptionOperation = FetchAllSubscriptionsOperation.fetchAllSubscriptionsOperation()
        // create an operation to compare the existing zonessubscriptions with the defined CloudKitZones
        let processServerSubscriptionOperation = ProcessServerSubscriptionOperation()
        
        // create an operation to update the subscriptions on the server
        let modifySubscriptionOperation = self.createModifySubscriptionOperation()
        
        // create an operation to transfer data from one operation to another
        let transferFetchedSubscriptionOperation = BlockOperation {
            [unowned processServerSubscriptionOperation, unowned fetchAllSubscriptionOperation ] in
            processServerSubscriptionOperation.preProcessedFetchedSubscriptions = fetchAllSubscriptionOperation.fetchedSubscriptions
        }
        // create an operation to transfer data from one operation to another
        let transferProcessedSubscriptionOperation = BlockOperation {
            [unowned modifySubscriptionOperation, unowned processServerSubscriptionOperation] in
            modifySubscriptionOperation.subscriptionsToSave = processServerSubscriptionOperation.postProcessSubscriptionsToCreate
            modifySubscriptionOperation.subscriptionIDsToDelete = processServerSubscriptionOperation.postProcessSubscriptionsToDelete
        }
        // Add dependencies
        transferFetchedSubscriptionOperation.addDependency(fetchAllSubscriptionOperation)
        processServerSubscriptionOperation.addDependency(transferFetchedSubscriptionOperation)
        transferProcessedSubscriptionOperation.addDependency(processServerSubscriptionOperation)
        modifySubscriptionOperation.addDependency(transferProcessedSubscriptionOperation)
        modifySubscriptionOperation.addDependency(fetchAllSubscriptionOperation)
        
        // load operations
        self.operation.addOperation(fetchAllSubscriptionOperation)
        self.operation.addOperation(transferFetchedSubscriptionOperation)
        self.operation.addOperation(processServerSubscriptionOperation)
        self.operation.addOperation(transferProcessedSubscriptionOperation)
        self.operation.addOperation(modifySubscriptionOperation)
        
        // wait until all operations are done:
        modifySubscriptionOperation.waitUntilFinished()
        
        print("Subscribe to databaseZones process: End")
    }
    
    private func createModifySubscriptionOperation() -> CKModifySubscriptionsOperation {
        let modifySubscriptionOperation = CKModifySubscriptionsOperation()
        
        modifySubscriptionOperation.modifySubscriptionsCompletionBlock = { (modifiedSubscriptions, deletedSubscriptionsIDs, error) in
            print ("CKModifySubscriptionsOperation.modifySubscriptionsCompletionBlock")
            
            if let error = error {
                print ("createModifySubscriptionOperation ERROR: \(error)")
                return
            }
            if let modifiedSubscriptions = modifiedSubscriptions {
                for subscription in modifiedSubscriptions {
                    print ("Modified subscription : \(subscription)")
                }
            }
            if let deletedSubscriptionsIDs = deletedSubscriptionsIDs {
                for subscriptionID in deletedSubscriptionsIDs {
                    print ("Deleted subscriptionIDs : \(subscriptionID)")
                }
            }
             UserDefaults.standard.set(true, forKey: UserDefaultKeys.subscribedToDatabaseChanges.rawValue)
        }
        return modifySubscriptionOperation
    }
    
}
//MARK - Create Publicdatabase Subscription

extension CloudKitManager {
    func createPublicDatabaseSubscription() {
        let usersDefault = UserDefaults.standard
        if usersDefault.exists(key:UserDefaultKeys.subscribedToPublicChanges.rawValue ) {
            return
        }
        let recordType = PublicDatabaseTypes.backgroundPicture.rawValue
        let predicate = NSPredicate(value: true)
        let publicDatabaseSubscription = CKQuerySubscription(recordType: recordType, predicate: predicate, subscriptionID: PublicDatabaseQuerySubscription.publicDatabaseChange.rawValue, options: [.firesOnRecordDeletion,.firesOnRecordUpdate,.firesOnRecordCreation])
        let notificationInfo = CKNotificationInfo()
        notificationInfo.desiredKeys = ["name"]
        notificationInfo.shouldSendContentAvailable = true
        publicDatabaseSubscription.notificationInfo = notificationInfo
        let modifySubscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [publicDatabaseSubscription], subscriptionIDsToDelete: nil)
        modifySubscriptionOperation.modifySubscriptionsCompletionBlock = {
            (savedSubscriptions, deletedSubscriptionsIDs, error) in
            if let error = error {
                print ("Public DatabaseSubscription Error : \(error)")
                return
            }
            if let savedSubscriptions = savedSubscriptions {
                for subscriptionsSaved in savedSubscriptions {
                    print ("Seved Subscriptions : \(subscriptionsSaved)")
                }
            }
            if let deletedSubscriptionsIDs = deletedSubscriptionsIDs {
                for deletedSubscriptions in deletedSubscriptionsIDs {
                    print ("Deleted subscriptionsIDs: \(deletedSubscriptions)")
                }
            }
        usersDefault.set(true, forKey: UserDefaultKeys.subscribedToPublicChanges.rawValue)
        }
        modifySubscriptionOperation.database = container.publicCloudDatabase
       operation.addOperation(modifySubscriptionOperation)
    }
    
    func subscribeToPublicDatabase () {
        // 1. fetch all subscriptions
        // 2. process those that need to be created and those that need to be deleted
        // 3. Make the adjustment in the Cloud
        
        let fetchAllSubscriptionOperation = FetchAllPublicDatabaseSubscriptionsOperation.fetchAllSubscriptionsOperation()
        fetchAllSubscriptionOperation.database = container.publicCloudDatabase
        
        let processServerSubscriptionOperation = ProcessServerPublicDatabaseSubscriptionOperation()
        let modifySubscriptionOperation = self.createModifyPublicSubscriptionOperation()
        
        let transferFetchedSubscriptionOperation = BlockOperation {
            [unowned processServerSubscriptionOperation, unowned fetchAllSubscriptionOperation ] in
            processServerSubscriptionOperation.preProcessedFetchedSubscriptions = fetchAllSubscriptionOperation.fetchedSubscriptions
        }
        
        let transferProcessedSubscriptionOperation = BlockOperation {
            [unowned modifySubscriptionOperation, unowned processServerSubscriptionOperation] in
            modifySubscriptionOperation.subscriptionsToSave = processServerSubscriptionOperation.postProcessSubscriptionsToCreate
            modifySubscriptionOperation.subscriptionIDsToDelete = processServerSubscriptionOperation.postProcessSubscriptionsToDelete
        }
        // dependencies
        transferFetchedSubscriptionOperation.addDependency(fetchAllSubscriptionOperation)
        processServerSubscriptionOperation.addDependency(transferFetchedSubscriptionOperation)
        transferProcessedSubscriptionOperation.addDependency(processServerSubscriptionOperation)
        modifySubscriptionOperation.addDependency(transferProcessedSubscriptionOperation)
        modifySubscriptionOperation.addDependency(fetchAllSubscriptionOperation)
        
        // load operations
        self.operation.addOperation(fetchAllSubscriptionOperation)
        self.operation.addOperation(transferFetchedSubscriptionOperation)
        self.operation.addOperation(processServerSubscriptionOperation)
        self.operation.addOperation(transferProcessedSubscriptionOperation)
        self.operation.addOperation(modifySubscriptionOperation)
        
    }
    
    private func createModifyPublicSubscriptionOperation() -> CKModifySubscriptionsOperation {
        let modifyPublicSubscriptionOperation = CKModifySubscriptionsOperation()
        modifyPublicSubscriptionOperation.database = container.publicCloudDatabase
        
        modifyPublicSubscriptionOperation.modifySubscriptionsCompletionBlock = { (modifiedSubscriptions, deletedSubscriptionsIDs, error) in
            print ("CKModifyPublicSubscriptionsOperation.modifySubscriptionsCompletionBlock")
            
            if let error = error {
                print ("createModifyPublicSubscriptionOperation ERROR: \(error)")
                return
            }
            if let modifiedSubscriptions = modifiedSubscriptions {
                for subscription in modifiedSubscriptions {
                    print ("Modified Public Subscription : \(subscription)")
                }
            }
            if let deletedSubscriptionsIDs = deletedSubscriptionsIDs {
                for subscriptionID in deletedSubscriptionsIDs {
                    print ("Deleted Public SubscriptionIDs : \(subscriptionID)")
                }
            }
            //create Default key "subscribedToPublicChanges"
            
            let userDefault = UserDefaults.standard
            userDefault.set(true, forKey: UserDefaultKeys.subscribedToPublicChanges.rawValue)
        }
        return modifyPublicSubscriptionOperation
    }
    
}
// MARK: -Sync changes in CloudKit Locally

extension CloudKitManager {
    func synZone(notification: CKNotification , completionBlockOperation: BlockOperation) {
        
        switch notification.notificationType {
        case .query :
            let queryNotification = notification as! CKQueryNotification
            let databaseScope = queryNotification.databaseScope
            let queryNotificationReason = queryNotification.queryNotificationReason.rawValue
            let queryRecordFields = queryNotification.recordFields
            if let recordID = queryNotification.recordID {
                let recordName = recordID.recordName
                let zoneID = recordID.zoneID
                print ("Cloudkitmanager called on query notification")
                print ("databaseScope : \(databaseScope.rawValue)")
                print ("recordID : \(recordID), recordName: \(recordName) and finally recordZone: \(zoneID)")
                print ("query reason: \(queryNotificationReason)")
                if let queryRecordfields = queryRecordFields {
                    for changedField in queryRecordfields {
                        print("field : \(changedField.key), value : \(changedField.value)")
                    }
                }
                operation.addOperation(completionBlockOperation)
                
            }
            
        case .recordZone :
            let cloudKitZoneNotificationUserInfo = notification as! CKRecordZoneNotification
            let databaseScope = cloudKitZoneNotificationUserInfo.databaseScope
            if let recordZoneID = cloudKitZoneNotificationUserInfo.recordZoneID {
                print ("Cloudkitmanger called on zone change notification")
                print ("databaseScope : \(databaseScope.rawValue)")
                print ("recordzoneID : \(recordZoneID)")
                operation.addOperation(completionBlockOperation)
            }
        default :
            break
        }
    }
}

//MARK: -Update BackgroundPictures
extension CloudKitManager {
    func updateBackgroundPictures(cloudKitZone: CloudKitZone,databaseScope: CKDatabaseScope, with coreDataStack: CoreDataStack) {
        // create an operation to fetch the zonesIDs that have changes
        let fetchDatabaseChangesForCloudKitOperation = FetchDatabaseChangesForCloudKitOperation(cloudKitZone: cloudKitZone, databaseScope: databaseScope)
        fetchDatabaseChangesForCloudKitOperation.database = container.database(with: databaseScope)
        
        // set operation the fetch the record changes
        let fetchRecordZoneChangesOperation = FetchRecordZoneChangesOperation(databaseScope: databaseScope, cloudKitZone: cloudKitZone, coreDataStack: coreDataStack)
        fetchRecordZoneChangesOperation.database = container.database(with: databaseScope)
      
        
        // set operation to transfer data between both operations
        let transferDataOperation = BlockOperation {
            [unowned fetchDatabaseChangesForCloudKitOperation,  fetchRecordZoneChangesOperation ] in
            fetchRecordZoneChangesOperation.changedZoneIDs = fetchDatabaseChangesForCloudKitOperation.changedZoneIDs
            fetchRecordZoneChangesOperation.fetchOptionsByRecordZoneID = fetchDatabaseChangesForCloudKitOperation.optionsByRecordZoneID
            fetchRecordZoneChangesOperation.serverChangeToken = fetchDatabaseChangesForCloudKitOperation.serverChangeToken
        }
        // add dependencies
        transferDataOperation.addDependency(fetchDatabaseChangesForCloudKitOperation)
        fetchRecordZoneChangesOperation.addDependency(transferDataOperation)
        fetchRecordZoneChangesOperation.addDependency(fetchDatabaseChangesForCloudKitOperation)
        
        // add operations to the queue
        
        self.operation.addOperation(fetchDatabaseChangesForCloudKitOperation)
        self.operation.addOperation(transferDataOperation)
        if !fetchDatabaseChangesForCloudKitOperation.changedZoneIDs.isEmpty {
        self.operation.addOperation(fetchRecordZoneChangesOperation)
        }
    }
}



