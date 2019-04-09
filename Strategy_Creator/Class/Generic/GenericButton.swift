//
//  GenericButton.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 19/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

class GenericButton: UIButton {


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
        self.setTitle(CLocalize(text: (self.titleLabel?.text ?? "")), for: .normal)
        self.titleLabel?.font = appDelegate?.convertToAppFont(font: self.titleLabel?.font ?? CFontCarterOne(size: 40, type: .Regular))
        
        if self.tag == 100
        {
            self.setTitleColor(ColorBlack, for: .normal)
            self.setTitleColor(ColorBlue, for: .selected)
            
            self.layer.cornerRadius = self.CViewHeight/3.0
            self.layer.masksToBounds = true
        }
    }
}

//MARK: - set UI
extension GenericButton
{
    
}

