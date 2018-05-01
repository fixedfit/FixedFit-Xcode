//
//  OutfitCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/6/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class OutfitCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    static let identifier = "outfitCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderWidth = 5
        layer.borderColor = UIColor.black.cgColor
    }
}
