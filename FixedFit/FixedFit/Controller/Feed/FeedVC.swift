//
//  FeedVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/28/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class FeedVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var outfits: [Outfit] = []

    let firebaseManager = FirebaseManager.shared

    var edgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    var numberOfColumns = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        outfits = UserStuffManager.shared.closet.outfits
    }

    @IBAction func segueToUserFinderVC(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: UIStoryboard.userFinderSegue, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userFinderVC = segue.destination as? UserFinderVC {
            userFinderVC.followBlockType = .follow
            userFinderVC.viewTitle = FirebaseUserFinderTitle.search
            userFinderVC.mode = FirebaseUserFinderMode.search
        }
    }
}

extension FeedVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outfits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedOutfitCell.identifier, for: indexPath) as! FeedOutfitCell
        let outfit = outfits[indexPath.row]

        cell.tag = indexPath.row

        firebaseManager.fetchOutfitImage(uniqueID: outfit.uniqueID) { (image, error) in
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

extension FeedVC: UICollectionViewDelegate {}

extension FeedVC: UICollectionViewDelegateFlowLayout {
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
