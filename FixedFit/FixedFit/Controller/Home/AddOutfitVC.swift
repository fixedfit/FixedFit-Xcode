//
//  AddOutfitVC.swift
//  FixedFit
//
//  Created by Carlo De Los Reyes on 4/9/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class AddOutfitVC: PhotosVC {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var eventNameTextField: UITextField!

    var outfits: [Outfit] {
        get {
            return UserStuffManager.shared.closet.outfits
        }

        set {
            collectionView.reloadData()
        }
    }
    var eventDate: Date!
    var pickedOutfitInfo: (index: Int, outfit: Outfit)? {
        didSet {
            checkAbiltyToSave()
        }
    }

    let firebaseManager = FirebaseManager.shared


    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        eventNameTextField.addTarget(self, action: #selector(eventNameTextFieldValueChanged), for: .allEditingEvents)
        checkAbiltyToSave()
    }

    @objc private func eventNameTextFieldValueChanged() {
        checkAbiltyToSave()
    }

    private func checkAbiltyToSave() {
        if pickedOutfitInfo != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    @IBAction func touchedSave(_ sender: UIBarButtonItem) {
        let eventName = eventNameTextField.text ?? ""

        firebaseManager.saveEvent(date: eventDate, eventName: eventName, outfit: pickedOutfitInfo!.outfit) { [weak self] (error) in
            if let error = error {
                // Show user an error
            } else {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

}

extension AddOutfitVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outfits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectableOutfitCell", for: indexPath) as! SelectableOutfitCell

        var specificOutfitItems = outfits[indexPath.row].items
        let numberOfStackViews = Int(ceil(Double(outfits[indexPath.row].items.count) / 2))

        cell.verticalStackView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        cell.tag = indexPath.row

        for _ in 0..<numberOfStackViews {
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.distribution = .fillEqually
            horizontalStackView.alignment = .fill
            horizontalStackView.spacing = 2


            var closetItemsToPlaceInRow: [ClosetItem] = []

            for _ in 0..<2 {
                if let closetItem = specificOutfitItems.first {
                    closetItemsToPlaceInRow.append(closetItem)
                    specificOutfitItems.remove(at: 0)
                }
            }

            for closetItem in closetItemsToPlaceInRow {
                let imageView = UIImageView()
                imageView.backgroundColor = .lightGray
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true

                firebaseManager.fetchImage(storageURL: closetItem.storagePath) { (image, error) in
                    if let _ = error {
                        print("Error fetching image")
                    } else if let image = image {
                        if cell.tag == indexPath.row {
                            imageView.image = image
                        }
                    }
                }

                horizontalStackView.addArrangedSubview(imageView)
            }

            cell.verticalStackView.addArrangedSubview(horizontalStackView)
        }

        return cell
    }
}

extension AddOutfitVC {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SelectableOutfitCell
        let outfit = outfits[indexPath.row]

        cell.toggleCheckmark()

        if let pickedOutInfo = pickedOutfitInfo {
            let previousOutfit = pickedOutfitInfo

            pickedOutfitInfo = (indexPath.row, outfit)

            if let previousOutfit = previousOutfit,
                let previouslySelectedCell = collectionView.cellForItem(at: IndexPath(row: previousOutfit.index, section: 0)) as? SelectableOutfitCell {
                previouslySelectedCell.toggleCheckmark()
            }
        } else {
            pickedOutfitInfo = (index: indexPath.row, outfit: outfit)
        }
    }
}
