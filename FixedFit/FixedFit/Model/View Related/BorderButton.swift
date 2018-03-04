//
//  BorderButton.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class BorderButton: UIButton {
    override func awakeFromNib() {
        layer.cornerRadius = 3
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
}
