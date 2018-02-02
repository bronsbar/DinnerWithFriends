//
//  FetchAllRecordZonesOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 22/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class FetchAllRecordZonesOperation: CKFetchRecordZonesOperation {
    var fetchedRecordZones : [CKRecordZoneID: CKRecordZone]? = nil
    
    override func main() {
        print("FetchAllRecordZonesOperation.main()")
        self.setBlock()
        super.main()
    }
    
    func setBlock() {
        self.fetchRecordZonesCompletionBlock = { [unowned self]
            (recordZones, error) in
            print("FetchAllRecordZonesOperation.fetchRecordCompletionBlock")
            if let error = error {
                print("FetchAllRecordZonesOperation error: \(error)")
            }
            if let recordZones = recordZones {
                self.fetchedRecordZones = recordZones
                for recordZonesID in recordZones.keys {
                    print(recordZonesID)
                }
                // set recordZones in UserDefault
                let recordZonesData = NSKeyedArchiver.archivedData(withRootObject: recordZones)
                let userDefault = UserDefaults.standard
                userDefault.set(recordZonesData, forKey: "recordZones")
            }
        }
    }
}
