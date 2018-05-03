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

    private func setupViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        setDoneButton()
    }

    private func setupAllItems() {
        userStuffManager.closet.categorySubcategoryStore.closetCategories.forEach { (category) in
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
        let message = "Would you like this outfit to be public?"
        let publicCompletion = { [weak self] in
            guard let strongSelf = self else { return }
            let message = "Uploading..."
            let informationVC = InformationVC(message: message, image: #imageLiteral(resourceName: "addCategory"), leftButtonData: nil, rightButtonData: nil)

            strongSelf.present(informationVC, animated: true, completion: nil)
            strongSelf.firebaseManager.saveOutfit(outfitItems: strongSelf.pickedOutfitItems, isPublic: true) { [weak self] (uniqueID, error) in
                guard let strongSelf = self else { return }
                let outfit = Outfit(uniqueID: uniqueID!, items: strongSelf.pickedOutfitItems, isPublic: true, userID: "", username: "")
                strongSelf.userStuffManager.closet.outfits.insert(outfit, at: 0)
                informationVC.dismiss(animated: true) { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
        let notPublicCompletion = { [weak self] in
            guard let strongSelf = self else { return }
            let message = "Uploading..."
            let informationVC = InformationVC(message: message, image: #imageLiteral(resourceName: "addCategory"), leftButtonData: nil, rightButtonData: nil)

            strongSelf.present(informationVC, animated: true, completion: nil)
            strongSelf.firebaseManager.saveOutfit(outfitItems: strongSelf.pickedOutfitItems, isPublic: false) { [weak self] (uniqueID, error) in
                guard let strongSelf = self else { return }
                let outfit = Outfit(uniqueID: uniqueID!, items: strongSelf.pickedOutfitItems, isPublic: false, userID: "", username: "")
                strongSelf.userStuffManager.closet.outfits.insert(outfit, at: 0)
                informationVC.dismiss(animated: true) { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
        let leftButtonData = ButtonData(title: "No", color: .red, action: notPublicCompletion)
        let rightButtonData = ButtonData(title: "Yes", color: .fixedFitBlue, action: publicCompletion)
        let informationVC = InformationVC(message: message, image: #imageLiteral(resourceName: "public"), leftButtonData: leftButtonData, rightButtonData: rightButtonData)

        present(informationVC, animated: true, completion: nil)
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

    private func setCellTag(indexPath: IndexPath, cell: UICollectionViewCell) {
        let rowNumberLength = String(indexPath.row).count
        let sectionNumberLength = String(indexPath.section).count

        cell.tag = Int("\(rowNumberLength)\(sectionNumberLength)\(indexPath.row)\(indexPath.section)")!
    }

    private func parse(cellTag: Int) -> IndexPath {
        let cellTagString = String(cellTag)
        let rowNumberLength = Int(String(cellTagString[cellTagString.startIndex]))!
        // let sectionNumberLength = Int(String(cellTagString[cellTagString.index(after: cellTagString.startIndex)]))!
        // get substring after the first two positions
        let thirdIndex = cellTagString.index(cellTagString.startIndex, offsetBy: 2)
        let rowSectionSubstring = cellTagString[thirdIndex..<cellTagString.endIndex]

        var rowNumberString = ""
        var sectionNumberString = ""

        for (index, char) in rowSectionSubstring.enumerated() {
            if index < rowNumberLength {
                rowNumberString.append(char)
            } else {
                sectionNumberString.append(char)
            }
        }

        return IndexPath(row: Int(rowNumberString)!, section: Int(sectionNumberString)!)
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

        setCellTag(indexPath: indexPath, cell: cell)
        cell.imageView.image = nil

        firebaseManager.fetchImage(storageURL: url) { [weak self] (image, error) in
            guard let strongSelf = self else { return }

            if let _ = error {
                print("Error fetching image")
            } else if let image = image {
                let parsedIndexPath = strongSelf.parse(cellTag: cell.tag)

                if parsedIndexPath == indexPath {
                    cell.imageView.image = image
                    self?.allClosetItems[indexPath.section][indexPath.row].image = image
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
