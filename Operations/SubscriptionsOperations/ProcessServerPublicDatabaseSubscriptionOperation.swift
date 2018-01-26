//
//  ProcessServerPublicDatabaseSubscriptionOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 24/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class ProcessServerPublicDatabaseSubscriptionOperation: Operation {
    
        var preProcessedFetchedSubscriptions : [String:CKQuerySubscription]
        var postProcessSubscriptionsToCreate : [CKQuerySubscription]?
        var postProcessSubscriptionsToDelete : [String]?
        
        override init() {
            self.preProcessedFetchedSubscriptions = [:]
            self.postProcessSubscriptionsToCreate = nil
            self.postProcessSubscriptionsToDelete = nil
            super.init()
        }
        
        override func main() {
            print( "ProcessServerPublicDatabaseSubscriptionOperation.main()")
            setSubscriptionsToCreate()
            setSubscriptionsToDelete()
        }
        
        func setSubscriptionsToCreate() {
            let serverSubscriptionIDSet = self.createServerSubscriptionIDSet()
            let expectedSubscriptionIDSet = Set(PublicDatabaseQuerySubscription.allPublicDatabaseSubscriptions)
            let missingSubscriptionIDSet = expectedSubscriptionIDSet.subtracting(serverSubscriptionIDSet)
            
            if missingSubscriptionIDSet.count > 0 {
                postProcessSubscriptionsToCreate = []
                for missingSubscriptionID in missingSubscriptionIDSet {
                    if let publicDatabaseQuerySubscription = PublicDatabaseQuerySubscription(rawValue: missingSubscriptionID) {
                        postProcessSubscriptionsToCreate?.append(publicDatabaseQuerySubscription.publicDatabaseQuerySubscription())
                    }
                }
            }
        }
        
        func setSubscriptionsToDelete()  {
            let serverSubscriptionIDSet = self.createServerSubscriptionIDSet()
            let expectedSubscriptionIDSet = Set(PublicDatabaseQuerySubscription.allPublicDatabaseSubscriptions)
            let unexpectedSubscriptionIDSet = serverSubscriptionIDSet.subtracting(expectedSubscriptionIDSet)
            
            if unexpectedSubscriptionIDSet.count > 0 {
                postProcessSubscriptionsToDelete = []
                
//                var subscriptionIDDictionary : [String: CKQuerySubscription] = [:]
                for subscripton in preProcessedFetchedSubscriptions.values {
                    let subscriptionID = subscripton.subscriptionID
//                    subscriptionIDDictionary[zoneID.zoneName] = subscripton
                    postProcessSubscriptionsToDelete?.append(subscriptionID)
                }
//                for subscriptionZoneName in unexpectedSubscriptionZoneNameSet {
//                    if let subscription = subscriptionZoneNameDictionary[subscriptionZoneName] {
//                        postProcessSubscriptionsToDelete?.append(subscription.subscriptionID)
//                    }
//                }
            }
        }
        
        func createServerSubscriptionIDSet() -> Set<String> {
            let serverSubscriptions = Array(preProcessedFetchedSubscriptions.values)
            let serverSubscriptionIDs = serverSubscriptions.map {$0.subscriptionID}
            let serverSubscriptionIDSet = Set(serverSubscriptionIDs)
            
            return serverSubscriptionIDSet
        }
        
        
    }

