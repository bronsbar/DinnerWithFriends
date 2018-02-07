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

extension CloudKitRecordIDObject {
    // unarchive the core data recordID, if it exists into a ckRecordID
    func cloudKitRecordID() -> CKRecordID? {
        guard let recordID = recordID else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: recordID as Data) as? CKRecordID
    }
}

protocol CloudKitManagedObject: CloudKitRecordIDObject {
    var modifiedAt : NSDate? {get set}
    var recordName :String? {get set}
    var recordType : String {get}
//    func managedObjectToRecord(record: CKRecord?) -> CKRecord
    func updateWithRecord(record: CKRecord)
}


extension CloudKitManagedObject {
    // create a CKRecord from recordType, recordName and recordZoneID
    func cloudKitRecord(record: CKRecord?) -> CKRecord {
        if let record = record {
            return record
        }
        var recordZoneID: CKRecordZoneID
        guard let cloudKitZone = CloudKitZone(recordType: recordType) else {
            fatalError("Attempted to create a CKRecord with an unknown zone")
        }
        recordZoneID = cloudKitZone.recordZoneID()
        
        let uuid = NSUUID()
        let recordName = recordType + "." + uuid.uuidString
        let recordID = CKRecordID(recordName: recordName, zoneID: recordZoneID)
        return CKRecord(recordType: recordType, recordID: recordID)
    }
    
    // MARK: -Storing MetaData for Record
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

protocol RootManagedObject {
    var name: String? {get set}
    var createdAt : NSDate? {get set}
    var modifiedAt : NSDate? {get set}
}
