//
//  CustomSlider.swift
//  Strategy_Creator
//
//  Created by Mac-00014 on 03/05/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit



/// The protocol which the container of Slider can conform to
@objc public protocol SliderDelegate {
  
    /// triggered when touchs Began
    @objc optional func touchesBegan()
    
    /// triggered when touches Moved
    @objc optional func touchesMoved()
    
    /// triggered when touches Ended
    @objc optional func touchesEnded()
}

class CustomSlider : UISlider {
    
    open weak var delegate: SliderDelegate?
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        //keeps original origin and width, changes height, you get the idea
        
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 14))
        
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        self.setThumbImage(#imageLiteral(resourceName: "round_circul"), for: .normal)
        self.value = self.minimumValue
        
        self.setMaximumTrackImage(self.from(color: CRGBA(r: 0, g: 211, b: 246, a: 0.3)), for: .normal)
        self.setMinimumTrackImage(self.from(color: ColorLightBlue), for: .normal)
        super.awakeFromNib()
    }
    
    func getXPositionWithRespectToCurrentValue(thumbWidthPadding : CGFloat) -> Float?
    {
        
        let trackRect = self.trackRect(forBounds: bounds)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)

        if Localization.sharedInstance.getLanguage() == CLanguageArabic {
            return Float((trackRect.width - thumbRect.origin.x) - 28)
        } else {
            return Float(thumbRect.origin.x - thumbWidthPadding)
        }
    }
    
    func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let _ = touches.first {
            
            if let delegate = delegate {
                delegate.touchesBegan?()
            }
            
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if let delegate = delegate {
            delegate.touchesEnded?()
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if let delegate = delegate {
            delegate.touchesMoved?()
        }
    }
}
