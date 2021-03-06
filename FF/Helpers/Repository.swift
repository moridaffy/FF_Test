//
//  Repository.swift
//  FF
//
//  Created by Максим Скрябин on 06.07.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import Foundation
import RealmSwift

class Repository: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var api_url: String = ""
    @objc dynamic var watchCount: Int = 0
    @objc dynamic var starCount: Int = 0
    @objc dynamic var forkCount: Int = 0
}
