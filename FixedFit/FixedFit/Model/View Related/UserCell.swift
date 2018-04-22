//
//  UserTableViewCell.swift
//  FixedFit
//
//  Created by Alexander Cheung on 4/17/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
    static let identifier = "UserCell"

    var following = false

    func configure(_ user: UserInfo) {
        following = false

        username.text = user.username
        fullName.text = user.firstName + " " + user.lastName

        if user.photo == nil {
            userPhotoImageView.image = #imageLiteral(resourceName: "defaultProfile")
        }
    }

    func toggleFollowing() {
        following = !following

        if following {
            followButton.setTitle("Unfollow", for: .normal)
        } else {
            followButton.setTitle("Follow", for: .normal)
        }
    }
}
