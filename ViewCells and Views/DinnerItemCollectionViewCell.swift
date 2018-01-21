//
//  DinnerItemCollectionViewCell.swift
//  DinnerWithFriends5.0
//
//  Created by Bart Bronselaer on 9/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit

class DinnerItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView! {
        didSet {
            image.clipsToBounds = true
            image.layer.cornerRadius = image.bounds.height * 0.2
        }
    }
    
    
    @IBOutlet weak var label: UILabel!
    
}
