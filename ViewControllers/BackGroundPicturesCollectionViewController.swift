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
    
    lazy var fetchedController: NSFetchedResultsController<BackgroundPictures> = {
        let fetchRequest: NSFetchRequest<BackgroundPictures> = BackgroundPictures.fetchRequest()
        let sort = NSSortDescriptor(key: "pictureName", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        return fetchResultsController
    }()
    
    var coreDataStack : CoreDataStack!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let center = NotificationCenter.default
//        let name = Notification.Name("Update Interface")
//        center.addObserver(self, selector: #selector(updateInterface(notification:)), name: name, object: nil)
//
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        coreDataStack = appDelegate.coreDataStack
        
        
        do {
            try fetchedController.performFetch()
        } catch let error as NSError {
            print ("Fetching error: \(error), \(error.userInfo)")
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        collectionView?.reloadData()
    }
    
//    @objc func updateInterface(notification: Notification) {
//        let main = OperationQueue.main
//        main.addOperation {
//            do {
//                try self.fetchedController.performFetch()
//                self.collectionView?.reloadData()
//            } catch {
//                print ("error in updateInterface after notification")
//            }
//        }
//    }

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
       
        guard let sections = fetchedController.sections else {
            return 0
        }
        return sections.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sectionsInfo = fetchedController.sections?[section] else {
            return 0
        }
        return sectionsInfo.numberOfObjects
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BackgroundPictureCollectionViewCell
         // Configure the cell
        configureCell(cell: cell, cellForItemAt: indexPath)
        return cell
        
    }
    
    func configureCell(cell:BackgroundPictureCollectionViewCell, cellForItemAt indexPath: IndexPath) {
        
        let backgroundPicture = fetchedController.object(at: indexPath)
        
        if let backgroundPictureData = backgroundPicture.picture {
            let backgroundPictureImage = backgroundPicture.convertNSDataToUIImage(from: backgroundPictureData)
            cell.backgroundPicture.image = backgroundPictureImage
        }
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
    
    var blockOperations = [BlockOperation]()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            // use block operations for multiple inserts
            blockOperations.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
            
        case .delete:
            // use block operations for multiple deletes
            blockOperations.append(BlockOperation(block: {
                self.collectionView?.deleteItems(at: [indexPath!])
            }))
            
        case .update:
            let cell = collectionView?.cellForItem(at: indexPath!) as! BackgroundPictureCollectionViewCell
            configureCell(cell: cell, cellForItemAt: indexPath!)
        case .move:
            collectionView?.deleteItems(at: [indexPath!])
            collectionView?.insertItems(at: [newIndexPath!])
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            // start the operations logged in blockoperation
            for operation in blockOperations {
                operation.start()
            }
        }) { (completed) in
            self.blockOperations = []
        }
    }
}
