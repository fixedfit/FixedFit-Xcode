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
    @IBOutlet weak var doneButton: UIBarButtonItem!

    var pickedOutfitItems: [ClosetItem] = [] {
        didSet {
            setDoneButton()
        }
    }
    var allClosetItems: [[ClosetItem]] = []

    let firebaseManager = FirebaseManager.shared
    var userStuffManager = UserStuffManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupAllItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }

    private func setupViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        setDoneButton()
    }

    private func setupAllItems() {
        userStuffManager.closet.categorySubcategoryStore.allCategories.forEach { (category) in
            let categoryItems = userStuffManager.closet.closetItems(matching: category)

            allClosetItems.append(categoryItems)
        }
        collectionView.reloadData()
    }

    private func setDoneButton() {
        navigationItem.rightBarButtonItem?.isEnabled = !pickedOutfitItems.isEmpty
    }

    @IBAction func touchedCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func touchedDone(_ sender: UIBarButtonItem) {
        let message = "Uploading..."
        let informationVC = InformationVC(message: message, image: #imageLiteral(resourceName: "addCategory"), leftButtonData: nil, rightButtonData: nil)

        present(informationVC, animated: true, completion: nil)
        firebaseManager.saveOutfit(outfitItems: pickedOutfitItems) { [weak self] (uniqueID, error) in
            guard let strongSelf = self else { return }
            let outfit = Outfit(uniqueID: uniqueID!, items: strongSelf.pickedOutfitItems)
            strongSelf.userStuffManager.closet.outfits.insert(outfit, at: 0)
            informationVC.dismiss(animated: true) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func addToPickedOutfitItems(closetItem: ClosetItem) {
        if let index = pickedOutfitItems.index(where: { $0.uniqueID == closetItem.uniqueID }) {
            pickedOutfitItems.remove(at: index)
        }

        pickedOutfitItems.append(closetItem)
    }

    private func removeFromPickedOutfitItems(closetItem: ClosetItem) {
        if let index = pickedOutfitItems.index(where: { $0.uniqueID == closetItem.uniqueID }) {
            pickedOutfitItems.remove(at: index)
        }
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
        let closetItem = allClosetItems[indexPath.section][indexPath.row]

        cell.toggleCheckmark()

        if cell.isPicked {
            addToPickedOutfitItems(closetItem: closetItem)
        } else {
            removeFromPickedOutfitItems(closetItem: closetItem)
        }
    }
}
