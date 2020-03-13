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

    
    public func configureCell(comment: Comment) {
        userProfilePic.kf.setImage(with: URL(string: comment.commenterPhoto))
        userNameLabel.text = comment.commentedBy
        commentLabel.text = comment.commentText
        let dateString = comment.createdDate.dateValue().dateString()
        dateLabel.text = dateString
    }
    
}



