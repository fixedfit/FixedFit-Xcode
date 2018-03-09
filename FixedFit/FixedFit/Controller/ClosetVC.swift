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

    var tags: Set<String> = [] {
        didSet {
            if tags.count == 0 {
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
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: #selector(tagsUpdated), name: .tagsUpdated, object: nil)
        setupViews()
        firebaseManager.fetchTags(for: userStuffManager.username) { [weak self] (foundTags, error) in
            if let _ = error {
                print("Trouble fetching tags")
            } else if let foundTags = foundTags {
                self?.tags = foundTags
                self?.tagsTableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    private func setupViews() {
        tagsTableView.dataSource = self
        tagsTableView.delegate = self
        tagsTableView.tableFooterView = UIView()

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
        tags = userStuffManager.tags
        tagsTableView.reloadData()
    }

    private func presentEmptyState() {
        emptyStateLabel.alpha = 1
    }

    private func hideEmptyState() {
        emptyStateLabel.alpha = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = segue.destination as? ItemsVC {
            print("Yay we about to segue")
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

        cell.tagNameLabel.text = tag

        return cell
    }
}

extension ClosetVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "itemsSegue", sender: nil)
    }
}
