//
//  SelectImageView.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 20/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

typealias selectImageHandler = ((_ image:UIImage? , _ info:[String : Any]?) -> Void)


class SelectImageView: UIView {

    @IBOutlet weak var btnCamera : UIButton!
    @IBOutlet weak var btnGallery : UIButton!
    @IBOutlet weak var lblSelectImg : UILabel!

    var completionBlock : selectImageHandler?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        if Localization.sharedInstance.getLanguage() == CLanguageArabic {
            lblSelectImg.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            btnGallery.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            btnCamera.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            
            btnGallery.contentHorizontalAlignment = .right
            btnCamera.contentHorizontalAlignment = .right

            btnGallery.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
            btnCamera.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)

        } else {
            lblSelectImg.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            btnGallery.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            btnCamera.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
    }
    
    func updateOrigin(x: CGFloat, y: CGFloat, completion: selectImageHandler?)  {
        
        self.CViewSetX(x: x)
        self.CViewSetY(y: y)
        self.CViewSetWidth(width:260)
        self.CViewSetHeight(height: 277)
        self.completionBlock = completion
    }
    
    @IBAction func btnGalleryClicked(_sender : UIButton) {
     
        
        self.viewController?.presentImagePickerControllerWithGallery(allowEditing: false) { (image, data) in
            
            if self.completionBlock != nil {
                
                if image != nil {
                    
                    self.completionBlock!(image, data)
                    self.removeFromSuperview()
                    
                }
            }
        }
        
    }
    
    @IBAction func btnCameraClicked(_sender : UIButton) {
        
        CTopMostViewController.presentImagePickerControllerWithCamera(allowEditing: false) { (image, data) in
            
            if self.completionBlock != nil {
                
                if image != nil {
                    
                    self.completionBlock!(image, data)
                    self.removeFromSuperview()
                    
                }
            }
        }
    }
    
    @IBAction func btnCloseClicked(_sender : UIButton) {
        
        self.removeFromSuperview()
    }
}
