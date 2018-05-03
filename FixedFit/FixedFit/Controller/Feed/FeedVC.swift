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

    var outfits: [Outfit] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared

    var edgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    var numberOfColumns = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchFeed()
    }

    private func fetchFeed() {
        firebaseManager.fetchFeed(following: userStuffManager.userInfo.following) { (outfits, error) in
            if let error = error {

            } else if let outfits = outfits {
                self.outfits = outfits
            }
        }
    }

    @IBAction func segueToUserFinderVC(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: UIStoryboard.userFinderSegue, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userFinderVC = segue.destination as? UserFinderVC {
            userFinderVC.followBlockType = .follow
            userFinderVC.viewTitle = FirebaseUserFinderTitle.search
            userFinderVC.mode = FirebaseUserFinderMode.search
        } else if let outfitItemsVC = segue.destination as? OutfitItemsVC,
            let outfit = sender as? Outfit {
            outfitItemsVC.outfit =  outfit
        }
    }

    @objc private func changeLikeStatus(_ sender: UITapGestureRecognizer) {
        guard let feedOutfitCell = sender.view?.superview?.superview?.superview?.superview as? FeedOutfitCell else { return }

        let feedOutfitCellTag = feedOutfitCell.tag
        let outfit = outfits[feedOutfitCellTag]

        if userStuffManager.userInfo.likes.contains(where: { $0.uniqueID == outfit.uniqueID }) {
            if let index = userStuffManager.userInfo.likes.index(where: {$0.uniqueID == outfit.uniqueID}) {
                let indexPath = IndexPath(row: feedOutfitCellTag, section: 0)
                userStuffManager.userInfo.likes.remove(at: index)
                collectionView.performBatchUpdates({
                    if let feedOutfitCell = collectionView.cellForItem(at: indexPath) as? FeedOutfitCell {
                        feedOutfitCell.likeImageView.image = UIImage(named: "unfilledlike")
                    }
                }, completion: nil)
            }
            
            firebaseManager.unfavorite(outfitUID: outfit.uniqueID) { (error) in
                if error != nil {

                }
            }
        } else {
            let indexPath = IndexPath(row: feedOutfitCellTag, section: 0)
            
            collectionView.performBatchUpdates({
                if let feedOutfitCell = collectionView.cellForItem(at: indexPath) as? FeedOutfitCell {
                    feedOutfitCell.likeImageView.image = UIImage(named: "filledlike")
                }
            }, completion: nil)
            userStuffManager.userInfo.likes.append(outfit)
            firebaseManager.favorite(outfit: outfit) { (error) in
                if error != nil {

                }
            }
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
        cell.usernameLabel.text = outfit.username
        cell.likeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeLikeStatus(_:))))

        if userStuffManager.userInfo.likes.contains(where: {$0.uniqueID == outfit.uniqueID}) {
            cell.likeImageView.image = #imageLiteral(resourceName: "filledlike")
        } else {
            cell.likeImageView.image = #imageLiteral(resourceName: "unfilledlike")
        }


        firebaseManager.fetchFeedOutfitImage(userID: outfit.userID, outfitUniqueID: outfit.uniqueID) { (image, error) in
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

extension FeedVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let outfit = outfits[indexPath.row]
        performSegue(withIdentifier: "showOutfitItems", sender: outfit)
    }
}

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
