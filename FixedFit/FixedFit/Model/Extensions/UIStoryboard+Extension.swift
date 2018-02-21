//
//  UIStoryboard+Extension.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 2/20/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    // Specific VC's from storyboards
    static let authVC = UIStoryboard(name: "Authentication", bundle: nil).instantiateInitialViewController()
    static let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
}
