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
    class var authVC: UIViewController? {
        return UIStoryboard(name: "Authentication", bundle: nil).instantiateInitialViewController()
    }

    class var mainVC: UIViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    }

    class var addVC: UIViewController? {
        return UIStoryboard(name: "Add", bundle: nil).instantiateInitialViewController()
    }

    class var tagVC: UIViewController? {
        return UIStoryboard(name: "Tag", bundle: nil).instantiateInitialViewController()
    }
}
