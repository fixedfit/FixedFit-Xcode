//
//  MainSupportFramework.swift
//  FixedFit
//
//  Created by Esmeralda Salas on 4/28/18.
//  Copyright © 2018 UNLV. All rights reserved.
//
/*
 Super class that will contain two variables for the supportVC that will be used to display message and/or images to the user in various modes of the SupportVC
 images = images that will be displayed to the user
 messages = text that will appear to the user
 
 Note, the ordering of the text and images corresponding to the Tutorial sections do matter,
 but for the help center, it does not.
 
 */
import Foundation
import UIKit
class MainSupportFramework{
    var images:[UIImage]?
    var messages:[String]?
    
    init(newImages: [UIImage]?, newMessages: [String]?){
        self.images = newImages
        self.messages = newMessages
    }
}
