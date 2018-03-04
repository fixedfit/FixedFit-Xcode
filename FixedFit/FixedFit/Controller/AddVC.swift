//
//  AddVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/1/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
import ImagePicker

class AddVC: UIViewController {
    var imagePicker = ImagePickerController()
    var currentTabBarController: UITabBarController?

    let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(imagePicker.view)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension AddVC: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        dismiss(animated: true, completion: nil)
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        currentTabBarController?.selectedIndex = 1
        dismiss(animated: true, completion: nil)

        guard currentTabBarController?.viewControllers?.count ?? 0 > 2 else { return }
        guard let navVC = currentTabBarController?.viewControllers![1] as? UINavigationController else { return }
        guard let closetVC = navVC.topViewController as? ClosetVC else { return }

        closetVC.presentTagVC(images: images)
    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
