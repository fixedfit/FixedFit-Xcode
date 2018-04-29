//
//  HelpCenter_FAQ.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/28/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

/*
 Class to display frequently asked questions to the user
 This class will have a answers variable to will only hold the answers to the questions of Users
 Note, the number of answers needs to equal the number of questions in messages
 */
import Foundation
import UIKit
class HelpCenter_FAQ: MainSupportFramework{
    var answers:[String]?
    init(){
        super.init(newImages: nil,
                   newMessages: ["Can we share our outfits with our friends?",
                                 "Can you put more than one clothing item in a outfit?",
                                 "How do i hide my outfits from people i don't know?",
                                 "How can i add more categories without adding them while taking photos",
                                 "Can I add an outfit for more then one event?"])
        
        self.answers = ["yes",
                        "yes you can put more then one clothing item per outfit.",
                        "You can set your profile to private so only followers and people you are following can see them. You can also block a user so your account information won't be displayed to them.",
                        "You can go to the Custom Categories section of the Settings and add/delete Custom Categories for your outfits.",
                        "Yes you can add an outfit for multiple events."]
    }
}
