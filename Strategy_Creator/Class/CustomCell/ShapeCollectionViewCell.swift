//
//  ShapeCollectionViewCell.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 20/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

class ShapeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgShape: GenericImageView!
    @IBOutlet weak var lblShapeName: GenericLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        if Localization.sharedInstance.getLanguage() == CLanguageArabic {
            lblShapeName.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        } else {
            lblShapeName.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }

    }

}
