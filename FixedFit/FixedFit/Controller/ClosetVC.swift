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

    var tagSections: [[String: Any]] = [] {
        didSet {
            if tagSections.count == 0 {
                presentEmptyState()
            } else {
                hideEmptyState()
            }
        }
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        tagsTableView.dataSource = self
        tagsTableView.delegate = self
        tagsTableView.tableFooterView = UIView()

        if tagSections.count == 0 {
            presentEmptyState()
        } else {
            hideEmptyState()
        }
    }

    func presentTagVC(images: [UIImage]) {
        if let navVC = UIStoryboard.tagVC as? UINavigationController,
            let tagVC = navVC.topViewController as? TagVC {
            tagVC.images = images
            present(navVC, animated: true, completion: nil)
        }
    }

    private func presentEmptyState() {
        emptyStateLabel.alpha = 1
    }

    private func hideEmptyState() {
        emptyStateLabel.alpha = 0
    }
}

extension ClosetVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagSections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagSectionCell.identifier, for: indexPath) as! TagSectionCell
        let tagSection = tagSections[indexPath.row]

        cell.tagNameLabel.text = tagSection["name"] as? String ?? ""

        return cell
    }
}

extension ClosetVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
