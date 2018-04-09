//
//  OutfitCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/6/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class OutfitCell: UICollectionViewCell {
    @IBOutlet weak var verticalStackView: UIStackView!

    static let identifier = "outfitCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        verticalStackView.spacing = 2
        verticalStackView.alignment = .fill
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually

        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
}
