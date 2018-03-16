//
//  ItemCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/13/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    static let identifier = "photoCell"

    override func awakeFromNib() {
        imageView.contentMode = .scaleAspectFill
    }
}
