//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

class ItemCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    public func configureCell(item: Item) {
        
        // set up image
        
        itemImageView.kf.setImage(with: URL(string: item.imageURL))
        
        itemNameLabel.text = item.name
        sellerNameLabel.text = "@\(item.sellerName)"
        dateLabel.text = item.listedDate.description
        let price = String(format: "%.2f", item.price)
        priceLabel.text = "$\(price)"
        
    }
    
}
