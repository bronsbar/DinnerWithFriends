//
//  BackGroundPicturesCollectionViewController.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 29/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit
import CoreData

private let reuseIdentifier = "Cell"

class BackGroundPicturesCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedController: NSFetchedResultsController<BackgroundPictures>!
    var coreDataStack : CoreDataStack!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NotificationCenter.default
        let name = Notification.Name("Update Interface")
        center.addObserver(self, selector: #selector(updateInterface(notification:)), name: name, object: nil)
        
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        coreDataStack = appDelegate.coreDataStack
        
        let request: NSFetchRequest<BackgroundPictures> = BackgroundPictures.fetchRequest()
        let sort = NSSortDescriptor(key: "pictureName", ascending: true)
        request.sortDescriptors = [sort]
        fetchedController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedController.delegate = self
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        do {
            try fetchedController.performFetch()
            collectionView?.reloadData()
        } catch {
            print ("error in viewwill appear reloading collectionViewdata ")
        }
    }
    
    @objc func updateInterface(notification: Notification) {
        let main = OperationQueue.main
        main.addOperation {
            do {
                try self.fetchedController.performFetch()
                self.collectionView?.reloadData()
            } catch {
                print ("error in updateInterface after notification")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
       
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedController.sections {
            let sectionInfo = sections[section]
            print("number of objects in backgroundpicture collectionview \(sectionInfo.numberOfObjects)")
            return sectionInfo.numberOfObjects
        } else {
        return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BackgroundPictureCollectionViewCell
    
        // Configure the cell
        
        let backgroundPicture = fetchedController.object(at: indexPath)
        
        if let backgroundPictureData = backgroundPicture.picture {
            let backgroundPictureImage = UIImage(data: backgroundPictureData as Data)
            cell.backgroundPicture.image = backgroundPictureImage
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
