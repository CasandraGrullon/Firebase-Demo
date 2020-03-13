//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/3/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

protocol ItemCellDelegate: AnyObject {
    func didTapSellerName(_ itemCell: ItemCell, item: Item)
}

class ItemCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
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
    weak var delegate: ItemCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sellerNameLabel.textColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        sellerNameLabel.isUserInteractionEnabled = true
        sellerNameLabel.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        delegate?.didTapSellerName(self, item: currentItem)
    }
    
    
    public func configureCell(item: Item) {
        currentItem = item
        updateUI(imageURL: item.imageURL, itemName: item.itemName, sellerName: item.sellerName, dateCreated: item.listedDate.dateValue(), price: item.price)
    }
    public func configureCell(favorite: Favorite) {
        updateUI(imageURL: favorite.imageURL, itemName: favorite.itemName, sellerName: favorite.seller, dateCreated: favorite.favoritedDate.dateValue(), price: favorite.price)
    }
    
    private func updateUI(imageURL: String, itemName: String, sellerName: String, dateCreated: Date, price: Double) {
        itemNameLabel.text = itemName
        sellerNameLabel.text = "@" + sellerName
        dateLabel.text = dateCreated.dateString()
        let priceString = String(format: "%.2f", price)
        priceLabel.text = "$\(priceString)"
        itemImage.kf.setImage(with: URL(string: imageURL))
    }
    
}

