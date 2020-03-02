//
//  CategoryCell.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    
    public func configureCell(for category: Category) {
        categoryNameLabel.text = category.name
        let colorImage = category.image.withTintColor(UIColor.generateRandomColor(), renderingMode: .alwaysOriginal)
        categoryImageView.image = colorImage
    }
}
