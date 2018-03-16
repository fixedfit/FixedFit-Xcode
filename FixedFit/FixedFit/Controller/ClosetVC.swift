//
//  ClosetVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class ClosetVC: UIViewController {
    @IBOutlet weak var categoriesTableView: UITableView!

    var categories: [String] {
        get {
            return userStuffManager.closet.categorySubcategoryStore.allCategories
        }

        set {
            if newValue.count == 0 {
                presentEmptyState()
            } else {
                hideEmptyState()
            }
        }
    }

    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared
    let notificationCenter = NotificationCenter.default

    lazy var emptyStateLabel: UILabel = {
        let label = UILabel()

        label.text = "No items in your closet"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.60)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        return label
    }()
    lazy var tableRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(fetchCloset), for: .valueChanged)

        return refreshControl
    }()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: #selector(categoriesUpdated), name: .categoriesUpdated, object: nil)
        setupViews()
        fetchCloset()
    }

    override func viewWillAppear(_ animated: Bool) {
        let indexPath = categoriesTableView.indexPathForSelectedRow

        if let indexPath = indexPath {
            categoriesTableView.deselectRow(at: indexPath, animated: true)
        }
    }

    private func setupViews() {
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.tableFooterView = UIView()
        categoriesTableView.refreshControl = tableRefreshControl

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
    }

    func presentAddCategoryVC(images: [UIImage]) {
        if let navVC = UIStoryboard.addCategoryVC as? UINavigationController,
            let addCategoryVC = navVC.topViewController as? AddCategoryVC {
            addCategoryVC.photos = images
            present(navVC, animated: true, completion: nil)
        }
    }

    @objc private func categoriesUpdated() {
        fetchCloset()
    }

    @objc private func fetchCloset() {
        firebaseManager.fetchCloset { [weak self] (closet, error) in
            guard let strongSelf = self else { return }

            if let _ = error {
                print("Trouble fetching closet")
            } else if let closet = closet {
                // If the second line isn't included the empty state won't show
                // Def change this later
                self?.userStuffManager.updateCloset(closet: closet)
                self?.categories = strongSelf.userStuffManager.closet.categorySubcategoryStore.allCategories
                self?.categoriesTableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.categoriesTableView.refreshControl?.endRefreshing()
            }
        }
    }

    private func presentEmptyState() {
        emptyStateLabel.alpha = 1
    }

    private func hideEmptyState() {
        emptyStateLabel.alpha = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let itemsVC = segue.destination as? ItemsVC,
            let category = sender as? String {
            itemsVC.closetItems = userStuffManager.closet.closetItems(matching: category)
        }
    }
}

extension ClosetVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ClosetCategoryCell.identifier, for: indexPath) as! ClosetCategoryCell
        let category = categories[indexPath.row]
        let imageStoragePath = userStuffManager.closet.imageStoragePath(for: category)

        cell.categoryNameLabel.text = category
        cell.tag = indexPath.row

        if let imageStoragePath = imageStoragePath {
            firebaseManager.fetchImage(storageURL: imageStoragePath, completion: { (image, error) in
                if cell.tag == indexPath.row {
                    cell.selectedItemImageView.image = image
                }
            })
        }

        return cell
    }
}

extension ClosetVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = categoriesTableView.cellForRow(at: indexPath) as? ClosetCategoryCell
        let category = cell?.categoryNameLabel.text

        performSegue(withIdentifier: UIStoryboard.itemsSegue, sender: category)
    }
}
