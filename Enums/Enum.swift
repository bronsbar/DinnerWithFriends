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

enum PublicDatabaseQuerySubscription: String {
    case publicDatabaseChange = "publicDatabaseChange"
    
    static let allPublicDatabaseSubscriptions = [PublicDatabaseQuerySubscription.publicDatabaseChange.rawValue]
    
    func publicDatabaseQuerySubscription() -> CKQuerySubscription {
        let predicate = NSPredicate(value: true)
        let querySubscription = CKQuerySubscription(recordType: PublicDatabaseTypes.backgroundPicture.rawValue, predicate: predicate, subscriptionID: self.rawValue, options: [.firesOnRecordCreation,.firesOnRecordDeletion,.firesOnRecordUpdate])
        querySubscription.notificationInfo = self.notificationInfo()
        return querySubscription
    }
    func notificationInfo() -> CKNotificationInfo {
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "Subscription Notification for \(self.rawValue)"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.shouldBadge = false
        return notificationInfo
    }
}

enum PublicDatabaseTypes : String {
    case dinnerItem = "DinnerItem"
    case backgroundPicture = "BackgroundPicture"
}

enum UserDefaultKeys : String {
    case subscribedToPublicChanges = "subscribedToPublicChanges"
    case publicServerChangeToken = "publicServerChangeToken"
}

extension UserDefaults {
    func exists(key:String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
