//
//  UserTableViewCell.swift
//  FixedFit
//
//  Created by Alexander Cheung on 4/17/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

enum FollowBlockType {
    case follow
    case block
}

class UserCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    static let identifier = "UserCell"

    var following = false
    var blocked = false
    var cellType: FollowBlockType = .follow

    func configure(_ user: UserInfo, followingOrBlocked: Bool) {
        switch cellType {
        case .follow: following = followingOrBlocked
        case .block: blocked = followingOrBlocked
        }

        setupButton()
        setupCell(user)
    }

    func setupCell(_ user: UserInfo) {
        username.text = user.username
        fullName.text = user.firstName + " " + user.lastName

        if user.photo == nil {
            userPhotoImageView.image = #imageLiteral(resourceName: "defaultProfile")
        }
    }

    private func setupButton() {
        switch cellType {
        case .follow:
            if following {
                button.setTitle("Unfollow", for: .normal)
            } else {
                button.setTitle("Follow", for: .normal)
            }
        case .block:
            if blocked {
                button.setTitle("Unblock", for: .normal)
            } else {
                button.setTitle("Block", for: .normal)
            }
        }
    }

    func toggle() {
        switch cellType {
        case .follow: following = !following
        case .block: blocked = !blocked
        }

        setupButton()
    }
}
