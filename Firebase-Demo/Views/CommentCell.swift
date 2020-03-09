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
    
    public func configureCell(comment: Comment) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        userProfilePic.kf.setImage(with: user.photoURL)
        userNameLabel.text = user.displayName
        commentLabel.text = comment.comment
    }
    
}
