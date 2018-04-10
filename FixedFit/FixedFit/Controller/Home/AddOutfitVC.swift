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
        collectionView.dataSource = self
        collectionView.delegate = self
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
