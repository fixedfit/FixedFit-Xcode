//
//  ItemCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/13/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        imageView.contentMode = .scaleAspectFill
    }
}
