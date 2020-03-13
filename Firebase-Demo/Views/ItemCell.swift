//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

protocol ItemCellDelegate: AnyObject {
    func didSelectSellerName(_ itemCell: ItemCell, item: Item)
}

class ItemCell: UITableViewCell {
    
    weak var delegate: ItemCellDelegate?

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap(_:)))
        return gesture
    }()
    
    private var currentItem: Item!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        itemImageView.layer.cornerRadius = 12
        sellerNameLabel.textColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        // user interavtion needs
        sellerNameLabel.isUserInteractionEnabled = true
        sellerNameLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        delegate?.didSelectSellerName(self, item: currentItem)
    }
    
    public func configureCell(for item: Item) {
        currentItem = item
        
        updateUI(imageUrl: item.imageURL, itemName: item.name, sellerName: item.sellerName, date: item.listedDate, price: item.price)
        
//        itemImageView.kf.setImage(with: URL(string: item.imageURL))
//
//        itemNameLabel.text = item.name
//        sellerNameLabel.text = "@\(item.sellerName)"
//        dateLabel.text = item.listedDate.description
//        let price = String(format: "%.2f", item.price)
//        priceLabel.text = "$\(price)"
        
    }
    
    
    public func configureCell(for favorite: Favorite) {
        updateUI(imageUrl: favorite.imageURL, itemName: favorite.itemName, sellerName: favorite.sellerName, date: favorite.favoritedDate.dateValue(), price: favorite.price)
        
    }
    
    private func updateUI(imageUrl: String, itemName: String, sellerName: String, date: Date, price: Double ) {
        
        itemImageView.kf.setImage(with: URL(string: imageUrl))
        
        itemNameLabel.text = itemName
        sellerNameLabel.text = "@\(sellerName)"
        dateLabel.text = date.dateString()
        let price = String(format: "%.2f", price)
        priceLabel.text = "$\(price)"
    }
    
    
}
