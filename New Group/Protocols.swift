//
//  Protocols.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 11/02/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import Foundation
import UIKit


protocol DinnerItemDetailEntryDelegate {
    func didFinish (viewcontroller : DinnerItemDetailViewController, didSave: Bool)
}

protocol ImageFile {
    func saveImageToDisk(image: UIImage, imageName:String) -> URL?
    func retrieveImageFromDisk(withUrl :URL) -> UIImage?
    func deleteImageFile( withUrl: URL?) -> Void
}

extension ImageFile {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
