//
//  Bundle+Extension.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/16/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

extension Bundle {
    static let statsOrderingView = "StatsOrderingView"

    func loadNibNamed(_ name: String) -> UIView? {
        guard let nibView = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? UIView  else { return nil }

        return nibView
    }
}
