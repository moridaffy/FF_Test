//
//  ListViewController.swift
//  FF
//
//  Created by Максим Скрябин on 08.06.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import UIKit
import CoreData

import SwiftyJSON
import NVActivityIndicatorView

class ListViewController: UITableViewController, NVActivityIndicatorViewable {
    
    @objc func reloadRepos(_ sender: Any) {
        startAnimating()
        for repo in repoList {
            context.delete(repo)
        }
        repoList.removeAll()
        
        //Запрос 1 - получение списка репозиториев
        let repoURL = URL(string: "https://api.github.com/search/repositories?access_token=\(githubToken)&q=language:swift&sort=stars")!
        URLSession.shared.dataTask(with: repoURL) { (repoData, repoResponse, repoError) in
            if repoData == nil || repoError != nil {
                print("error at request 1")
            } else {
                do {
                    let repoJSON = try JSON(data: repoData!)
                    for i in 0...29 {
                        let entity = NSEntityDescription.entity(forEntityName: "Repo", in: context)!
                        let tempRepo = NSManagedObject(entity: entity, insertInto: context)
                        
                        tempRepo.setValue(repoJSON["items"][i]["name"].string!, forKey: "name")
                        tempRepo.setValue(repoJSON["items"][i]["description"].string!, forKey: "desc")
                        tempRepo.setValue(repoJSON["items"][i]["html_url"].string!, forKey: "url")
                        tempRepo.setValue(repoJSON["items"][i]["stargazers_count"].int!, forKey: "starCount")
                        tempRepo.setValue(repoJSON["items"][i]["forks_count"].int!, forKey: "forkCount")
                        
                        //Запрос 2 - получение кол-ва страниц watcher'ов
                        let watchURL = URL(string: "\(repoJSON["items"][i]["url"].string!)/subscribers?access_token=\(githubToken)&per_page=100")!
                        URLSession.shared.dataTask(with: watchURL) { (watchData, watchResponse, watchError) in
                            if watchError != nil {
                                print("error at request 2")
                            } else {
                                let httpResponse = watchResponse as! HTTPURLResponse
                                let linkHeader: String = httpResponse.allHeaderFields["Link"] as? String ?? "none"
                                let requestsLeft: String = httpResponse.allHeaderFields["X-RateLimit-Remaining"] as! String
                                
                                print("API uses left: \(requestsLeft)")
                                
                                let lastHeader = linkHeader.slice(from: "rel=\"next\", ", to: "; rel=\"last\"") ?? "none"
                                let pageCount = lastHeader.slice(from: "per_page=100&page=", to: ">") ?? "none"
                                
                                if linkHeader == "none" || lastHeader == "none" || pageCount == "none" {
                                    print("no link header received at request 2")
                                } else {
                                    
                                    //Запрос 3 - получение кол-ва watcher'ов на последней странице
                                    let lastPageURL = URL(string: "\(repoJSON["items"][i]["url"].string!)/subscribers?access_token=\(githubToken)&per_page=100&page=\(pageCount)")!
                                    URLSession.shared.dataTask(with: lastPageURL) { (lastPageData, lastPageResponse, lastPageError) in
                                        if lastPageError != nil || lastPageData == nil {
                                            print("error at request 3")
                                        } else {
                                            do {
                                                let lastPageJSON = try JSON(data: lastPageData!)
                                                let lastPageCount = lastPageJSON.count
                                                
                                                let totalCount = 100 * (Int(pageCount)! - 1) + lastPageCount
                                                tempRepo.setValue(totalCount, forKey: "watchCount")
                                            } catch let error as NSError {
                                                print("error while creating last page json")
                                            }
                                        }
                                        
                                    }.resume()
                                    //Запрос 3 - конец
                                }
                            }
                        }.resume()
                        //Запрос 2 - конец
                        
                        repoList.append(tempRepo)
                    }
                    
                    try context.save()
                    DispatchQueue.main.sync {
                        self.tableView.reloadData()
                        self.stopAnimating()
                        self.refresher.endRefreshing()
                    }
                } catch let error as NSError {
                    print("error while creating repo json")
                }
            }
        }.resume()
        //Запрос 1 - конец
        
    }
    
    var sID: Int = 0
    var refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repoRequest = NSFetchRequest<NSManagedObject>(entityName: "Repo")
        do {
            repoList = try context.fetch(repoRequest)
            repoList.sort(by: { ($0.value(forKey: "starCount") as! Int) > ($1.value(forKey: "starCount") as! Int) })
        } catch let error as NSError {
            print("Error while loading information from CoreData.\nError code: \(error.code)")
        }
        
        refresher.addTarget(self, action: #selector(reloadRepos(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresher
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        //self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let destVC = segue.destination as! DetailViewController
            destVC.rID = sID
        }
    }
    
    //Методы UITableViewController
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if repoList.count == 0 {
            return 1
        } else {
            return repoList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if repoList.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell")!

            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "repoCell")!
            let logoImg = cell.viewWithTag(1) as! UIImageView
            let nameLbl = cell.viewWithTag(2) as! UILabel
            let descLbl = cell.viewWithTag(3) as! UILabel
            let starLbl = cell.viewWithTag(4) as! UILabel
            let repo = repoList[indexPath.row]

            //Стиль
            logoImg.layer.cornerRadius = logoImg.frame.width / 2
            logoImg.layer.masksToBounds = true

            //Содержание
            logoImg.image = UIImage(named: "swift_logo")
            nameLbl.text = (repo.value(forKey: "name") as! String)
            descLbl.text = (repo.value(forKey: "desc") as! String)

            let formatter = NumberFormatter()
            formatter.groupingSeparator = " "
            formatter.numberStyle = .decimal
            starLbl.text = "★ \(formatter.string(from: repo.value(forKey: "starCount") as! NSNumber)!)"

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if repoList.count != 0 {
            sID = indexPath.row
            self.performSegue(withIdentifier: "showDetails", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if repoList.count != 0 {
            return UITableViewAutomaticDimension
        } else {
            return self.tableView.frame.height
        }
    }
}
