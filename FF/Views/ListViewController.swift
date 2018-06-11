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
        let requestURL = URL(string: "https://api.github.com/search/repositories?q=language:swift&sort=stars")!
        startAnimating()
        
        for repo in repoList {
            context.delete(repo)
        }
        repoList.removeAll()
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if error != nil || data == nil {
                print("Error while loading repos URL:\n\(error.debugDescription)")
            } else {
                do {
                    let json = try JSON(data: data!)
                    for i in 0...29 {
                        let entity = NSEntityDescription.entity(forEntityName: "Repo", in: context)!
                        let tempRepo = NSManagedObject(entity: entity, insertInto: context)
                        
                        tempRepo.setValue(json["items"][i]["name"].string!, forKey: "name")
                        tempRepo.setValue(json["items"][i]["description"].string!, forKey: "desc")
                        tempRepo.setValue(json["items"][i]["html_url"].string!, forKey: "url")
                        tempRepo.setValue(json["items"][i]["watchers_count"].int!, forKey: "watchCount")
                        tempRepo.setValue(json["items"][i]["stargazers_count"].int!, forKey: "starCount")
                        tempRepo.setValue(json["items"][i]["forks_count"].int!, forKey: "forkCount")
                        
                        repoList.append(tempRepo)
                    }
                    
                    try context.save()
                    
                    DispatchQueue.main.sync {
                        self.tableView.reloadData()
                        self.stopAnimating()
                        self.refresher.endRefreshing()
                    }
                } catch let error as NSError {
                    print("Error while creating JSON:\n\(error.debugDescription)")
                }
            }
        }.resume()
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
        self.tableView.rowHeight = UITableViewAutomaticDimension
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
}
