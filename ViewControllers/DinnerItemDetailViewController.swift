//
//  DinnerItemDetailViewController.swift
//  DinnerWithFriends5.0
//
//  Created by Bart Bronselaer on 21/12/17.
//  Copyright © 2017 Bart Bronselaer. All rights reserved.
//

import UIKit
import SafariServices
import CoreGraphics
import CoreData

class DinnerItemDetailViewController: UIViewController {
    
    
    // MARK: -Properties
    
    var newItem : Bool = false // is set true by when + is selected in the dinnerItemList
    var dinnerItemDetail : DinnerItems? // will be set when a dinnerItem is passed from the dinnerItem list
    
    var coreDataStack : CoreDataStack!
    
    var categories = [ "dinnerItemIcon", "wineIcon", "dessertsIcon"]
    var categorySelected : String = "" {
        didSet {
            guard categorySelected != "" else {return}
            let image = UIImage(named: categorySelected)
            self.updateCategorySelection(with: image)
        }
    }
    
    // MARK: -Outlets
    
    @IBOutlet weak var wrapperViewCategoryBar: UIView!
    
    
    @IBOutlet var categoryBarEdgeContstraint: NSLayoutConstraint!
    
    var wrapperViewZeroHeightConstraint : NSLayoutConstraint!
    
    @IBOutlet weak var categoryBarCollectionView: DinnerDetailCategoryCollectionView!
    
    
    
    
    @IBOutlet weak var selectedCategoryImage: UIImageView! {
        didSet {
            selectedCategoryImage.tintColor = UIColor.darkGray
        }
    }
    @IBOutlet weak var notesContainer: UIView! {
        didSet {
            notesContainer.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            notesContainer.layer.borderWidth = 0.5
            notesContainer.layer.cornerRadius = notesContainer.bounds.height * 0.1
            
        }
    }
    @IBOutlet weak var imageContainer: UIView!
    // add a dropshadow to the imageContainer
    
    @IBAction func categoryImageTapped(_ sender: Any) {
        print("categoryimage tapped")
        animateCategoryMenuBar()
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        let shadowPath = UIBezierPath(rect: imageContainer.layer.bounds)
        imageContainer.layer.masksToBounds = false
        imageContainer.layer.shadowOpacity = 0.5
        imageContainer.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        imageContainer.layer.shadowRadius = 3
        imageContainer.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        imageContainer.layer.shadowPath = shadowPath.cgPath
        
        
    }
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var urlLabel: UITextField! {
        didSet {
            urlLabel.layer.cornerRadius = urlLabel.bounds.height * 0.1
        }
    }
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var ratingLabel: UITextField! {
        didSet {
            ratingLabel.layer.cornerRadius = ratingLabel.bounds.height * 0.1
        }
    }
    
    @IBOutlet weak var notesLabel: UITextView! {
        didSet {
            notesLabel.layer.cornerRadius = notesLabel.bounds.height * 0.10
        }
    }
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func urlLabelTapped(_ sender: UITextField) {
        // select een url via SafariController
        selectUrl()
    }
    @IBAction func textEditingChanged(_ sender: UITextField) {
        // Save button is only active when the name field is filled out
        updateSaveButtonStatus()
    }
    @IBAction func picturedTapped(_ sender: UITapGestureRecognizer) {
        print("picture tapped")
        updateImage()
    }
    
    // MARK: Pan the Image
    // helpermethod transform calculates the transform
    private func transform(for translation: CGPoint) -> CGAffineTransform {
        let moveBy = CGAffineTransform(translationX: translation.x, y: translation.y)
        let rotation = -sin(translation.x / (imageContainer.frame.width * 4.0))
        return moveBy.rotated(by: rotation)
    }
    
    @IBAction func panImage(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: imageContainer.superview)
            imageContainer.transform = transform(for: translation)
        case .ended:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: [], animations : {self.imageContainer.transform = .identity}, completion: nil)
            
        default:
            break
        }
        
    }
    
    
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButtonStatus()
        
        // if a dinnerItem has been sent by the list, set the fields
        if let receivedDinnerItem = dinnerItemDetail {
            updateFields(with: receivedDinnerItem)
        }
        
        // set delegate and datasource for categoryBarCollectionview as an extension
        categoryBarCollectionView.delegate = self
        categoryBarCollectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveDinnerItemSegue" {
            addDinnerItem()
        }
    }

}

