//
//  Enum.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 22/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import Foundation
import CloudKit

enum CloudKitZone: String {
    case dinnerItemsZone = "dinnerItemsZone"
    
    static let allCloudKitZoneNames = [CloudKitZone.dinnerItemsZone.rawValue]
    
    func recordZoneID() -> CKRecordZoneID {
        return CKRecordZoneID(zoneName: self.rawValue)
    }
}
