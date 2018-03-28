//
//  SettingsVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 3/13/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UIViewController, UITableViewDelegate{
    
    let firebaseManager = FirebaseManager.shared
    //MARK: Management of Categories
    //MARK: Management of blocked users
    //MARK: Change user email and password
    //MARK: Push Notification Settings
    //MARK: Support Center - FAQ and Contacts
    //MARK: log out of user account
    @IBAction func tappedLogout(_ sender: UIButton) {
        let message = "Are you sure you want to logout?"
        let rightButtonData = ButtonData(title: "Yes, I'm Sure", color: .fixedFitPurple) { [weak self] in
            self?.firebaseManager.logout { _ in }
        }
        let leftButtonData = ButtonData(title: "Nevermind", color: .fixedFitBlue, action: nil)
        let informationVC = InformationVC(message: message, image: #imageLiteral(resourceName: "question"), leftButtonData: leftButtonData, rightButtonData: rightButtonData)
        
        present(informationVC, animated: true, completion: nil)
        
    }

    //MARK: Delete Account
    
}
