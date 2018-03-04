//
//  ProfileVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 2/20/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    let firebaseManager = FirebaseManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tappedLogout(_ sender: Any) {
        let message = "Are you sure you want to logout?"
        let rightButtonData = ButtonData(title: "Yes, I'm Sure", color: .fixedFitPurple) { [weak self] in
            self?.firebaseManager.logout { _ in }
        }
        let leftButtonData = ButtonData(title: "Nevermind", color: .fixedFitBlue, action: nil)
        let informationVC = InformationVC(message: message, image: #imageLiteral(resourceName: "question"), leftButtonData: leftButtonData, rightButtonData: rightButtonData)

        present(informationVC, animated: true, completion: nil)
    }
}
