//
//  DinnerCreatorViewController.swift
//  DinnerWithFriends5.0
//
//  Created by Bart Bronselaer on 9/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class DinnerCreatorViewController: UIViewController{
    
    // MARK: - Outlets
    @IBOutlet weak var wrapperViewDinnerItemCollection: UIView!
    
   var wrapperViewZeroHeightConstraint: NSLayoutConstraint!
 
    @IBOutlet var dinnerItemCollectionTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var menuBarCollectionView: CreateDinnerCollectionView!
    
    @IBOutlet weak var dinnerItemsCollectionView: UICollectionView!
    @IBOutlet weak var dinnerCollectionView: UICollectionView!
    @IBOutlet weak var backgroundPicture: UIImageView!
    
    // MARK: - Properties
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    var menuItems = ["friendsIcon", "dinnerItemIcon", "wineIcon", "dessertsIcon","searchIcon"]
    // coreDataStack initialized from AppDelegate
    var coreDataStack : CoreDataStack!
    // fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController<DinnerItems> = {
        let fetchRequest: NSFetchRequest<DinnerItems> = DinnerItems.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(DinnerItems.name), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: "DinnerCreator")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    // array of BlockOperations to execute multiple changes in nsfetchedresultscontroller, used in the extension delegate for nsfetchedresultscontroller
    var blockOperation = [BlockOperation]()
    
    // Dinner array holding the selected dinnerItems
    var dinnerCreation = [DinnerCreation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set collectionView delegate and datasource
        dinnerItemsCollectionView.delegate = self
        dinnerItemsCollectionView.dataSource = self
        dinnerCollectionView.delegate = self
        dinnerCollectionView.dataSource = self
        
        // assign the drag and dropDelegate for the dinnerCollectionView to self and enable drag
        dinnerCollectionView.dropDelegate = self
        dinnerCollectionView.dragDelegate = self
        dinnerCollectionView.dragInteractionEnabled = true
        
        // assign the dragDelegate for the dinnerItemsCollectionView to self and enable drag
        dinnerItemsCollectionView.dragDelegate = self
        dinnerItemsCollectionView.dragInteractionEnabled = true
        
        // assign menubar delegate and datasource
        menuBarCollectionView.delegate = self
        menuBarCollectionView.dataSource = self
     
        
        
        
    
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        animateDinnerItemsCollectionView()
        loadRandomBackgroundPicture()
        do {
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            print ("Fetching error: \(error), \(error.userInfo)")
        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: -Helper functions
    
    // animate the dinnerItemsCollectionViewBar
    
    private func animateDinnerItemsCollectionView() {
        if self.wrapperViewZeroHeightConstraint == nil {
            self.wrapperViewZeroHeightConstraint = self.wrapperViewDinnerItemCollection.heightAnchor.constraint(equalToConstant: 0)
        }
        
        let shouldShow = !dinnerItemCollectionTopConstraint.isActive
        // Deactivate constraint first to avoid constraint conflict message
        if shouldShow {
            self.wrapperViewZeroHeightConstraint.isActive = false
            self.dinnerItemCollectionTopConstraint.isActive = true
            backgroundPicture.alpha = 0.1
        } else {
            self.dinnerItemCollectionTopConstraint.isActive = false
            self.wrapperViewZeroHeightConstraint.isActive = true
            backgroundPicture.alpha = 1.0
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
   private func loadRandomBackgroundPicture() {
    let maxNumber = delegate.dinnerPictures.count
    let randomNumber = arc4random_uniform(UInt32(maxNumber))
    backgroundPicture.image = delegate.dinnerPictures[Int(randomNumber)]
    
    }
}

// MARK: -NSFetchedResultsControllerDelegate

extension DinnerCreatorViewController: NSFetchedResultsControllerDelegate {
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            // use block operations for multiple inserts
            blockOperation.append(BlockOperation(block: {
                self.dinnerItemsCollectionView.insertItems(at: [newIndexPath!])
            }))
            
        case .delete:
            // use block operations for multiple deletes
            blockOperation.append(BlockOperation(block: {
               self.dinnerItemsCollectionView.deleteItems(at: [indexPath!])
            }))
            
        case .update:
            let cell = dinnerItemsCollectionView.cellForItem(at: indexPath!) as! DinnerItemCollectionViewCell
            configureCell(cell: cell, at: indexPath!)
        case .move:
            dinnerItemsCollectionView.deleteItems(at: [indexPath!])
            dinnerItemsCollectionView.insertItems(at: [newIndexPath!])
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dinnerItemsCollectionView.performBatchUpdates({
            // start the operations logged in blockoperation
            for operation in blockOperation {
                operation.start()
            }
        }) { (completed) in
            self.blockOperation = []
        }
    }
}

// MARK: -UICollectionView datasource and delegate
extension DinnerCreatorViewController: UICollectionViewDataSource, UICollectionViewDelegate {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfItems : Int = 0
        switch collectionView {
        case dinnerItemsCollectionView:
            if let numberOfObjects = fetchedResultsController.fetchedObjects?.count {
                numberOfItems = numberOfObjects
            }
        case dinnerCollectionView:
            numberOfItems = dinnerCreation.count
        case menuBarCollectionView:
            numberOfItems = menuItems.count
        default:
            numberOfItems = 0
        }
        return numberOfItems
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == dinnerItemsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dinnerItemsCollectionViewCell", for: indexPath) as! DinnerItemCollectionViewCell
            configureCell(cell: cell, at: indexPath)
            return cell
        } else {
            if collectionView == dinnerCollectionView {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dinnerCollectionViewCell", for: indexPath) as! DinnerCollectionViewCell
                let dinnerItem = dinnerCreation[indexPath.item]
                let image = dinnerItem.image
                cell.image.image = image
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! MenuBarCollectionViewCell
                cell.menuBarImage.image = UIImage(named: menuItems[indexPath.row])
                return cell
            }
            
        }
    }
    
    func configureCell(cell:DinnerItemCollectionViewCell, at indexPath: IndexPath) {
        let dinnerItem = fetchedResultsController.object(at: indexPath)
        
        cell.label.text = dinnerItem.name
        if let image = dinnerItem.convertNSDataToUIImage(from: dinnerItem.image) {
            cell.image.image = image
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == menuBarCollectionView {
            animateDinnerItemsCollectionView()
            dinnerItemsCollectionView.reloadData()
        }
    }
    
}

// MARK: -CollectionView drop delegate
extension DinnerCreatorViewController : UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if collectionView == dinnerCollectionView {
            return session.canLoadObjects(ofClass: UIImage.self)
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        coordinator.session.loadObjects(ofClass: UIImage.self) { (images) in
            guard let imagesArray = images as? [UIImage] else {return}
            
            collectionView.performBatchUpdates({
                let newDinnerCreation = DinnerCreation()
                newDinnerCreation.image = imagesArray.first
                self.dinnerCreation.insert(newDinnerCreation, at: destinationIndexPath.item)
                collectionView.insertItems(at: [destinationIndexPath])
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        // when the session drags from within the collectionview
        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            // when the session drags from somewhere else
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
}

// MARK: -CollectionView Drag Delegate

extension DinnerCreatorViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        print(indexPath)
    let dinnerItemSelected = fetchedResultsController.object(at: indexPath)
        let image = dinnerItemSelected.convertNSDataToUIImage(from: dinnerItemSelected.image)!
        
        let itemProvider = NSItemProvider(object: image)
        let dragItem = UIDragItem(itemProvider: itemProvider)
       return [dragItem]
    }
}




class DinnerCreation {
    var image : UIImage!
    
}
