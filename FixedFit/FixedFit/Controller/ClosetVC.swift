//
//  ClosetVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class ClosetVC: UIViewController {
    @IBOutlet weak var tagsTableView: UITableView!

    var tags: Set<String> {
        get {
            return userStuffManager.closet.allTags
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
        notificationCenter.addObserver(self, selector: #selector(tagsUpdated), name: .tagsUpdated, object: nil)
        setupViews()
        fetchCloset()
    }

    override func viewWillAppear(_ animated: Bool) {
        let indexPath = tagsTableView.indexPathForSelectedRow

        if let indexPath = indexPath {
            tagsTableView.deselectRow(at: indexPath, animated: true)
        }
    }

    private func setupViews() {
        tagsTableView.dataSource = self
        tagsTableView.delegate = self
        tagsTableView.tableFooterView = UIView()
        tagsTableView.refreshControl = tableRefreshControl

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
    }

    func presentTagVC(images: [UIImage]) {
        if let navVC = UIStoryboard.tagVC as? UINavigationController,
            let tagVC = navVC.topViewController as? TagVC {
            tagVC.items = images
            present(navVC, animated: true, completion: nil)
        }
    }

    @objc private func tagsUpdated() {
        fetchCloset()
    }

    @objc private func fetchCloset() {
        firebaseManager.fetchCloset { [weak self] (closet, error) in
            guard let strongSelf = self else { return }

            if let _ = error {
                print("Trouble fetching closet")
            } else if let closet = closet {
                self?.userStuffManager.updateCloset(closet: closet)
                self?.tags = strongSelf.userStuffManager.closet.allTags
                self?.tagsTableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.tagsTableView.refreshControl?.endRefreshing()
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
        if let _ = segue.destination as? ItemsVC {
            print("About to segue to ItemsVC")
        }
    }
}

extension ClosetVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagSectionCell.identifier, for: indexPath) as! TagSectionCell
        let tag = Array(tags)[indexPath.row]
        let imageStoragePath = userStuffManager.closet.imageStoragePath(for: tag)

        cell.tagNameLabel.text = tag
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
        performSegue(withIdentifier: UIStoryboard.itemsSegue, sender: nil)
    }
}
