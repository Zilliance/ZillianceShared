//
//  ActionPlanCell.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 11-07-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import ZillianceShared

class ActionPlanCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var recurrenceContainer: UIView!
    @IBOutlet weak var recurrenceLabel: UILabel!
    @IBOutlet weak var notificationTypeImageView: UIImageView!
    @IBOutlet weak var recurrenceIndicatorView: UIView!
    @IBOutlet weak var notificationText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }

    
    func configure(item: NotificationTableItemViewModel) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        self.dayLabel.text = formatter.string(from: item.nextDate).uppercased()
        
        formatter.dateFormat = "d"
        self.dayNumberLabel.text = formatter.string(from: item.nextDate)
        
        formatter.dateFormat = "h:mm a"
        self.dateLabel.text = formatter.string(from: item.nextDate)
        
        if (item.recurrence == .weekly) {
            self.recurrenceContainer.isHidden = false
            self.recurrenceIndicatorView.backgroundColor = UIColor.recurrenceColor
        } else {
            self.recurrenceContainer.isHidden = true
            self.recurrenceIndicatorView.backgroundColor = UIColor.lightGray
        }
        
        let imageName = item.type == .calendar ? "iconCalendar" : "iconNotification"
        let image = UIImage(named: imageName)
        self.notificationTypeImageView.image = image
        
        self.notificationText.text = item.body
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
    }
    

}
