//
//  ShapeFormatTool.swift
//  Strategy_Creator
//
//  Created by mac-00017 on 26/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

enum TouchesEvent : Int {
    case Begin
    case Moved
    case Ended
}

enum shapeToolDisableOption : Int {
    case FillColorDisable
    case BorderColorDisable
    case AllEnable
}

typealias sliderUpdatedValue = (Float) -> ()
typealias sliderTouches = (TouchesEvent) -> ()

class ShapeFormatTool: UIView {
    
    @IBOutlet weak var btnBorderColor : UIButton!{
        didSet {
            if Localization.sharedInstance.getLanguage() == CLanguageArabic {
                btnBorderColor.contentHorizontalAlignment = .right
            }
        }
    }
    @IBOutlet weak var bgImageView : UIImageView!
        
        
    @IBOutlet weak var btnFillColor : UIButton!{
        didSet {
            if Localization.sharedInstance.getLanguage() == CLanguageArabic {
                btnFillColor.contentHorizontalAlignment = .right
            }
        }
    }
    
    @IBOutlet weak var lblSliderCount : UILabel!
    @IBOutlet weak var sliderWidth : CustomSlider! {
        didSet {
            sliderWidth.delegate = self
        }
    }
    @IBOutlet weak var layoutConstCenterViewCount: NSLayoutConstraint!
    var lastCenter: CGPoint?
    var completionBlock : sliderUpdatedValue?
    var sliderTouchesEventBlock : sliderTouches?
}

extension ShapeFormatTool {
    
    @IBAction func sliderValueChanged(_ sender: CustomSlider) {
        
        if sender == sliderWidth {
            
            let currentPosition = sliderWidth.getXPositionWithRespectToCurrentValue(thumbWidthPadding : 4.0)
            layoutConstCenterViewCount.constant = CGFloat(currentPosition ?? Float(layoutConstCenterViewCount.constant))
            lblSliderCount.text = String(format: "%.1f", sliderWidth.value)
            
            guard let sliderValue = completionBlock else {return}
            sliderValue(sliderWidth.value)
            
        }
    }
    
    func sliderPreFillWidth(_ width : Float)  {
        
        sliderWidth.value = width
        
        DispatchQueue.main.async {
            let currentPosition = self.sliderWidth.getXPositionWithRespectToCurrentValue(thumbWidthPadding : 4.0)
            self.layoutConstCenterViewCount.constant = CGFloat(currentPosition ?? Float(self.layoutConstCenterViewCount.constant))
            self.lblSliderCount.text = String(format: "%.1f", self.sliderWidth.value)
        }
    
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        bgImageView.addGestureRecognizer(panGesture)
    }
    
    
    @objc func panGesture(_ sender : UIPanGestureRecognizer) {
        
        guard let formatTool = sender.view as? UIImageView else {
            return
        }
        
        //this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
        
        let xFromCenter = sender.translation(in: formatTool).x //positive for right swipe, negative for left
        let yFromCenter = sender.translation(in: formatTool).y //positive for up, negative for down
        
        switch sender.state {
        case .began :
            
            self.superview?.bringSubview(toFront: self)
        
             self.lastCenter = self.center
            
        case .changed :
            
            
            let shapeX = (self.lastCenter!.x + xFromCenter) - self.CViewWidth / 2
            let shapeY = (self.lastCenter!.y + yFromCenter) - self.CViewHeight / 2
            let tempFrame = CGRect(x:shapeX , y: shapeY , width: self.CViewWidth, height: self.CViewHeight)
            
            // Frame contains in Window
            if appDelegate!.window.bounds.contains(tempFrame) {
                
                 self.center = CGPoint(x: self.lastCenter!.x + xFromCenter, y: self.lastCenter!.y + yFromCenter)
            }
            
        case  .ended :
            // Frame contains in Window
            if appDelegate!.window.bounds.contains(formatTool.frame) {
                self.lastCenter = self.center
                appDelegate?.FormatToolFrame = self.frame
            }
                                
            
        default:
            break
        }
        
    }
    
}


extension ShapeFormatTool : SliderDelegate {
    
    func touchesBegan() {
     
        if sliderTouchesEventBlock != nil {
            
            sliderTouchesEventBlock!(.Begin)
        }
    }
    
    func touchesEnded() {
        
        if sliderTouchesEventBlock != nil {
            
            sliderTouchesEventBlock!(.Ended)
        }
    }
}

extension ShapeFormatTool {
    
    func disableShapeFormatToolOption (_ disableOption : shapeToolDisableOption) {
        
        switch disableOption {
            
        case .FillColorDisable:
            self.btnFillColor .setTitleColor(CRGBA(r: 0, g: 0, b: 0, a: 0.3), for: .normal)
            self.btnFillColor.isEnabled = false
            
        case .BorderColorDisable:
            self.btnBorderColor .setTitleColor(CRGBA(r: 0, g: 0, b: 0, a: 0.3), for: .normal)
            self.btnBorderColor.isEnabled = false
            
        default:
            self.btnBorderColor .setTitleColor(ColorBlack, for: .normal)
            self.btnFillColor .setTitleColor(ColorBlack, for: .normal)
            self.btnFillColor.isEnabled = true
            self.btnBorderColor.isEnabled = true
            
        }
    }
}
