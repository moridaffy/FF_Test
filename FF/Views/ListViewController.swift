//
//  ListViewController.swift
//  FF
//
//  Created by Максим Скрябин on 08.06.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import UIKit

import RealmSwift
import SwiftyJSON
import NVActivityIndicatorView

class ListViewController: UITableViewController, NVActivityIndicatorViewable {
    
    @IBAction func aboutBtn(_ sender: Any) {
        let alert = UIAlertController(title: "О приложении", message: "Приложение является выполненным тестовым заданием для кандидатов на позицию iOS Junior Developer в компании Family Friend.\n\nРазработчик: Максим Скрябин.", preferredStyle: .alert)
        let close = UIAlertAction(title: "Закрыть", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        let web = UIAlertAction(title: "Портфолио", style: .default, handler: { _ in
            let url = URL(string: "http://mskr.name")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        })
        alert.addAction(web)
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func reloadRepos(_ sender: Any) {
        self.tableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    var sID: Int = 0
    var refresher = UIRefreshControl()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realmFetch = realm.objects(Repository.self)
        for i in realmFetch {
            repositoryList.append(i)
        }
        repositoryList.sort(by: { $0.starCount > $1.starCount })
        
        refresher.addTarget(self, action: #selector(reloadRepos(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresher
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let destVC = segue.destination as! DetailViewController
            destVC.rID = sID
        }
    }
    
    //Методы UITableViewController
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if repositoryList.count == 0 {
            return 1
        } else {
            return repositoryList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if repositoryList.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell")!

            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "repoCell")!
            let logoImg = cell.viewWithTag(1) as! UIImageView
            let nameLbl = cell.viewWithTag(2) as! UILabel
            let descLbl = cell.viewWithTag(3) as! UILabel
            let starLbl = cell.viewWithTag(4) as! UILabel
            let repo = repositoryList[indexPath.row]

            //Стиль
            logoImg.layer.cornerRadius = logoImg.frame.width / 2
            logoImg.layer.masksToBounds = true

            //Содержание
            logoImg.image = UIImage(named: "swift_logo")
            nameLbl.text = repo.name
            descLbl.text = repo.desc

            let formatter = NumberFormatter()
            formatter.groupingSeparator = " "
            formatter.numberStyle = .decimal
            starLbl.text = "★ \(formatter.string(from: (repo.starCount as NSNumber))!)"

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if repositoryList.count != 0 {
            sID = indexPath.row
            self.performSegue(withIdentifier: "showDetails", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if repositoryList.count != 0 {
            return UITableViewAutomaticDimension
        } else {
            return self.tableView.frame.height
        }
    }
}
