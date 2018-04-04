//
//  CreateOutfitVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/3/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class CreateOutfitVC: PhotosVC {
    @IBOutlet weak var collectionView: UICollectionView!

    var pickedOutfitPhotos: Set<UIImage> = Set()
    var allClosetItems: [[ClosetItem]] = []

    let firebaseManager = FirebaseManager.shared
    var userStuffManager = UserStuffManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupAllItems()
    }

    private func setupViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupAllItems() {
        userStuffManager.closet.categorySubcategoryStore.allCategories.forEach { (category) in
            let categoryItems = userStuffManager.closet.closetItems(matching: category)

            allClosetItems.append(categoryItems)
        }
        collectionView.reloadData()
    }

    @IBAction func touchedDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateOutfitVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionTitleCell.identifier, for: indexPath) as! SectionTitleCell
        let sectionTitle = allClosetItems[indexPath.section][0].categorySubcategory.category ?? ""

        sectionTitleCell.titleLabel.text = sectionTitle

        return sectionTitleCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allClosetItems.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allClosetItems[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        let url = allClosetItems[indexPath.section][indexPath.row].storagePath

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

extension CreateOutfitVC {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell

        cell.toggleCheckmark()

        if cell.isPicked {
            pickedOutfitPhotos.insert(cell.imageView.image!)
        } else {
            pickedOutfitPhotos.remove(cell.imageView.image!)
        }
    }
}
