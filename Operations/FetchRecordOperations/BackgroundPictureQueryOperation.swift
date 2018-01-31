//
//  BackgroundPictureQueryOperation.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 31/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import UIKit
import CloudKit

class BackgroundPictureQueryOperation: CKQueryOperation {
    override init() {
        super.init()
    }
    override func main() {
        print("BackgroundPictureQueryOperation.main")
        setBlocks()
        super.main()
    }
    func setBlocks() {
    
    }
}
