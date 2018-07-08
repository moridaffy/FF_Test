//
//  RepositoryCell.swift
//  FF
//
//  Created by Максим Скрябин on 08.07.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import UIKit

class RepositoryCell: UITableViewCell {
    @IBOutlet weak var swiftImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var starLbl: UILabel!
    
    class func presentRepo(repo: Repository) -> RepositoryCell {
        let cell = Bundle.main.loadNibNamed("RepositoryCell", owner: self, options: nil)!.first as! RepositoryCell
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
}
