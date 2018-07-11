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
    //Загрузка JSON'a с репозиториями
    private class func loadData(token: String, completionHandler: @escaping (Bool, Data?, Error?) -> Void) {
        let url = URL(string: "https://api.github.com/search/repositories?access_token=\(token)&q=language:swift&sort=stars")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if data == nil || error != nil {
                if data == nil {
                    let err = NSError(domain: "No data received", code: 1, userInfo: nil)
                    completionHandler(false, nil, err)
                } else {
                    let err = NSError(domain: "Error received: \(error.debugDescription)", code: 1, userInfo: nil)
                    completionHandler(false, data, err)
                }
            } else {
                completionHandler(true, data, nil)
            }
        }.resume()
    }
    
    //Парс информации из полученного JSON'a
    private class func parseRepos(data: Data, count: Int, completionHandler: (Bool, [Repository]?, Error?) -> Void) {
        do {
            let repoJSON = try JSON(data: data)
            var tempArr: [Repository] = []
            
            for i in 0...count-1 {
                let tempRepo = Repository()
                tempRepo.name = repoJSON["items"][i]["name"].string!
                tempRepo.desc = repoJSON["items"][i]["description"].string!
                tempRepo.url = repoJSON["items"][i]["html_url"].string!
                tempRepo.api_url = repoJSON["items"][i]["url"].string!
                tempRepo.starCount = repoJSON["items"][i]["stargazers_count"].int!
                tempRepo.forkCount = repoJSON["items"][i]["forks_count"].int!
                tempRepo.watchCount = 0
                tempArr.append(tempRepo)
            }
            completionHandler(true, tempArr, nil)
        } catch let error as NSError {
            let err = NSError(domain: "Error received: \(error.debugDescription)", code: 2, userInfo: nil)
            completionHandler(false, nil, err)
        }
    }
    
    //Получение кол-ва watcher'ов
    private class func loadWatchers(token: String, repos: [Repository], completionHandler: @escaping (Bool, [Repository]?, Error?) -> Void) {
        for i in 0...repos.count-1{
            let pagesURL = URL(string: "\(repos[i].api_url)/subscribers?access_token=\(token)&per_page=100")!
            URLSession.shared.dataTask(with: pagesURL) { (data, response, error) in
                if data == nil || error != nil {
                    if data == nil {
                        let err = NSError(domain: "No data received", code: 3, userInfo: nil)
                        completionHandler(false, nil, err)
                    } else {
                        let err = NSError(domain: "Error received: \(error.debugDescription)", code: 3, userInfo: nil)
                        completionHandler(false, nil, err)
                    }
                } else {
                    let httpResponse = response as! HTTPURLResponse
                    let linkHeader: String = httpResponse.allHeaderFields["Link"] as? String ?? "none"
                    let requestsLeft: String = httpResponse.allHeaderFields["X-RateLimit-Remaining"] as? String ?? "none"
                    print("API uses left: \(requestsLeft)")
                    
                    let lastHeader = linkHeader.slice(from: "rel=\"next\", ", to: "; rel=\"last\"") ?? "none"
                    let pageCount = lastHeader.slice(from: "per_page=100&page=", to: ">") ?? "none"
                    if linkHeader == "none" || lastHeader == "none" || pageCount == "none" {
                        if linkHeader == "none" {
                            let err = NSError(domain: "No header received", code: 3, userInfo: nil)
                            completionHandler(false, nil, err)
                        } else {
                            let err = NSError(domain: "No last page's index found", code: 3, userInfo: nil)
                            completionHandler(false, nil, err)
                        }
                    } else {
                        let lastPageURL = URL(string: "\(repos[i].api_url)/subscribers?access_token=\(token)&per_page=100&page=\(pageCount)")!
                        URLSession.shared.dataTask(with: lastPageURL) { (data, response, error) in
                            if data == nil || error != nil {
                                if data == nil {
                                    let err = NSError(domain: "No data received", code: 4, userInfo: nil)
                                    completionHandler(false, nil, err)
                                } else {
                                    let err = NSError(domain: "Error received: \(error.debugDescription)", code: 4, userInfo: nil)
                                    completionHandler(false, nil, err)
                                }
                            } else {
                                do {
                                    let lastPageJSON = try JSON(data: data!)
                                    let lastPageCount = lastPageJSON.count
                                    repos[i].watchCount = 100 * (Int(pageCount)! - 1) + lastPageCount
                                    
                                    if i == repos.count-1 {
                                        completionHandler(true, repos, nil)
                                    }
                                } catch let error as NSError {
                                    let err = NSError(domain: "Error received: \(error.debugDescription)", code: 4, userInfo: nil)
                                    completionHandler(false, nil, err)
                                }
                            }
                        }.resume()
                    }
                }
            }.resume()
        }
    }
    
    //Загрузка и обработка всей необходимой информации
    class func loadRepos(count: Int, token: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        print("🔥 Loading repos from GitHub API")
        loadData(token: token) { (status_loadData, data_loadData, error_loadData) in
            if !status_loadData {
                //Ошибка при загрузке JSON'a
                completionHandler(false, error_loadData)
            } else {
                //JSON загружен успешно
                self.parseRepos(data: data_loadData!, count: count) { (status_parse, data_parse, error_parse) in
                    if !status_parse {
                        //Ошибка при извлечении информации из JSON'a
                        completionHandler(false, error_parse)
                    } else {
                        //Извлечение информации из JSON'a прошло успешно
                        self.loadWatchers(token: token, repos: data_parse!) { (status_loadWatchers, data_loadWatchers, error_loadWatchers) in
                            if !status_loadWatchers {
                                //Ошибка при загрузке кол-ва Watcher'ов
                                completionHandler(false, error_loadWatchers)
                            } else {
                                //Кол-во Watcher'ов загружено успешно
                                DBManager.writoToDB(data: data_loadWatchers!) { (success_write, error_write) in
                                    if success_write {
                                        completionHandler(true, nil)
                                    } else {
                                        completionHandler(false, error_write)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
