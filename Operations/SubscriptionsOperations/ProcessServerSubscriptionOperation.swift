//
//  ProcessServerSubscriptionOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 24/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class ProcessServerSubscriptionOperation: Operation {
    var preProcessedFetchedSubscriptions : [String:CKRecordZoneSubscription]
    var postProcessSubscriptionsToCreate : [CKRecordZoneSubscription]?
    var postProcessSubscriptionsToDelete : [String]?
    
    override init() {
        self.preProcessedFetchedSubscriptions = [:]
        self.postProcessSubscriptionsToCreate = nil
        self.postProcessSubscriptionsToDelete = nil
        super.init()
    }
    
    override func main() {
        print( "ProcessServerSubscriptionOperation.main()")
        setSubscriptionsToCreate()
        setSubscriptionsToDelete()
    }
    
    func setSubscriptionsToCreate() {
        let serverSubscriptionZoneNameSet = self.createServerSubscriptionZoneNameSet()
        let expectedZoneNamesWithSubscriptionSet = Set(CloudKitZone.allCloudKitZoneNames)
        let missingSubscriptionZoneNameSet = expectedZoneNamesWithSubscriptionSet.subtracting(serverSubscriptionZoneNameSet)
        
        if missingSubscriptionZoneNameSet.count > 0 {
            postProcessSubscriptionsToCreate = []
            for missingSubscriptionZoneName in missingSubscriptionZoneNameSet {
                if let cloudKitSubscription = CloudKitZone(rawValue: missingSubscriptionZoneName) {
                    postProcessSubscriptionsToCreate?.append(cloudKitSubscription.cloudKitSubscription())
                }
            }
        }
    }
    
    func setSubscriptionsToDelete()  {
        let serverSubscriptionZoneNameSet = self.createServerSubscriptionZoneNameSet()
        let expectedZoneNamesWithSubscriptionSet = Set(CloudKitZone.allCloudKitZoneNames)
        let unexpectedSubscriptionZoneNameSet = serverSubscriptionZoneNameSet.subtracting(expectedZoneNamesWithSubscriptionSet)
        
        if unexpectedSubscriptionZoneNameSet.count > 0 {
            postProcessSubscriptionsToDelete = []
            
            var subscriptionZoneNameDictionary : [String: CKRecordZoneSubscription] = [:]
            for subscripton in preProcessedFetchedSubscriptions.values {
                let zoneID = subscripton.zoneID
                subscriptionZoneNameDictionary[zoneID.zoneName] = subscripton
            }
            for subscriptionZoneName in unexpectedSubscriptionZoneNameSet {
                if let subscription = subscriptionZoneNameDictionary[subscriptionZoneName] {
                    postProcessSubscriptionsToDelete?.append(subscription.subscriptionID)
                }
            }
        }    
    }
    
    func createServerSubscriptionZoneNameSet() -> Set<String> {
        let serverSubscriptions = Array(preProcessedFetchedSubscriptions.values)
        let serverSubscriptionZoneIDs = serverSubscriptions.flatMap {$0.zoneID}
        let serverSubscriptionZoneNameSet = Set(serverSubscriptionZoneIDs.map {$0.zoneName} )
        
        return serverSubscriptionZoneNameSet
    }
    

}
