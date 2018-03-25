//
//  UIImage+Extension.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/9/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resized(withPercencategorye percencategorye: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percencategorye, height: size.height * percencategorye)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
