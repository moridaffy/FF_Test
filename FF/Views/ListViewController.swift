//
//  ListViewController.swift
//  FF
//
//  Created by Максим Скрябин on 08.06.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import UIKit

import RealmSwift

class ListViewController: UITableViewController {
    
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
        APIManager.loadRepos(count: 30, token: githubToken) { (status, error) in
            DispatchQueue.main.async {
                if !status {
                    self.showAlert(title: "Ошибка!", body: "Произошла ошибка при загрузке данных.\n\nОшибка: \(error.debugDescription)", btn: "Ок")
                }
                
                self.refresher.endRefreshing()
            }
        }
    }
    
    var refresher = UIRefreshControl()
    var repoList: Results<Repository>!
    
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        repoList = realm.objects(Repository.self).sorted(byKeyPath: "starCount", ascending: false)
        
        notificationToken = repoList.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .error(let error):
                fatalError("\(error)")
            default:
                self?.tableView.reloadData()
            }
        }
        
        refresher.addTarget(self, action: #selector(reloadRepos(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresher
        self.tableView.register(UINib(nibName: "RepositoryCell", bundle: Bundle.main), forCellReuseIdentifier: "repositoryCell")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    //Методы UITableViewController
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if repoList.count == 0 {
            return 100
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if repoList.count == 0 {
            let headerLbl = UILabel()
            headerLbl.text = "Потяните экран вниз, чтобы загрузить список репозиториев."
            headerLbl.numberOfLines = 0
            headerLbl.textAlignment = .center
            headerLbl.font = UIFont(name: "HelveticaNeue", size: 16)
            return headerLbl
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repositoryCell") as! RepositoryCell
        let repo = repoList[indexPath.row]
        
        cell.swiftImage.layer.cornerRadius = cell.swiftImage.frame.width / 2
        cell.swiftImage.layer.masksToBounds = true
        cell.swiftImage.image = UIImage(named: "swift_logo")
        cell.nameLbl.text = repo.name
        cell.descLbl.text = repo.desc
        
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        cell.starLbl.text = "★ \(formatter.string(from: (repo.starCount as NSNumber))!)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if repoList.count != 0 {
            let sb = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let destVC = sb.instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
            destVC.repo = repoList[indexPath.row]
            self.navigationController?.pushViewController(destVC, animated: true)
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
