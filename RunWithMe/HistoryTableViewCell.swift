//
//  HistoryTableViewCell.swift
//  RunWithMe
//
//  Created by Lukasz Pik on 12/01/2019.
//  Copyright © 2019 Łukasz Pik. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
