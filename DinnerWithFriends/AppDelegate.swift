//
//  AppDelegate.swift
//  DinnerWithFriends5.0
//
//  Created by Bart Bronselaer on 20/12/17.
//  Copyright © 2017 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit
import CoreData
import Foundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    

    lazy var coreDataStack = CoreDataStack(modelName: "DinnerWithFriends")
    
//    var dinnerPictures :[UIImage] = []
    let cloudKitManager = CloudKitManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      
        // propagate the managedContext
        
        guard let tabBarController = window?.rootViewController as? UITabBarController, let navController = tabBarController.childViewControllers.first as? UINavigationController, let viewController = navController.topViewController as? DinnerItemTableViewController else { print ("managedcontext not propagated")
            return true
        }
        
        
        guard let navController2 = tabBarController.childViewControllers[1] as? UINavigationController else {
            print("tweede navcontroller niet gevonden")
            return true
        }
        guard let viewController2 = navController2.topViewController as? DinnerCreatorViewController else {
            print( "dinnercreator controller niet gevonden")
            return true
        }
        
        viewController.coreDataStack = coreDataStack
        viewController2.coreDataStack = coreDataStack
        
        // Initialisation operation: check if cloudKit zones on the server exist
        cloudKitManager.initialisationOperation()
        
        // Check if the subscription to Zones exist, if not create them and flush a flag to Disk
        cloudKitManager.subscribeToDatabaseZones()
        
//        cloudKitManager.createPublicDatabaseSubscription()
//        let userDefault = UserDefaults.standard
//        if !userDefault.exists(key: UserDefaultKeys.subscribedToPublicChanges.rawValue) {
//             cloudKitManager.subscribeToPublicDatabase()
//        }
        
        // Update the local database with changes on the  CloudKit server
        cloudKitManager.updateLocalCache(databaseScope: .private, with: coreDataStack)
        
        
        
//        configureCloudKit()
        // if Core Data is empty, import the dinnerItems from Cloudkit
        importCloudKitDataIfNeeded(toUpdate: viewController)
//        subscribeToChangeNotifications()
        print(NSHomeDirectory())
        
        //register to recieve remote notifications
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("received notification")
        
        if let stringObjectUserInfo = userInfo as? [String : NSObject] {
            let notification = CKNotification(fromRemoteNotificationDictionary: stringObjectUserInfo)
            let completionBlockOperation = BlockOperation(block: {
                completionHandler(UIBackgroundFetchResult.newData)
            })
            cloudKitManager.synZone(notification: notification, completionBlockOperation: completionBlockOperation, coreDataStack: coreDataStack)
        }
        else {
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("application did succesfully registered for remote notification")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("app did fail to register for remote notification error :\(error)")
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        coreDataStack.saveContext()
        print( "Application did enter Background, CoreDataStack Saved")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        coreDataStack.saveContext()
        print("application will terminate, coreDataStack saved")
    }
}

// MARK: - Helper Methods
extension AppDelegate {
    
    
    
    private func configureCloudKit() {
        let container = CKContainer(identifier: "iCloud.bart.bronselaer-me.com.DinnerWithFriends")
        container.privateCloudDatabase.fetchAllRecordZones { zones, error in
            guard let zones = zones, error == nil else {
                
                // error handling
                return
            }
            print ("I have these zones : \(zones)")
            for zones in zones {
                print (zones.zoneID.zoneName)
            }
        }
    }
    
    private func importCloudKitDataIfNeeded(toUpdate viewController: DinnerItemTableViewController) {
        
        let fetchRequest: NSFetchRequest<DinnerItems> = DinnerItems.fetchRequest()
        let count = try? coreDataStack.managedContext.count(for: fetchRequest)
        
        // check if there are dinnerItems in the coreDataStack
        guard let dinnerItemsCount = count,
            dinnerItemsCount == 0 else {
                return
        }
        // When there are no dinnerItems
        importCloudKitData(toUpdate: viewController)
    }
    
