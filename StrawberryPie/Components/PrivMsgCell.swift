//
//  PrivMsgCell.swift
//  StrawberryPie
//
//  Created by iosdev on 09/12/2019.
//  Copyright © 2019 Team Työkkäri. All rights reserved.
//
// Reusable cell for private messages. Has a .xib file for styling.

import UIKit

class PrivMsgCell: UITableViewCell {
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var messagefield: UILabel!
}
