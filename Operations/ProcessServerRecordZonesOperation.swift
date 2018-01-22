//
//  ProcessServerRecordZonesOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 22/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class ProcessServerRecordZonesOperation: Operation {
    
    var preProcessRecordZoneIDs : [CKRecordZoneID]
    var postProcessRecordZonesToCreate: [CKRecordZone]?
    var postProcessRecordZonesToDelete: [CKRecordZoneID]?
    
    override init() {
        preProcessRecordZoneIDs = []
        postProcessRecordZonesToCreate = nil
        postProcessRecordZonesToDelete = nil
    }
    
    override func main() {
        print("ProcessServerRecordZonesOperation.main()")
        setZonesToCreate()
        setZonesToDelete()
    }
    private func setZonesToCreate() {
        let serverZoneNameSet = Set(preProcessRecordZoneIDs.map {$0.zoneName})
        let expectedZoneNameSet = Set(CloudKitZone.allCloudKitZoneNames)
        let missingZoneNameSet = expectedZoneNameSet.subtracting(serverZoneNameSet)
        
        if missingZoneNameSet.count > 0 {
            postProcessRecordZonesToCreate = []
            for missingZoneName in missingZoneNameSet {
                if let missingCloudKitZone = CloudKitZone(rawValue: missingZoneName) {
                    let missingRecordZone = CKRecordZone(zoneID: missingCloudKitZone.recordZoneID())
                    postProcessRecordZonesToCreate?.append(missingRecordZone)
                }
            }
        }
    }
    private func setZonesToDelete() {
        
    }
}
