//
//  DinnerItem.swift
//  DinnerWithFriends5.0
//
//  Created by Bart Bronselaer on 20/12/17.
//  Copyright © 2017 Bart Bronselaer. All rights reserved.
//

import Foundation
import UIKit
import CloudKit


struct DinnerItem {
    var name : String
    var image : UIImage?
    var url : URL?
    var notes : String?
    var rating : Int?
    
    func convertDataToUIimage (inputdata data: Data) -> UIImage? {
        // nog uit te werken
        return nil
    }
   
    init (from record : CKRecord) {
        let name = record["name"] as! String
        let myImage = record.assetToUIImage()
        self.image = myImage
        self.name = name
        if let urlString = record["url"] as? String, let url = URL(string: urlString) {
            self.url = url
        }
        self.notes = record["notes"] as? String
        self.rating = record["rating"] as? Int
    }
    
}

// extension on CKRecord to convert a property of type CKAsset into a UIImage

extension CKRecord {
    func assetToUIImage () -> UIImage? {
        if let imageInRecord = self["image"] as? CKAsset, let newImage =  UIImage(contentsOfFile: imageInRecord.fileURL.path){
            return newImage
        } else {
            return nil
        }
        
    }
}
