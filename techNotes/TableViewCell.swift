//
//  TableViewCell.swift
//  techNotes
//
//  Created by Toni SILVA DA COSTA on 23/05/2016.
//  Copyright © 2016 VienneDoc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var Client: UILabel!
    @IBOutlet weak var Technicien: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Danger: UIImageView!
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var ovalShape: UIImageView!
    @IBOutlet weak var Note: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
