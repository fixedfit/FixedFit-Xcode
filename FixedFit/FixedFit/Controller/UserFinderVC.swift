//
//  UserFinderVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/3/18.
//  Edited by Alexander Cheung on 4/5/18
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

class UserFinderVC: UIViewController {

    @IBOutlet weak var userSearchBar: UISearchBar!
    @IBOutlet weak var searchStatusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    //Initialize variables used to finding users from multiple sources
    var mode = ""
    var viewTitle = "Title"
    var users: [UserInfo] = [] {
        didSet {
            checkEmptyUsers()
        }
    }

    private let firebaseManager = FirebaseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func setupViews() {
        userSearchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        navigationItem.title = viewTitle
        userSearchBar.autocapitalizationType = .none

        searchStatusLabel.text = "Type in username"
        self.navigationItem.title = self.viewTitle
    }

    private func checkEmptyUsers() {
        if users.isEmpty {
            searchStatusLabel.isHidden = false
        } else {
            searchStatusLabel.isHidden = true
        }
    }
}

extension UserFinderVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        let userInfo = users[indexPath.row]

        cell.configure(userInfo)

        if !userInfo.previousPhotoURL.isEmpty {
            firebaseManager.fetchImage(storageURL: userInfo.previousPhotoURL) { (image, error) in
                if error != nil {
                    //If user does not have a photo set up, then assign the default photo as the profile picture
                    cell.userPhotoImageView.image = UIImage(named: "defaultProfile")
                } else {
                    cell.userPhotoImageView.image = image
                }
            }
        }

        return cell
    }
}

extension UserFinderVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         //Transition to the UserViewVC
         guard let vc = PushViews.executeTransition(vcName: "UserViewVC", storyboardName: "UserFinder", newTitle: "User id", newMode: self.mode) else {return}
         
         if let vc = vc as? UserViewVC{
             //Push View Controller onto Navigation Stack
             self.navigationController?.pushViewController(vc, animated: true)
         } else if let vc = vc as? InformationVC{
             self.present(vc, animated: true, completion: nil)
         }
 
    }
}

extension UserFinderVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        firebaseManager.fetchUsers(nameStartingWith: searchBar.text!) { [weak self] (usersInfos, error) in
            if error != nil {
                // Show the user something
            } else if let usersInfos = usersInfos {
                self?.users = usersInfos
                self?.searchStatusLabel.text = "No users found"
                self?.tableView.reloadData()
                searchBar.resignFirstResponder()
            }
        }
    }
}
