//
//  OneOutfitVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/9/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class OutfitItemsVC: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    var outfit: Outfit!

    let firebaseManager = FirebaseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        setupViews()
    }

    private func setupViews() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        let scrollViewSize = CGSize(width: CGFloat(outfit.items.count) * view.bounds.width, height: scrollView.bounds.height)

        scrollView.contentSize = scrollViewSize
        scrollView.isPagingEnabled = true

        for (index,outfitItem) in outfit.items.enumerated() {
            let imageViewHeight: CGFloat = scrollView.bounds.height
            let padding = (scrollView.bounds.height - imageViewHeight) / 2
            print("Scroll view height", scrollView.bounds.height)
            print("Image ViewHeight", imageViewHeight)
            print("Padding", padding)
            let imageViewRect = CGRect(x: CGFloat(index) * scrollView.bounds.width, y: padding, width: scrollView.bounds.width, height: imageViewHeight)
            let imageView = UIImageView(frame: imageViewRect)
            imageView.contentMode = .scaleAspectFit

            scrollView.addSubview(imageView)
            firebaseManager.fetchImage(storageURL: outfitItem.storagePath) { (image, error) in
                if let _ = error {
                    // Show the user something
                } else {
                    imageView.image = image
                }
            }
        }
    }
}
