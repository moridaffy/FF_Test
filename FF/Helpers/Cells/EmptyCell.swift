//
//  EmptyCell.swift
//  FF
//
//  Created by Максим Скрябин on 08.07.2018.
//  Copyright © 2018 mSkr. All rights reserved.
//

import UIKit

class EmptyCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    class func presentEmpty() -> EmptyCell{
        let cell = Bundle.main.loadNibNamed("EmptyCell", owner: self, options: nil)!.first as! EmptyCell
        cell.selectionStyle = .none
        return cell
    }
}
