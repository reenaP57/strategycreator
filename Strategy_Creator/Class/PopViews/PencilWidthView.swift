//
//  PencilWidthView.swift
//  Strategy_Creator
//
//  Created by Mac-00014 on 03/05/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

class PencilWidthView: UIView {

    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var lblWidth: UILabel!
    @IBOutlet weak var layoutConstCenterViewCount: NSLayoutConstraint!
    @IBOutlet weak var vwWidth: UIView!

    var completionBlock : sliderUpdatedValue?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func updateOrigin(x: CGFloat, y: CGFloat, completion: sliderUpdatedValue?)  {
        
        self.CViewSetX(x: x)
        self.CViewSetY(y: y)
        self.CViewSetWidth(width:296)
        self.CViewSetHeight(height: 155)
        self.completionBlock = completion
        
    }
    
}

extension PencilWidthView {
    
    @IBAction func sliderValueChanged(_ sender: CustomSlider) {
        
        if sender == slider {
            
            let currentPosition = slider.getXPositionWithRespectToCurrentValue(thumbWidthPadding : kCThumbWidthPadding)
            layoutConstCenterViewCount.constant = CGFloat(currentPosition ?? Float(layoutConstCenterViewCount.constant))
            lblWidth.text = String(format: "%.1f", sender.value)
            
            guard let sliderValue = completionBlock else {return}
            sliderValue(sender.value)
            
        }
    }
    
    func sliderPreFillWidth(_ width : Float)  {
        
        slider.value = width
        
        DispatchQueue.main.async {
            let currentPosition = self.slider.getXPositionWithRespectToCurrentValue(thumbWidthPadding : kCThumbWidthPadding)
            self.layoutConstCenterViewCount.constant = CGFloat(currentPosition ?? Float(self.layoutConstCenterViewCount.constant))
            self.lblWidth.text = String(format: "%.1f", self.slider.value)
        }
    }
}
