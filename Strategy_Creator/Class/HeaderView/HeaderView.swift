//
//  HeaderView.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 19/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit
import MessageUI

class HeaderView: UIView, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var btnMenu: GenericButton!
    @IBOutlet weak var btnShare: GenericButton!
    @IBOutlet weak var btnSave: GenericButton!
    @IBOutlet weak var btnRedo: GenericButton!
    @IBOutlet weak var btnUndo: GenericButton!
    
    @IBOutlet weak var lblTitle: GenericLabel!
    @IBOutlet weak var imgHeader: GenericImageView!
    
    var vwSideMenu : SideMenuView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func showHomeButtons()
    {
        self.btnShare.isHidden = false
        self.btnSave.isHidden = false
        self.btnUndo.isHidden = false
        self.btnRedo.isHidden = false
    }
    
    func hideHomeButtons()
    {
        self.btnShare.isHidden = true
        self.btnSave.isHidden = true
        self.btnUndo.isHidden = true
        self.btnRedo.isHidden = true

    }
    
    func hideSideMenuView() {
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            self.vwSideMenu?.vwOptions.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
            self.vwSideMenu?.removeFromSuperview()
        })
    }
    
    
    //MARK:- Button Click Action
    @IBAction func btnMenuClicked(_ sender: Any) {
        
        if (!(vwSideMenu != nil))
        {
            guard let sideMenu = SideMenuView.viewFromXib as? SideMenuView else {return}
            vwSideMenu = sideMenu
        }
        
        vwSideMenu?.center = btnMenu.center
        vwSideMenu?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        vwSideMenu?.vwOptions.alpha = 0
        
        vwSideMenu?.setRotationAngle()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.vwSideMenu?.transform = CGAffineTransform.identity
            self.vwSideMenu?.vwOptions.alpha = 1
            
            if Localization.sharedInstance.getLanguage() == CLanguageArabic {
                self.vwSideMenu?.center = CGPoint(x: self.btnMenu.frame.origin.x - 125, y: self.btnMenu.frame.origin.y + 150)
            } else {
                self.vwSideMenu?.center =  CGPoint(x: self.btnMenu.frame.origin.x + 170, y: self.btnMenu.frame.origin.y + 150)
            }
            
            self.vwSideMenu?.vwOptions.isHidden = false
            appDelegate?.window.addSubview(self.vwSideMenu!)

        }, completion: { (success:Bool) in
        })
        
        self.setClickeActionForHeaderView()
    }
    
    //MARK:-
    //MARK:- MFMailComposer Methods
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:-
    //MARK:- SideMenu Button Action
    
    func setClickeActionForHeaderView()
    {
        //... Home
        vwSideMenu?.btnHome.touchUpInside(genericTouchUpInsideHandler: { (sender) in
           
            self.hideSideMenuView()
            
            if (!self.isKind(of: HomeViewController.self)) {
                self.viewController?.navigationController?.popToRootViewController(animated: false)
            }
        })
        
        //... Select Language
        vwSideMenu?.btnSelectLanguage.touchUpInside(genericTouchUpInsideHandler: { (sender) in
           
            self.hideSideMenuView()
            
            if (!self.isKind(of: SelectLanguageViewController.self)) {
                guard let vcSelectLanguage = CMain_storyboard.instantiateViewController(withIdentifier: "vcSelectLanguage") as? SelectLanguageViewController else {return}
               
                if (self.viewController?.isKind(of: HomeViewController.self))! {
                    let homeVC = self.viewController as? HomeViewController
                    homeVC?.scratchDrawView.eraserView.removeFromSuperview()
                    vcSelectLanguage.imgCanvas = homeVC?.vwCanvas.snapshotImage
                }
            self.viewController?.navigationController?.pushViewController(vcSelectLanguage, animated: false)
            }
        })
        
        //... About US
        vwSideMenu?.btnAboutUs.touchUpInside(genericTouchUpInsideHandler: { (sender) in
            
            self.hideSideMenuView()
            
            if (!self.isKind(of: CMSViewController.self)) {
                
                guard let vcCMS = CMain_storyboard.instantiateViewController(withIdentifier: "vcCMS") as? CMSViewController else { return }
                vcCMS.strTitle = CAboutUs
                self.viewController?.navigationController?.pushViewController(vcCMS, animated: false)
            }
        })
        
        //... Contact US
        vwSideMenu?.btnContactUs.touchUpInside(genericTouchUpInsideHandler: { (sender) in
            
            self.hideSideMenuView()
            
            let composeVC: MFMailComposeViewController = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setSubject(CStrategyCreator)
            composeVC.setToRecipients(["abc@gmail.com"])
        
            
            if (!IS_SIMULATOR) {
                self.viewController?.present(composeVC, animated: true, completion: nil)
            }
            
        })
        
        vwSideMenu?.btnClose.touchUpInside(genericTouchUpInsideHandler: { (sender) in
            self.hideSideMenuView()
        })
        
    }
    
    
    func circleAnim(_ view: UIView, duration: CFTimeInterval) {
        let maskDiameter = CGFloat(sqrtf(powf(Float(view.frame.width), 2) + powf(Float(view.frame.height), 2)))
        let mask = CAShapeLayer()
        let animationId = "path"
        
        // Make a circular shape.
        mask.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: maskDiameter, height: maskDiameter), cornerRadius: maskDiameter / 2).cgPath
        
        // Center the shape in the view.
        mask.position = CGPoint(x: (view.bounds.width - maskDiameter) / 2, y: (view.bounds.height - maskDiameter) / 2)
        
        // Fill the circle.
        mask.fillColor = UIColor.black.cgColor
        
        // Add as a mask to the parent layer.
        view.layer.mask = mask
        
        // Animate.
        let animation = CABasicAnimation(keyPath: animationId)
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        // Create a new path.
        let newPath = UIBezierPath(roundedRect: CGRect(x: maskDiameter / 2, y: maskDiameter / 2, width: 0, height: 0), cornerRadius: 0).cgPath
        
        // Set start and end values.
        animation.fromValue = mask.path
        animation.toValue = newPath
        
        // Start the animaiton.
        mask.add(animation, forKey: animationId)
    }

    
}
