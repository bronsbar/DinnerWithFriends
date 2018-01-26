//
//  FetchAllPublicDatabaseSubscriptionsOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 24/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class FetchAllPublicDatabaseSubscriptionsOperation: CKFetchSubscriptionsOperation {
        var fetchedSubscriptions : [String : CKQuerySubscription]
        
        override init() {
            fetchedSubscriptions = [:]
            super.init()
        }
        
        override func main() {
            print ("FetchAllPublicDatabaseSubscriptionsOperation.main()")
            self.setBlock()
            super.main()
        }
        
        func setBlock() {
            self.fetchSubscriptionCompletionBlock = {
                (subscriptions, error) in
                print("FetchAllPublicDatabaseSubscriptionsOperation.fetchSubscriptionCompletionBlock")
                if let error = error {
                    print("FetchPublicDatabaseSubscription Error: \(error)")
                }
                if let subscriptions = subscriptions {
                    self.fetchedSubscriptions = subscriptions as! [String: CKQuerySubscription]
                    for subscriptionID in subscriptions.keys {
                        print ("Fetched CKQuerySubscription : \(subscriptionID)")
                    }
                }
            }
        }
    }
