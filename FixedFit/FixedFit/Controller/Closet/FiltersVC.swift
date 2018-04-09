//
//  FiltersVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/19/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

struct DefaultSubcategory {
    static let showAll = "show all"
}

class FiltersVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var category: String!
    var filterSubcategories: [String] = []
    var filterSubcategory: String? = nil
    var allFilterSubcategories: [String] {
        return filterSubcategories + [DefaultSubcategory.showAll]
    }

    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared
    let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    @IBAction func touchedDone(_ sender: UIBarButtonItem) {
        let newFilterSubcategory = filterSubcategory ?? DefaultSubcategory.showAll
        let newFilterSubcategoryInfo = [NotificationUserInfo.newFilterSubcategory: newFilterSubcategory]

        userStuffManager.closet.filters[category] = filterSubcategory
        firebaseManager.saveSubcategoryFilter(subcategoryFilter: newFilterSubcategory, category: category)
        notificationCenter.post(name: .filtersUpdated, object: nil, userInfo: newFilterSubcategoryInfo)
        dismiss(animated: true, completion: nil)
    }
}

extension FiltersVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFilterSubcategories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubcategoryCell.identifier, for: indexPath) as! SubcategoryCell
        let cellFilterSubcategory = allFilterSubcategories[indexPath.row]

        cell.subcategoryNameLabel.text = cellFilterSubcategory

        if let filterSubcategory = filterSubcategory {
            if filterSubcategory == cellFilterSubcategory  {
                cell.checkmarkImageView.image = #imageLiteral(resourceName: "bluecheckmark")
            } else {
                cell.checkmarkImageView.image = #imageLiteral(resourceName: "graycheckmark")
            }
        } else {
            cell.checkmarkImageView.image = #imageLiteral(resourceName: "graycheckmark")
        }

        return cell
    }
}

extension FiltersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SubcategoryCell
        let subcategory = cell.subcategoryNameLabel.text

        filterSubcategory = subcategory ?? ""
        tableView.reloadData()
    }
}
