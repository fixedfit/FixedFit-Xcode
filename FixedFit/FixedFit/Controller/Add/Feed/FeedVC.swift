//
//  FeedVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 4/28/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class FeedVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func segueToUserFinderVC(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: UIStoryboard.userFinderSegue, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userFinderVC = segue.destination as? UserFinderVC {
            userFinderVC.followBlockType = .follow
        }
    }
}
