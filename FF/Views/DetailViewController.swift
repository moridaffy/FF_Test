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
        let url = URL(string: repo.url)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    var repo: Repository = Repository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Стиль
        webBtnOut.layer.cornerRadius = 10.0
        webBtnOut.layer.masksToBounds = true
        
        //Содержание
        navItem.title = repo.name
        
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        watchCounter.text = "\(formatter.string(from: repo.watchCount as NSNumber) ?? "error")"
        starCounter.text = "\(formatter.string(from: repo.starCount as NSNumber) ?? "error")"
        forkCounter.text = "\(formatter.string(from: repo.forkCount as NSNumber) ?? "error")"
    }
    
}
