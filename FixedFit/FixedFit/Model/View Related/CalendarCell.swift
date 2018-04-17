//
//  CustomCell.swift
//  FixedFit
//
//  Created by clo on 3/1/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var closetEvent: UIImageView!
    @IBOutlet weak var outfitImage: UIImageView!
    
    static let identifier = "calendarCell"
}
