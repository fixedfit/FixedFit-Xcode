//
//  OutfitVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/6/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

enum Outfits {
    case outfits
    case liked
    case favorited
}

class OutfitsVC: PhotosVC {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noOutfitsLabel: UILabel!

    var outfits: [Outfit] = [] {
        didSet {
            collectionView.reloadData()
            checkEmptyState()
        }
    }
    var outfitsType = Outfits.outfits

    let firebaseManager = FirebaseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        checkEmptyState()
    }

    private func checkEmptyState() {
        if outfits.isEmpty {
            noOutfitsLabel.isHidden = false
            var noOutfitsText = ""
            switch outfitsType {
            case .outfits: noOutfitsText = "No outfits to show"
            case .liked: noOutfitsText = "No liked outfits to show"
            case .favorited: noOutfitsText = "No favorited outfits to show"
            }
            noOutfitsLabel.text = noOutfitsText
        } else {
            noOutfitsLabel.isHidden = true
        }
    }
}

extension OutfitsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if outfits.isEmpty {
            // Show no outfits message
            noOutfitsLabel.isHidden = false
        } else {
            noOutfitsLabel.isHidden = true
        }

        return outfits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutfitCell.identifier, for: indexPath) as! OutfitCell
        let outfit = outfits[indexPath.row]

        cell.tag = indexPath.row

        if outfitsType == .liked {
            print(outfit.userID)
            print("Im fetcching it like this bruh!!!")
            firebaseManager.fetchLikedOutfitImage(userUniqueID: outfit.userID, outfitUniqueID: outfit.uniqueID) { (image, error) in
                if let _ = error {
                    print("Error fetching image")
                } else if let image = image {
                    if cell.tag == indexPath.row {
                        cell.imageView.image = image
                    }
                }
            }
        } else {
            firebaseManager.fetchOutfitImage(uniqueID: outfit.uniqueID) { (image, error) in
                if let _ = error {
                    print("Error fetching image")
                } else if let image = image {
                    if cell.tag == indexPath.row {
                        cell.imageView.image = image
                    }
                }
            }
        }

        return cell
    }
}

extension OutfitsVC {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let outfit = outfits[indexPath.row]
        // Segue to next VC
        if let profileVC = self.parent as? ProfileVC {
            profileVC.selectedOutfit = outfit
            profileVC.performSegue(withIdentifier: "showOutfitItems", sender: nil)
        }
    }
}
