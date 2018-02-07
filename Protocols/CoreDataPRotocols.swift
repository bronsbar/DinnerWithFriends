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
    var recordID: Data? {get set}
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
    
    func cloudKitRecord(record: CKRecord?) -> CKRecord {
        
        if let record = record {
            return record
        }
        
        var recordZoneID: CKRecordZoneID
        
        
        return CKRecord(recordType: <#T##String#>, recordID: <#T##CKRecordID#>)
    }
    
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
// MARK: - Unarchive the CKRecordID if it exist in Core Data
extension CloudKitRecordIDObject {
    func cloudKitRecordID() -> CKRecordID? {
        guard let recordID = recordID else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: recordID) as? CKRecordID
    }
}
