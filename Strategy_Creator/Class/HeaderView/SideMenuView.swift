//
//  SideMenuView.swift
//  Strategy_Creator
//
//  Created by mac-00017 on 01/05/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

class SideMenuView: UIView {

    @IBOutlet weak var btnClose: GenericButton!
    @IBOutlet weak var btnHome: GenericButton!
    @IBOutlet weak var btnSelectLanguage: GenericButton!
    @IBOutlet weak var btnAboutUs: GenericButton!
    @IBOutlet weak var btnContactUs: GenericButton!
    
    @IBOutlet weak var vwOptions: GenericView!
    @IBOutlet weak var vwContent: GenericView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.inititalize()
    }
    
    
    func inititalize()
    {
        //set Corner radius
      
        self.vwOptions.layer.cornerRadius = self.vwOptions.CViewHeight/2.0
        self.vwOptions.layer.masksToBounds = true
        
        self.vwContent.layer.cornerRadius = self.vwContent.CViewHeight/2.0
        self.vwContent.layer.masksToBounds = true
        
    }
    
    //MARK:- HELPER FUNCTIOn
    func setRotationAngle()
    {
        //set the rotation angle
        if Localization.sharedInstance.getLanguage() == CLanguageArabic
        {
            self.btnHome.transform = CGAffineTransform(rotationAngle: CGFloat(-20 * Double.pi / 180))
            self.btnSelectLanguage.transform = CGAffineTransform(rotationAngle: CGFloat(-30 * Double.pi / 180))
            self.btnAboutUs.transform = CGAffineTransform(rotationAngle: CGFloat(-40 * Double.pi / 180))
            self.btnContactUs.transform = CGAffineTransform(rotationAngle: CGFloat(-50 * Double.pi / 180))
        }
        else{
            self.btnHome.transform = CGAffineTransform(rotationAngle: CGFloat(20 * Double.pi / 180))
            self.btnSelectLanguage.transform = CGAffineTransform(rotationAngle: CGFloat(30 * Double.pi / 180))
            self.btnAboutUs.transform = CGAffineTransform(rotationAngle: CGFloat(40 * Double.pi / 180))
            self.btnContactUs.transform = CGAffineTransform(rotationAngle: CGFloat(50 * Double.pi / 180))
        }
        
    }
}
