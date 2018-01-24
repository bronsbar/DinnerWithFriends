//
//  FetchAllSubscriptionsOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 24/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class FetchAllSubscriptionsOperation: CKFetchSubscriptionsOperation {
    var fetchedSubscriptions : [String : CKRecordZoneSubscription]
    
    override init() {
        fetchedSubscriptions = [:]
        super.init()
    }
    
    override func main() {
        print ("FetchedAllSubscriptionsOperation.main()")
        self.setBlock()
        super.main()
    }
    
    func setBlock() {
        self.fetchSubscriptionCompletionBlock = {
            (subscriptions, error) in
            print("FetchAllSubscriptionsOperation.fetchSubscriptionCompletionBlock")
            if let error = error {
                print("FetchAllSubscriptions Error: \(error)")
            }
            if let subscriptions = subscriptions {
                self.fetchedSubscriptions = subscriptions as! [String: CKRecordZoneSubscription]
                for subscriptionID in subscriptions.keys {
                    print ("Fetched CKSubscription : \(subscriptionID)")
                }
            }
        }
    }
}
