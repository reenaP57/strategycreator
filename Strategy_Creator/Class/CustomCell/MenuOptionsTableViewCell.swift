//
//  MenuOptionsTableViewCell.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 19/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

class MenuOptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var imgMenu: GenericImageView!
    @IBOutlet weak var lblMenu: GenericLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        
        if Localization.sharedInstance.getLanguage() == CLanguageArabic
        {
            imgMenu.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
