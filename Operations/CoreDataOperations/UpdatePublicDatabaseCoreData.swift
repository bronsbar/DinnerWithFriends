//
//  UpdatePublicDatabaseCoreData.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 27/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class UpdatePublicDatabaseCoreData: Operation {
    var changedRecords : [CKRecord]
    var deletedRecords : [CKRecordID]
    
    override init() {
        self.changedRecords = []
        self.deletedRecords = []
    }

}
