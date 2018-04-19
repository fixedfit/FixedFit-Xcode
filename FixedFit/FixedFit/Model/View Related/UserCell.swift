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

    static let identifier = "UserCell"

    func configure(_ user: UserInfo) {
        username.text = user.username
        fullName.text = user.firstName + " " + user.lastName

        if user.photo == nil {
            userPhotoImageView.image = #imageLiteral(resourceName: "defaultProfile")
        }
    }
}