    private func importCloudKitData(toUpdate viewController: DinnerItemTableViewController) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "DinnerItem", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { record in
            let entityDescription = NSEntityDescription.entity(forEntityName: "DinnerItems", in: self.coreDataStack.managedContext)
            if let entityDescription = entityDescription {
                // create DinnerItems objects
                let dinnerItem = DinnerItems(from: record, context: self.coreDataStack.managedContext, description: entityDescription)
                print(dinnerItem.name!)
            }
            
        }
        operation.queryCompletionBlock = { cursor, error in
            if let error = error {
                print ("error, \(error)")
            }
            self.coreDataStack.saveContext()
            // print to console how much in core data
            let fetchRequest: NSFetchRequest<DinnerItems> = DinnerItems.fetchRequest()
            let count = try? self.coreDataStack.managedContext.count(for: fetchRequest)
            print(" number of items loaded : \(String(describing: count))")
            // when the dinnerItems are saved to Core Data, perform a fetch on the main Queue and reload the data in the tableView
            DispatchQueue.main.async {
                do {
                    try viewController.fetchedResultsController.performFetch()
                    
                } catch let error as NSError {
                    print ("Fetching error: \(error), \(error.userInfo)")
                }
                viewController.tableView.reloadData()
            }
            
        }
        
        cloudKitManager.container.privateCloudDatabase.add(operation)
    }
}

