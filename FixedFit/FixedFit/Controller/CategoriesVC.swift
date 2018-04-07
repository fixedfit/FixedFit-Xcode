//
//  CategoriesVC.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/7/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class CategoriesVC: UIViewController {
    var viewTitle: String!
    override func viewWillAppear(_ animated: Bool){
        self.navigationItem.title = viewTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
