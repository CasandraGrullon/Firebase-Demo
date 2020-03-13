//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/3/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

class ItemCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, h:mm a"
        return formatter
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
       let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap(_:)))
        return gesture
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sellerNameLabel.textColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        sellerNameLabel.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        print("was tapped")
    }
    
    
    public func configureCell(item: Item) {
        updateUI(imageURL: item.imageURL, itemName: item.itemName, sellerName: item.sellerName, dateCreated: item.listedDate.dateValue(), price: item.price)
    }
    public func configureCell(favorite: Favorite) {
        updateUI(imageURL: favorite.imageURL, itemName: favorite.itemName, sellerName: favorite.seller, dateCreated: favorite.favoritedDate.dateValue(), price: favorite.price)
    }
    
    private func updateUI(imageURL: String, itemName: String, sellerName: String, dateCreated: Date, price: Double) {
        itemNameLabel.text = itemName
        sellerNameLabel.text = sellerName
        dateLabel.text = dateCreated.description
        let priceString = String(format: "%.2f", price)
        priceLabel.text = "$\(priceString)"
        itemImage.kf.setImage(with: URL(string: imageURL))
    }
    
}
extension Date {
    func convertDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
}