extension DinnerItemDetailViewController :SFSafariViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: HelperFunctions
    
    private func updateFields(with dinnerItem : DinnerItems) {
        
        if let category = dinnerItem.category {
            // if there is a category animate categoryMenuBar to disappear and update the categoryImage
            animateCategoryMenuBar()
            selectedCategoryImage.image = UIImage(named: category)
            
        }
        
        if let dinnerItemImage = dinnerItem.convertNSDataToUIImage(from: dinnerItem.image) {
            image.image = dinnerItemImage
        }
        nameLabel.text = dinnerItem.name
        if let urlAvailable = dinnerItem.url {
            urlLabel.text = String(describing: urlAvailable)
        }
//        if let ratingAvailable = dinnerItem.rating {
//            ratingLabel.text = String(ratingAvailable)
//        }
        if let notesAvailable = dinnerItem.notes {
            notesLabel.text = notesAvailable
        }
        
    }
    private func updateSaveButtonStatus()-> Void {
    let nameText = nameLabel.text ?? ""
        saveButton.isEnabled = !((nameText == "Name")||(nameText.isEmpty))
    }
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        urlLabel.text = URL.absoluteString
        dinnerItemDetail?.url = URL
        let a :[UIActivity] = []
        return a
    }
    private func selectUrl () {
        if let url = dinnerItemDetail?.url {
            let safariController = SFSafariViewController(url: url)
            safariController.delegate = self
            present(safariController, animated: true, completion: nil)
        } else {
            let defaultUrlString = "https:www.google.com"
            if let defaultUrl = URL(string:defaultUrlString){
                let safariController = SFSafariViewController(url: defaultUrl)
                safariController.delegate = self
                present(safariController, animated: true, completion: nil)
            }
        }
    }
    private func updateImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photolibrary", style: .default, handler: { (action) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(photoLibraryAction)
        }
        present(alertController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image.image = selectedImage
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func addDinnerItem() {
        if newItem {
            // create new dinnerItemObject
            let dinnerItem = DinnerItems(context: coreDataStack.managedContext)
            dinnerItem.createdAt = NSDate()
            dinnerItem.modifiedAt = NSDate()
            let name = nameLabel.text ?? nil
            dinnerItem.name = name
            let notes = notesLabel.text ?? nil
            dinnerItem.notes = notes
            if let image = image {
                dinnerItem.image = dinnerItem.convertUIImageToNSData(from: image.image)
            }
            dinnerItem.category = categorySelected
            
            coreDataStack.saveContext()
        } else {
            // update existing dinnerItemDetail
            if let dinnerItem = dinnerItemDetail {
                dinnerItem.lastUpdate = NSDate()
                let name = nameLabel.text ?? nil
                dinnerItem.name = name
                let notes = notesLabel.text ?? nil
                dinnerItem.notes = notes
                if let image = image {
                    dinnerItem.image = dinnerItem.convertUIImageToNSData(from: image.image)
                }
                dinnerItem.category = categorySelected
                
                coreDataStack.saveContext()
            }
        }

        }
    // update Category selection with animation
    private func updateCategorySelection(with image: UIImage?) {
        self.selectedCategoryImage.tintColor = UIColor.darkGray
        if let image = image {
            self.selectedCategoryImage.image = image
        }
        animateCategoryMenuBar()
    }
    // animate the categoryMenuBar
    private func animateCategoryMenuBar() {
        if self.wrapperViewZeroHeightConstraint == nil {
            self.wrapperViewZeroHeightConstraint = self.wrapperViewCategoryBar.heightAnchor.constraint(equalToConstant: 0)
        }
        
        let shouldShow = !categoryBarEdgeContstraint.isActive
        // Deactivate constraint first to avoid constraint conflict message
        if shouldShow {
            self.wrapperViewZeroHeightConstraint.isActive = false
            self.categoryBarEdgeContstraint.isActive = true
        } else {
           self.categoryBarEdgeContstraint.isActive = false
            self.wrapperViewZeroHeightConstraint.isActive = true
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

extension DinnerItemDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categorySelectionCell", for: indexPath) as! MenuBarCollectionViewCell
        if let image = UIImage(named: categories[indexPath.item]){
            cell.categoryImage.image = image
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categorySelected = categories[indexPath.item]
}
}
