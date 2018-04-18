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
import ObjectMapper

class UserFinderVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    private let firebaseManager = FirebaseManager.shared

    //Initialize variables used to finding users from multiple sources
    var mode = ""
    var viewTitle = ""
    var userList: [UserStuffManager] = []
    let cellReuseIdentifier = "UserCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        userSearchBar.delegate = self
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = viewTitle
    }
}

// UITableViewDataSource

extension UserFinderVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! UserTableViewCell
        let user = userList[indexPath.row]
        cell.configure(user)
        
        return cell
    }
}

extension UserFinderVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let ref = firebaseManager.ref.child(FirebaseKeys.users)
        let usermanager = UserStuffManager.shared
        usermanager.fetchUserInformation()
        
        ref.queryOrdered(byChild: FirebaseKeys.username)
        .queryStarting(atValue: searchBar.text!)
        .queryEnding(atValue: searchBar.text!+"\u{f8ff}")
        .observeSingleEvent(of: .value) { snap in
                self.userList.removeAll()
                print(snap.key)
                guard let data = snap.value as? [String: Any] else {
                    return
                }
                
                for userData in data.values {
                    guard let unwrappedData = userData as? [String: Any] else { continue }
                    guard let user = Mapper<UserStuffManager>().map(JSON: unwrappedData) else { continue }
                   
                    //Check If Current User is Following This user
                        //Save Whether or Not in isFollowing
                    
                    self.userList.append(user)
                }
                
                self.tableView.reloadData()
        }

    }
}

