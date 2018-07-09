//
//  Extensions.swift
//  FF
//
//  Created by Максим Скрябин on 08.06.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import UIKit
import Foundation

let githubToken: String = "e1824194bdad8cb6082ba53d9f54e2ebc6950377"

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

extension UIViewController {
    func showAlert(title: String, body: String, btn: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let ok = UIAlertAction(title: btn, style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
