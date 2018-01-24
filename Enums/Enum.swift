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
    case backgroundPicture = "backgroundPicture"
   
    
    static let allCloudKitZoneNames = [CloudKitZone.dinnerItemsZone.rawValue, CloudKitZone.backgroundPicture.rawValue]
    
    func recordZoneID() -> CKRecordZoneID {
        return CKRecordZoneID(zoneName: self.rawValue, ownerName: CKCurrentUserDefaultName)
    }
    func cloudKitSubscription() -> CKRecordZoneSubscription {
        let subscription = CKRecordZoneSubscription(zoneID: self.recordZoneID())
        subscription.notificationInfo = self.notificationInfo()
        return subscription
    }
    func notificationInfo() -> CKNotificationInfo {
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "Subscription notification for \(self.rawValue)"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.shouldBadge = false
        return notificationInfo
    }
}
