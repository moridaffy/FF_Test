//
//  DetailViewController.swift
//  FF
//
//  Created by Максим Скрябин on 08.06.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var counterStack: UIStackView!
    @IBOutlet weak var watchStack: UIStackView!
    @IBOutlet weak var starStack: UIStackView!
    @IBOutlet weak var forkStack: UIStackView!
    @IBOutlet weak var watchCounter: UILabel!
    @IBOutlet weak var starCounter: UILabel!
    @IBOutlet weak var forkCounter: UILabel!
    
    @IBOutlet weak var webBtnOut: UIButton!
    @IBAction func webBtn(_ sender: Any) {
        let url = URL(string: repoList[rID].value(forKey: "url") as! String)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    var rID: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Стиль
        webBtnOut.layer.cornerRadius = 10.0
        webBtnOut.layer.masksToBounds = true
        
        //Содержание
        let repo = repoList[rID]
        navItem.title = (repoList[rID].value(forKey: "name") as! String)
        
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        watchCounter.text = "\(formatter.string(from: repo.value(forKey: "watchCount") as! NSNumber)!)"
        starCounter.text = "\(formatter.string(from: repo.value(forKey: "starCount") as! NSNumber)!)"
        forkCounter.text = "\(formatter.string(from: repo.value(forKey: "forkCount") as! NSNumber)!)"
        
        //Расположение
        let horSpacing = (UIScreen.main.bounds.width - watchStack.frame.width - starStack.frame.width - forkStack.frame.width) / 4
        let verSpacing = ((self.view.frame.height / 2) - webBtnOut.frame.height - counterStack.frame.height) / 3
        
        infoStack.frame.size.width = UIScreen.main.bounds.width - horSpacing * 2
        infoStack.frame.size.height = (self.view.frame.height / 2) - verSpacing * 2
        infoStack.frame.origin.x = horSpacing
        infoStack.frame.origin.y = self.navigationController!.navigationBar.frame.maxY + verSpacing
    }
    
}
