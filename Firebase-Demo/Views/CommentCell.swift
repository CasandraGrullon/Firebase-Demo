//
//  CommentCell.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/9/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, h:mm a"
        return formatter
    }()
    
    public func configureCell(comment: Comment) {
        userProfilePic.kf.setImage(with: URL(string: comment.commenterPhoto))
        userNameLabel.text = comment.commentedBy
        commentLabel.text = comment.commentText
        let dateString = dateFormatter.string(from: comment.createdDate.dateValue())
        dateLabel.text = dateString
    }
    
}



