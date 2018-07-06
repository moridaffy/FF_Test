//
//  APIManager.swift
//  FF
//
//  Created by Максим Скрябин on 06.07.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import Foundation
import SwiftyJSON

class APIManager {
    private func loadRepos(token: String, completionHandler: @escaping (Bool, Data?, Error?) -> Void) {
        let url = URL(string: "https://api.github.com/search/repositories?access_token=\(token)&q=language:swift&sort=stars")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if data == nil || error != nil {
                if data == nil {
                    let err = (NSError(domain: "No data received", code: 0, userInfo: nil) as Error)
                    completionHandler(false, nil, err)
                } else {
                    let err = (NSError(domain: "Error received: \(error.debugDescription)", code: 1, userInfo: nil))
                    completionHandler(false, data, err)
                }
            } else {
                completionHandler(true, data, nil)
            }
        }
    }
}
