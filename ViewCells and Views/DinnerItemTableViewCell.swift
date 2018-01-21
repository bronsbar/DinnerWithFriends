//
//  DinnerItemTableViewCell.swift
//  DinnerWithFriends5.0
//
//  Created by Bart Bronselaer on 20/12/17.
//  Copyright © 2017 Bart Bronselaer. All rights reserved.
//

import UIKit

class DinnerItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var imageContainerView: UIView! {
        didSet {
            imageContainerView.clipsToBounds = true
            imageContainerView.layer.cornerRadius = imageContainerView.bounds.height * 0.2
        }
    }

    
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    
    
    @IBOutlet weak var dinnerItemImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
