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
    var followBlockType: FollowBlockType = .block

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
            var completion: (Error?) -> Void = { (error) in if error != nil { } }

            if !userUniqueID.isEmpty {
                cell.toggle()

                switch cell.cellType {
                case .follow:
                    if cell.following {
                        if let index = currentUserInfo.following.index(where: {$0 == userUniqueID}) {
                            currentUserInfo.following.remove(at: index)
                            userStuffManager.userInfo.following = currentUserInfo.following
                        }

                        firebaseManager.followUser(usernameUniqueID: userUniqueID, completion: completion)
                    } else {
                        currentUserInfo.following.append(userUniqueID)
                        userStuffManager.userInfo.following = currentUserInfo.following
                        firebaseManager.unfollowUser(usernameUniqueID: userUniqueID, completion: completion)
                    }
                case .block:
                    if cell.blocked{
                        currentUserInfo.blocked.append(userUniqueID)
                        userStuffManager.userInfo.blocked = currentUserInfo.blocked
                        firebaseManager.blockUser(usernameUniqueID: userUniqueID, completion: completion)
                    } else {
                        if let index = currentUserInfo.blocked.index(where: {$0 == userUniqueID}) {
                            currentUserInfo.blocked.remove(at: index)
                            userStuffManager.userInfo.blocked = currentUserInfo.blocked
                        }

                        firebaseManager.unblockUser(usernameUniqueID: userUniqueID, completion: completion)
                    }
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
        var followingOrBlocked: Bool = false

        cell.tag = indexPath.row
        cell.cellType = followBlockType
        cell.button.addTarget(self, action: #selector(tappedFollow(_:)), for: .touchUpInside)

        switch cell.cellType {
        case .follow: followingOrBlocked = currentUserInfo.following.contains(userInfo.uid)
        case .block: followingOrBlocked = currentUserInfo.blocked.contains(userInfo.uid)
        }

        cell.configure(userInfo, followingOrBlocked: followingOrBlocked)

        if !userInfo.previousPhotoURL.isEmpty {
            firebaseManager.fetchImage(storageURL: userInfo.previousPhotoURL) { (image, error) in
                if error != nil {
                    //If user does not have a photo set up, then assign the default photo as the profile picture
                    cell.userPhotoImageView.image = UIImage(named: "defaultProfile")
                } else {
                    cell.userPhotoImageView.image = image
                    self.users[indexPath.row].photo = image
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
        let currentUid = userStuffManager.userInfo.uid

        //Transition to the UserViewVC
        guard let vc = PushViews.executeTransition(vcName: PushViewKeys.userviewVC, storyboardName: PushViewKeys.userfinder, newString: uid, newMode: self.mode) else {return}
         
        if let vc = vc as? UserViewVC{
            
            //Due to delays in firebase retrieval by the time the UserViewVC is displayed, the profile information of the current user is recorded later in time after the view appears
            //So, initialize the profileStatus variable with the selected user's status boolean
            vc.profileStatus = userInfo.publicProfile
            
            //Determine if the currentUser is not inside either the following or followers list of the selected user
            if(vc.profileStatus == false){

                if(!userInfo.following.contains(currentUid) && !userInfo.followers.contains(currentUid)){
                    vc.uidContainedInList = false
                } else {
                    vc.uidContainedInList = true
                }
            } else {
                vc.uidContainedInList = true
            }
                
            //Obtain the selected users profile photo from the userInfo Object at the current index
            let image = self.users[indexPath.row].photo
            vc.initialProfileImage = image

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
