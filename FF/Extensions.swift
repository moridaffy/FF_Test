//
//  Extensions.swift
//  FF
//
//  Created by Максим Скрябин on 08.06.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import UIKit
import CoreData

var repoList: [NSManagedObject] = []

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext
