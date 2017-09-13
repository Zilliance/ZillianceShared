//
//  MeditationPlanCell.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 14-07-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class MeditationPlanCell: UITableViewCell {
    @IBOutlet weak var viewContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewContainer.layer.cornerRadius = 4
        self.contentView.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
