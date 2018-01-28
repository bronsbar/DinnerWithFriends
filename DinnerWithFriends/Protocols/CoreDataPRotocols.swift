//
//  CoreDataPRotocols.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 28/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import Foundation

protocol CloudKitRecordIDObject {
    var recordID: NSData? {get set}
}

protocol CloudKitManagedObject: CloudKitRecordIDObject {
    var lastUpdated : NSDate? {get set}
    var recordName :String? {get set}
}
