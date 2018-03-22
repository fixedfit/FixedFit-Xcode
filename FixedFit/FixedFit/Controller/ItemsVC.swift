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

    var category: String!
    var closetItems: [ClosetItem] = []
    var filteredClosetItems: [ClosetItem] = [] {
        didSet {
            if filteredClosetItems.isEmpty {
                presentEmptyState()
            } else {
                hideEmptyState()
            }
        }
    }
    var subcategories: [String] = [] {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = subcategories.count == 1 || subcategories.count == 0 ? false : true
        }
    }
    var filterSubcategory: String!

    lazy var emptyStateLabel: UILabel = {
        let label = UILabel()

        label.text = "No items to show. Try changing the filter."
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.60)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        return label
    }()

    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared
    let notificationCenter = NotificationCenter.default

    let numberOfColumns = 3
    let edgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: #selector(filtersUpdated(notification:)), name: .filtersUpdated, object: nil)
        setupViews()
        subcategories = findSubcategories()
        filteredClosetItems = findFilteredClosetItems()
    }

    private func setupViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    @objc func filtersUpdated(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: String] {
            filterSubcategory = userInfo[NotificationUserInfo.newFilterSubcategory]
            filteredClosetItems = findFilteredClosetItems()
            collectionView.reloadData()
        }
    }

    @IBAction func touchedFilter(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: UIStoryboard.filtersSegue, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController, let filtersVC = navVC.viewControllers.first as? FiltersVC {
            filtersVC.category = category
            filtersVC.filterSubcategories = subcategories
            filtersVC.filterSubcategory = userStuffManager.closet.filterForCategory(category: category)
        }
    }

    // Helper methods

    private func findFilteredClosetItems() -> [ClosetItem] {
        if filterSubcategory == DefaultSubcategory.showAll {
            return closetItems
        } else {
            return closetItems.filter({ (closetItem) -> Bool in
                if closetItem.categorySubcategory.subcategory ?? "" == filterSubcategory {
                    return true
                } else {
                    return false
                }
            })
        }
    }

    private func findSubcategories() -> [String] {
        var subcategories: Set<String> = []

        for closetItem in closetItems {
            if let foundSubcategory = closetItem.categorySubcategory.subcategory {
                subcategories.insert(foundSubcategory)
            }
        }

        return Array(subcategories)
    }

    private func presentEmptyState() {
        emptyStateLabel.alpha = 1
    }

    private func hideEmptyState() {
        emptyStateLabel.alpha = 0
    }
}

extension ItemsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredClosetItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        let closetItem = filteredClosetItems[indexPath.row]
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
