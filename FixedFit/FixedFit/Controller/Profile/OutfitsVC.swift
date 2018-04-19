//
//  OutfitVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/6/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class OutfitsVC: PhotosVC {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noOutfitsLabel: UILabel!

    var outfits: [Outfit] {
        get {
            return UserStuffManager.shared.closet.outfits
        }

        set {
            collectionView.reloadData()
        }
    }

    let firebaseManager = FirebaseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }

    private func setupViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
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
