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
            [modifyRecordZonesOperation, unowned processServerRecordZonesOperation] in
            modifyRecordZonesOperation.recordZonesToSave = processServerRecordZonesOperation.postProcessRecordZonesToCreate
            modifyRecordZonesOperation.recordZoneIDsToDelete = processServerRecordZonesOperation.postProcessRecordZonesToDelete
        }
        
        // add dependencies
        
        transferFetchedZonesOperation.addDependency(fetchAllRecordZonesOperation)
        processServerRecordZonesOperation.addDependency(transferFetchedZonesOperation)
        transferProcessedZonesOperation.addDependency(processServerRecordZonesOperation)
        modifyRecordZonesOperation.addDependency(transferProcessedZonesOperation)
        
       //add operations
        operation.addOperation(fetchAllRecordZonesOperation)
        operation.addOperation(transferFetchedZonesOperation)
        operation.addOperation(processServerRecordZonesOperation)
        operation.addOperation(transferProcessedZonesOperation)
        operation.addOperation(modifyRecordZonesOperation)
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

