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
    let userStuffManager = UserStuffManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Items"
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        let favoriteImage: UIImage!

        favoriteImage = outfit.isFavorited ? #imageLiteral(resourceName: "filledstar") : #imageLiteral(resourceName: "unfilledstar")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: favoriteImage, style: .plain, target: self, action: #selector(tappedFavorite))
    }

    override func viewDidLayoutSubviews() {
        setupViews()
    }

    private func setupViews() {
        let scrollViewSize = CGSize(width: CGFloat(outfit.items.count) * view.bounds.width, height: scrollView.bounds.height)

        scrollView.contentSize = scrollViewSize
        scrollView.isPagingEnabled = true

        for (index,outfitItem) in outfit.items.enumerated() {
            let imageViewHeight: CGFloat = scrollView.bounds.height
            let padding = (scrollView.bounds.height - imageViewHeight) / 2
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

    @objc private func tappedFavorite() {
        outfit.isFavorited = !outfit.isFavorited

        if outfit.isFavorited {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "filledstar"), style: .plain, target: self, action: #selector(tappedFavorite))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "unfilledstar"), style: .plain, target: self, action: #selector(tappedFavorite))
        }

        firebaseManager.updateOutfitFavorite(outfitUID: outfit.uniqueID, favorite: outfit.isFavorited) { _ in }
        userStuffManager.closet.updateFavorite(outfitUID: outfit.uniqueID, favorite: outfit.isFavorited)
    }
}
