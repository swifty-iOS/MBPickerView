//
//  PickerCell.swift
//  Sample
//
//  Created by Manish Bhande on 23/05/17.
//  Copyright © 2017 Manish Bhande. All rights reserved.
//

import UIKit

class PickerCell: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    class func loadFromNib() -> PickerCell? {
        return Bundle.main.loadNibNamed("PickerCell", owner: nil, options: nil)?.first as? PickerCell
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
