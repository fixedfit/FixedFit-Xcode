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

    class var addPhotosVC: UIViewController? {
        return UIStoryboard(name: "AddPhotos", bundle: nil).instantiateInitialViewController()
    }

    class var addCategoryVC: UIViewController? {
        return UIStoryboard(name: "AddCategory", bundle: nil).instantiateInitialViewController()
    }

    // Segues
    static let itemsSegue = "itemsSegue"
    static let filtersSegue = "filtersSegue"
}
