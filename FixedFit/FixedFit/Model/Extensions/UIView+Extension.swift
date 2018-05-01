//
//  UIView+Extension.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 2/20/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }

    func fillSuperView() {
        if let superView = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.leftAnchor.constraint(equalTo: superView.leftAnchor),
                self.rightAnchor.constraint(equalTo: superView.rightAnchor),
                self.topAnchor.constraint(equalTo: superView.topAnchor),
                self.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
                ])
        }
    }

    func fadeIn(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }

    func fadeOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0
        }
    }

    var screenshot: UIImage {
        UIGraphicsBeginImageContext(self.bounds.size);
        let context = UIGraphicsGetCurrentContext();
        self.layer.render(in: context!)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return screenShot!
    }
}
