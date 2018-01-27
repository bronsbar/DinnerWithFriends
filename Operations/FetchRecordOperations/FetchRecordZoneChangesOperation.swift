//
//  FetchRecordZoneChangesOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 27/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class FetchRecordZoneChangesOperation: CKFetchRecordZoneChangesOperation {
    var fetchOptionsByRecordZoneID: [CKRecordZoneID : CKFetchRecordZoneChangesOptions]
    var changedZoneIDs : [CKRecordZoneID]
    private let cloudKitZone : CloudKitZone
    private let databaseScope : CKDatabaseScope
    
    init(databaseScope: CKDatabaseScope, cloudKitZone: CloudKitZone) {
        self.databaseScope = databaseScope
        self.cloudKitZone = cloudKitZone
        self.fetchOptionsByRecordZoneID = [:]
        self.changedZoneIDs = []
        super.init()
    }
    override func main() {
        print ("FetchRecordZoneChangesOperation.main()")
        lookUpChangeTokenForEachZone()
        setBlocks()
        super.main()
    }
    
    func lookUpChangeTokenForEachZone() {
        
    }
    
    func setBlocks() {
        
    }

}
