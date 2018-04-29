//
//  Block_A_User.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/29/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import UIKit
class Block_A_User: MainSupportFramework{
    init(){
        super.init(newImages: nil, newMessages: ["To block a user, you can search up the user's name from the feed or select a user from either your followers or someone you are following",
                                                 "After you have selected a user, you can select the block button, which the user is removed from either your followers or people you are following.",
                                                 "You can also see the user's you blocked in the Blocked Users section of the settings.",
                                                 "From the Blocked Users section you can choose to unblock them."])
    }
}