//    private func subscribeToChangeNotifications() {
//        // check if there is a Local UserDefault file and if so what is the value of the subscribedToPrivateChanges key
//        let userDefault = UserDefaults.standard
//        // if user default file does not exist, create it
//        if !userDefault.exists(key: "subscribedToPrivateChanges") {
//
//            userDefault.set(false, forKey: "createdCustomZone")
//            userDefault.set(false, forKey: "subscribedToPrivateChanges" )
//            userDefault.set(false, forKey: "subscribedToSharedChanges")
//            userDefault.set("", forKey: "privateDatabaseToken")
//            userDefault.set("", forKey: "sharedDatabaseToken")
//            subscriptionToChanges()
//        }
//        else {
//            subscriptionToChanges()
//        }
//    }
//
//    // subscribe to changes in the private and shared CKdatabase
//    func subscriptionToChanges() {
//
//        let userDefault = UserDefaults.standard
//        let subscriptionToPrivateChanges = userDefault.bool(forKey: "subscribedToPrivateChanges")
//        if !subscriptionToPrivateChanges {
//            let createSubscriptionOperation = createDabtabaseSubscriptionOperation(subscriptionID: "private-changes")
//
//            createSubscriptionOperation.modifySubscriptionsCompletionBlock = { (subscriptions, deletedIds, error) in
//                if error == nil {
//                    print ("subcription to private-changes was succesfull")
//                    userDefault.set(true, forKey: "subscribedToPrivateChanges")
//                }
//                else {
//                    // custom error handling:
//                    print("subscription returned error: \(error!)")
//                }
//            }
//            self.container.privateCloudDatabase.add(createSubscriptionOperation)
//        }
//
//        let subscriptionToSharedChanges = userDefault.bool(forKey: "subscribedToSharedChanges")
//        if !subscriptionToSharedChanges {
//            let createSubscriptionOperation = createDabtabaseSubscriptionOperation(subscriptionID: "shared-changes")
//
//            createSubscriptionOperation.modifySubscriptionsCompletionBlock = { (subscriptions, deletedIds, error) in
//                if error == nil {
//                    print ("subcription to shared-changes was succesfull")
//                    userDefault.set(true, forKey: "subscribedToSharedChanges")
//                }
//                else {
//                    // custom error handling:
//                    print("subscription returned error: \(error!)")
//
//                }
//            }
//            self.container.sharedCloudDatabase.add(createSubscriptionOperation)
//        }
//    }
//    // helper function to create a database subscription operation
//    func createDabtabaseSubscriptionOperation(subscriptionID: String)-> CKModifySubscriptionsOperation {
//
//        let subscription = CKDatabaseSubscription.init(subscriptionID: subscriptionID)
//        let notificationInfo = CKNotificationInfo()
//        // send a silent notification
//        notificationInfo.shouldSendContentAvailable = true
//        subscription.notificationInfo = notificationInfo
//
//        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
//        operation.qualityOfService = .utility
//        return operation
//    }
////
//    func fetchChanges(in databaseScope: CKDatabaseScope, completion: @escaping () -> Void) {
//        switch databaseScope {
//        case .private:
//            break
////          fetchDatabaseChanges(database: container.privateCloudDatabase, databaseTokenKey: "private", completion: completion)
//        case .shared:
//            break
////            fetchDatabaseChanges(database: container.sharedCloudDatabase, databaseTokenKey: "shared", completion: completion)
//        case .public:
//            fetchDatabaseChanges(database: container.publ, databaseTokenKey: "shared", completion: completion)
//        }
//    }
//    func fetchDatabaseChanges (database : CKDatabase, databaseTokenKey: String, completion: @escaping () -> Void) {
//        var changedZoneIDs : [CKRecordZoneID] = []
//        var changeToken : CKServerChangeToken?
//        let userDefault = UserDefaults.standard
//
//        switch database {
//        case container.sharedCloudDatabase:
//            changeToken = userDefault.sharedDBserverChangeToken
//        case container.privateCloudDatabase:
//            changeToken = userDefault.privateDBserverChangeToken
//        case container.publicCloudDatabase:
//            fatalError()
//        default:
//            fatalError()
//        }
//
//        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: changeToken)
//
//        operation.recordZoneWithIDChangedBlock = {
//            (zoneID) in
//            changedZoneIDs.append(zoneID)
//        }
//
//        operation.recordZoneWithIDWasDeletedBlock = { (zoneID) in
//            // write this zone deletion to memory
//        }
//
//        operation.changeTokenUpdatedBlock = { (token) in
//            // flush zone deletions for this database to disk
//            // write this new database change token to disk
//            switch database {
//            case self.container.sharedCloudDatabase:
//                userDefault.sharedDBserverChangeToken = token
//            case self.container.privateCloudDatabase:
//                userDefault.privateDBserverChangeToken = token
//            default:
//                fatalError()
//            }
//        }
//        operation.fetchDatabaseChangesCompletionBlock = { (token, moreComing, error) in
//            if let error = error {
//                print("Error during fetch share database changes operaton", error)
//                completion()
//                return
//            }
//            //flush zone deletions for this database to disk
//            // write this new database change token to memory
//            switch database {
//            case self.container.sharedCloudDatabase:
//                userDefault.sharedDBserverChangeToken = token
//            case self.container.privateCloudDatabase:
//                userDefault.privateDBserverChangeToken = token
//            default:
//                fatalError()
//            }
//            self.fetchZoneChanges(database: database, databaseTokenKey: databaseTokenKey, zoneIDs: changedZoneIDs, completion: {
//                //Flush in-memory database change token to disk
//                completion()
//            })
//        }
//        operation.qualityOfService = .userInitiated
//
//        database.add(operation)
//
//
//        }
//    func fetchZoneChanges(database:CKDatabase, databaseTokenKey:String, zoneIDs: [CKRecordZoneID], completion: @escaping () -> Void) {
//
//    }
//
//    func convertMetadataFromCkRecord(from record: CKRecord)-> NSMutableData {
//        let data = NSMutableData()
//        let coder = NSKeyedArchiver.init(forWritingWith: data)
//        coder.requiresSecureCoding = true
//        record.encodeSystemFields(with: coder)
//        coder.finishEncoding()
//
//        return data
//
//    }
//
//    func convertMetadataFromManagedObject(from data: NSMutableData) -> CKRecord? {
//
//        let coder = NSKeyedUnarchiver(forReadingWith: data as Data)
//        coder.requiresSecureCoding = true
//        if let record = CKRecord(coder: coder){
//            coder.finishDecoding()
//            return record
//        } else {
//            coder.finishDecoding()
//            print ("error in decoding ManagedObject")
//            return nil
//        }
//    }
//}







