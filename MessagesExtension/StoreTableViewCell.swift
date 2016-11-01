//
//  StoreTableViewCell.swift
//  pop
//
//  Created by Sam Kirkiles on 10/27/16.
//  Copyright © 2016 Sam Kirkiles. All rights reserved.
//

import UIKit

class StoreTableViewCell: UITableViewCell {

    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var purchaseTitleLabel: UILabel!
    @IBOutlet weak var purchaseImageView: UIImageView!
    
    @IBOutlet weak var purchasedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
