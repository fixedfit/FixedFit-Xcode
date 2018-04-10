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
class UserFinderVC: UIViewController, UISearchBarDelegate{
    
    @IBOutlet weak var userSearchBar: UISearchBar!
    private let firebaseManager = FirebaseManager.shared
    
    //Initialize variables used to finding users from multiple sources
    var mode = ""
    var viewTitle = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        userSearchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        let ref = firebaseManager.ref.child(FirebaseKeys.users)
        
        ref.queryOrdered(byChild: FirebaseKeys.username)
        .queryStarting(atValue: searchBar.text!)
            .queryEnding(atValue: searchBar.text!+"\u{f8ff}")
            .queryLimited(toFirst: 10)
            .observeSingleEvent(of: .value) {
                (snap) in
                print(snap.value as? [String: Any])
                if !snap.exists() {
                    print("Nothing")
                }
        }
        
    }
    
    /*
     Live Searching
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text!)
        let ref = firebaseManager.ref.child(FirebaseKeys.users)
     
        if searchBar.text! != nil {
            ref.queryOrdered(byChild: FirebaseKeys.username)
            .queryStarting(atValue: searchBar.text!)
            .queryEnding(atValue: searchBar.text!+"\u{f8ff}")
            .queryLimited(toFirst: 25)
            .observeSingleEvent(of: .value) {
            (snap) in
                print(snap.value)
                if !snap.exists() {
                    print("Nothing")
                }
            }
        }
     } */
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = viewTitle
    }
}

