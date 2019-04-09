//
//  GenericView.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 19/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

class GenericView: UIView {

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
        if self.tag == 100 //Corner Radius
        {
            self.layer.cornerRadius = self.CViewHeight/3.0
            self.layer.masksToBounds = true
        }
        if self.tag == 101 // Shadow
        {
            self.layer.shadowOffset = CGSize(width: 2, height: 2)
            self.layer.shadowRadius = 3.0
            self.layer.shadowColor =  UIColor.lightGray.cgColor
            self.layer.shadowOpacity = 0.35
            
            if self.accessibilityLabel == "1"
            {
                let bottomBorder = CALayer()
                bottomBorder.frame = CGRect(x: 0.0, y: 43.0, width: self.frame.size.width, height: 1.0)
                bottomBorder.backgroundColor = UIColor(white: 0.8, alpha: 1.0).cgColor
                self.layer.addSublayer(bottomBorder)
            }
        }
        else if self.tag == 102 // Pop View
        {
            self.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.layer.shadowRadius = 3.0
            self.layer.shadowColor =  UIColor.lightGray.cgColor
            self.layer.shadowOpacity = 0.7

            self.layer.borderColor = ColorBlue.cgColor
            self.layer.borderWidth = 1.0
        }
    }
}



extension GenericView : NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let vw  = UIView(frame: self.frame)
        vw.backgroundColor = self.backgroundColor
                
        return vw
    }
}
