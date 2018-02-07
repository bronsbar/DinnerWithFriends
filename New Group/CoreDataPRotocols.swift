//
//  CoreDataPRotocols.swift
//  DinnerWithFriends
//
//  Created by Bart Bronselaer on 28/01/18.
//  Copyright © 2018 Bart Bronselaer. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitRecordIDObject {
    var recordID: NSData? {get set}
}

protocol CloudKitManagedObject: CloudKitRecordIDObject {
    var lastUpdated : NSDate? {get set}
    var recordName :String? {get set}
    var recordType : String {get}
//    func managedObjectToRecord(record: CKRecord?) -> CKRecord
    func updateWithRecord(record: CKRecord)
}
// MARK: -Storing MetaData for Record

extension CloudKitManagedObject {
    func obtainMetaDataFromRecord(record: CKRecord) -> Data {
        let data = NSMutableData()
        let coder = NSKeyedArchiver.init(forWritingWith: data)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        return data as Data
    }
    
    func obtainMetaDataFromData(data: Data)->CKRecord? {
        let coder = NSKeyedUnarchiver(forReadingWith: data)
        coder.requiresSecureCoding = true
        let record = CKRecord(coder: coder)
        coder.finishDecoding()
        return record
        
    }
    
}
