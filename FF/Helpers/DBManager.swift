//
//  DBManager.swift
//  FF
//
//  Created by Максим Скрябин on 09.07.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import Foundation

import RealmSwift

class DBManager {
    
    class func readFromDB(completionHandler: (Bool, Error?) -> Void) {
        do {
            var repoList: [Repository] = []
            let realm = try Realm()
            let realmFetch = realm.objects(Repository.self)
            for i in realmFetch {
                repoList.append(i)
            }
            completionHandler(true, nil)
        } catch let error as NSError {
            let err = NSError(domain: "Error while reading data from DB. Error: \(error.debugDescription)", code: 5, userInfo: nil)
            completionHandler(false, err)
        }
    }
    
    class func writoToDB(data: [Repository], completionHandler: @escaping (Bool, Error?) -> Void) {
        var err: NSError?
        DispatchQueue.main.sync {
            do {
                print("🔥 Writing to DB from thread: \(Thread.current)")
                let realm = try Realm()
                try realm.write {
                    realm.deleteAll()
                    for i in data {
                        realm.add(i)
                    }
                }
                print("🔥 Done writing to DB from thread: \(Thread.current)")
            } catch let error as NSError {
                err = NSError(domain: "Error while writing data to DB. Error: \(error.debugDescription)", code: 5, userInfo: nil)
            }
        }
        
        if err == nil {
            completionHandler(true, nil)
        } else {
            completionHandler(false, err)
        }
    }
}
