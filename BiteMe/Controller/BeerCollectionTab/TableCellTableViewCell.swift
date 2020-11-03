//
//  TableCellTableViewCell.swift
//  BiteMe
//
//  Created by Jan Krzempek on 07/09/2020.
//  Copyright © 2020 Jan Krzempek. All rights reserved.
//

import UIKit

class TableCellTableViewCell: UITableViewCell {

    @IBOutlet weak var CellsImage: UIImageView!
    
    @IBOutlet weak var CellsNameLabel: UILabel!
    @IBOutlet weak var CellsAlcoLabel: UILabel!
    @IBOutlet weak var CellsBackBottleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


}
