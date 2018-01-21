//
//  MenuBarCollectionViewCell.swift
//  DinnerWithFriends5.0
//
//  Created by Bart Bronselaer on 13/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit

class MenuBarCollectionViewCell: UICollectionViewCell {
   @IBOutlet weak var menuBarImage : UIImageView!
    
    @IBOutlet weak var categoryImage: UIImageView! {
        didSet {
            categoryImage.tintColor = UIColor.white
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if let menuBarImage = menuBarImage {
                menuBarImage.tintColor = isHighlighted ? UIColor.darkGray : UIColor.white
            }
            if let categoryImage = categoryImage {
                categoryImage.tintColor = isHighlighted ? UIColor.darkGray : UIColor.white
            }
            
            
           
        }
    }
    override var isSelected: Bool {
        didSet {
            if let menuBarImage = menuBarImage {
                 menuBarImage.tintColor = isSelected ? UIColor.darkGray: UIColor.white
            }
            if let categoryImage = categoryImage {
                categoryImage.tintColor = isSelected ? UIColor.darkGray: UIColor.white
            }
           
           
        }
    }
    
    
}
