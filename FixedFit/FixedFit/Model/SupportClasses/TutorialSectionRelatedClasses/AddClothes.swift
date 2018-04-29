//
//  AddClothes.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/29/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit
class AddClothes: MainSupportFramework{
    init(){
        super.init(newImages: nil, newMessages: ["Select the plus sign to start adding photos",
                                                 "Take photos of clothes from the camera button and/or use photos of clothes from the device's photo gallery",
                                                 "Each photo needs a main category to applied to it. So either select a default category or created a custom category. Each main category can also contain subcategories",
                                                 "Once every photo has been given a category, select the down button. All of the added outfits will be displayed in the closet under their corresponding categories"])
    }
}
