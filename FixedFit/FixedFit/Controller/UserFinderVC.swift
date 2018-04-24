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
    @IBOutlet var viewTapGestureRecognizer: UITapGestureRecognizer!
    
    //Initialize variables used to finding users from multiple sources
    var mode = ""
    var viewTitle = "Title"
    var users: [UserInfo] = [] {
        didSet {
            checkEmptyUsers()
        }
    }

    private let firebaseManager = FirebaseManager.shared
    private let userStuffManager = UserStuffManager.shared

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
        viewTapGestureRecognizer.isEnabled = false

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

    @objc private func tappedFollow(_ button: UIButton) {
        if let cell = button.superview?.superview as? UserCell {
            let userInfo = users[cell.tag]
            let userUniqueID = userInfo.uid
            var currentUserInfo = userStuffManager.userInfo

            if !userUniqueID.isEmpty {
                if cell.following {
                    cell.toggleFollowing()
                    firebaseManager.unfollowUser(usernameUniqueID: userUniqueID) { (error) in
                        if error != nil {
                            // Show the user something
                        }
                    }
                    if let index = currentUserInfo.following.index(where: {$0 == userUniqueID}) {
                        currentUserInfo.following.remove(at: index)

                        userStuffManager.userInfo.following = currentUserInfo.following
                    }
                } else {
                    cell.toggleFollowing()
                    firebaseManager.followUser(usernameUniqueID: userUniqueID) { (error) in
                        if error != nil {
                            // Show the user something
                        }
                    }
                    currentUserInfo.following.append(userUniqueID)
                    userStuffManager.userInfo.following = currentUserInfo.following
                }
            }
        }
    }

    @IBAction func tappedView(_ sender: UITapGestureRecognizer) {
        userSearchBar.resignFirstResponder()
    }
}

extension UserFinderVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        let userInfo = users[indexPath.row]
        let currentUserInfo = userStuffManager.userInfo

        if currentUserInfo.following.contains(userInfo.uid) {
            cell.configure(userInfo, isFollowing: true)
        } else {
            cell.configure(userInfo, isFollowing: false)
        }

        cell.tag = indexPath.row
        cell.followButton.addTarget(self, action: #selector(tappedFollow(_:)), for: .touchUpInside)

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
        
        //Obtain the user's information
        let userInfo = users[indexPath.row]
        let uid = userInfo.uid
        
         //Transition to the UserViewVC
         guard let vc = PushViews.executeTransition(vcName: PushViewKeys.userviewVC, storyboardName: PushViewKeys.userfinder, newString: uid, newMode: self.mode) else {return}
         
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
        let username = searchBar.text ?? ""

        if !username.isEmpty {
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

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewTapGestureRecognizer.isEnabled = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        viewTapGestureRecognizer.isEnabled = false
    }
}
