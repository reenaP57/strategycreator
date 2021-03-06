//
//  GenericLabel.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 19/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

class GenericLabel: UILabel {

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }


    func initialize()
    {
        self.text = CLocalize(text: self.text ?? "")
        self.font = appDelegate?.convertToAppFont(font: self.font)
        self.textColor = ColorBlack
        
        if self.tag == 100
        {
            self.textColor = ColorWhite
        }
    }
}
