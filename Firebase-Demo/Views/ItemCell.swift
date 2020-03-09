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
    
    
    public func configureCell(item: Item) {
        itemNameLabel.text = item.itemName
        sellerNameLabel.text = item.sellerName
        dateLabel.text = item.listedDate.convertDate()
        let price = String(format: "%.2f", item.price)
        priceLabel.text = "$\(price)"
        itemImage.kf.setImage(with: URL(string: item.imageURL))
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
