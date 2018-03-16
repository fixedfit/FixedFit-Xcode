//
//  ItemsVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/9/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class ItemsVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var closetItems: [ClosetItem] = []

    let firebaseManager = FirebaseManager.shared

    let numberOfColumns = 3
    let edgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        navigationItem.title = "Items"

        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension ItemsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return closetItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        let closetItem = closetItems[indexPath.row]
        let url = closetItem.storagePath

        cell.tag = indexPath.row

        firebaseManager.fetchImage(storageURL: url) { (image, error) in
            if let _ = error {
                print("Error fetching image")
            } else if let image = image {
                if cell.tag == indexPath.row {
                    cell.imageView.image = image
                }
            }
        }

        return cell
    }
}

extension ItemsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableSpace = collectionView.bounds.width - (edgeInsets.left * CGFloat(numberOfColumns + 1))
        let cellWidth = availableSpace / CGFloat(numberOfColumns)

        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return edgeInsets.bottom
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return edgeInsets.bottom
    }
}
