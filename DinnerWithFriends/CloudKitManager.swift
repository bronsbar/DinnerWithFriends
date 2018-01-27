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
    
    func initialisationOperation() {
        
        // fetch all zones
        let fetchAllRecordZonesOperation = FetchAllRecordZonesOperation.fetchAllRecordZonesOperation()
        // process the returned zones and create arrays for zones that need creation and those that need deletion
        
        let processServerRecordZonesOperation = ProcessServerRecordZonesOperation()
        let modifyRecordZonesOperation = self.createModifyRecordZoneOperation(recordZonesToSave: nil, recordZoneIDsToDelete: nil)
        
        let transferFetchedZonesOperation = BlockOperation {
            [unowned fetchAllRecordZonesOperation, unowned processServerRecordZonesOperation] in
            if let fetchRecordZones = fetchAllRecordZonesOperation.fetchedRecordZones {
                processServerRecordZonesOperation.preProcessRecordZoneIDs = Array(fetchRecordZones.keys)
            }
            print("TransferFetchedZonesOperation Blockoperation executed")
        }
        
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
        }
    

    
    private func createModifyRecordZoneOperation(recordZonesToSave: [CKRecordZone]?, recordZoneIDsToDelete: [CKRecordZoneID]?) -> CKModifyRecordZonesOperation {
        
        let modifyRecordZonesOperation = CKModifyRecordZonesOperation(recordZonesToSave: recordZonesToSave, recordZoneIDsToDelete: recordZoneIDsToDelete)
        modifyRecordZonesOperation.modifyRecordZonesCompletionBlock = { (modifiedRecordZones, deletedRecordZonesIDs , error) in
            print ("CKModifyRecordZonesOperation.modifyRecordZonesOperation")
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
        }
        return modifyRecordZonesOperation
    }
}
// MARK - Create database zone subscriptions
extension CloudKitManager {
    
    func subscribeToDatabaseZones() {
        // 1. fetch all subscriptions
        // 2. process those that need to be created and those that need to be deleted
        // 3. Make the adjustment in the Cloud
        
        let fetchAllSubscriptionOperation = FetchAllSubscriptionsOperation.fetchAllSubscriptionsOperation()
        let processServerSubscriptionOperation = ProcessServerSubscriptionOperation()
        let modifySubscriptionOperation = self.createModifySubscriptionOperation()
        
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
                print ("Cloudkitmanager called on query notification")
                print ("databaseScope : \(databaseScope.rawValue)")
                print ("recordID : \(recordID)")
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



