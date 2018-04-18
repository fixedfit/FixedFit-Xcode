//
//  UserTableViewCell.swift
//  FixedFit
//
//  Created by Alexander Cheung on 4/17/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var fullName: UILabel!

    func configure(_ user: UserStuffManager) {
        userName.text = user.username
        fullName.text = user.firstName + " " + user.lastName
        userAvatarImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        if (user.profileImageURL == "") {
            userAvatarImageView.image = #imageLiteral(resourceName: "profile")
        }
        else {
            //userAvatarImageView
        }
        
        /*
         if (user.isFollowing) {
         //Display Unfollow Button
         }
         else {
         //Display Follow Button
         }
         */
    }
}
