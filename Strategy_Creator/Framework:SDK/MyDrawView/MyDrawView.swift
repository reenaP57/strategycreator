//
//  MyDrawView.swift
//  Strategy_Creator
//
//  Created by Mac-00014 on 10/05/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

enum DrawType : Int {
    case Pencil
    case Eraser
}

/// The protocol which the container of MyDrawView can conform to
@objc public protocol MyDrawViewDelegate {
    
    /// triggered when touchs Began
    @objc optional func touchesBegan()
    
    /// triggered when touches Moved
    @objc optional func touchesMoved()
    
    /// triggered when touches Ended
    @objc optional func touchesEnded()
}

/// A subclass of UIView which allows you to draw on the view using your fingers
class MyDrawView: UIView {

    /// Should be set in whichever class is using the MyDrawView
    open weak var delegate: MyDrawViewDelegate?
    
    
    /// Used to register undo and redo actions
    var drawViewUndoManager: UndoManager!
    
    var lastPoint = CGPoint.zero
    
    /// Used to keep track of the current StrokeSettings
    fileprivate var settings: StrokeSettings!
    
    var pencilColor : UIColor!
    var eraserColor : UIColor?
    var pencilWidth : Float!
    var eraserWidth : Float!
    var currrentDrawingType: DrawType!
    var eraserView = UIView()
    
    let imageView = UIImageView()
    var isNeedToTouchesEndedCall = true
    
    
    /// Initializes a MyDrawView instance
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize(frame)
    }
    
    /// Initializes a MyDrawView instance
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize(CGRect.zero)
    }

    /// Adds the subviews and initializes stack
    private func initialize(_ frame: CGRect) {
        
        
        settings = StrokeSettings()
        currrentDrawingType = .Pencil
        pencilColor = UIColor.black
        pencilWidth = 2.0
        
        eraserColor = nil
        eraserWidth = 12
        
        eraserView.backgroundColor = UIColor.white
        eraserView.layer.borderColor = UIColor.black.cgColor
        eraserView.layer.borderWidth = 1.0
        
        addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        
        drawViewUndoManager = undoManager
        if drawViewUndoManager == nil {
            drawViewUndoManager = UndoManager()
        }
        
        // Initially sets the frames of the UIImageView
        draw(frame)


    }
    
    /// Sets the frames of the subviews
    override open func draw(_ rect: CGRect) {
        imageView.frame = rect
    }
    
    /// Sets the brush's color
    open func setColor(_ color: UIColor?) {
        
        if color == nil {
            settings.color = nil
        } else {
            settings.color = CIColor(color: color!)
        }
    }
    
    /// Sets the brush's width
    open func setWidth(_ width: CGFloat) {
        settings.width = width
    }
    
    /// Sets the brush's width and Color
    func setBrushType(_ drawType: DrawType) {
        
        currrentDrawingType = drawType
        
        if drawType == .Pencil {
            setWidth(CGFloat(pencilWidth))
            setColor(pencilColor)
            
        } else {
            setWidth(CGFloat(eraserWidth))
            setColor(eraserColor)
        }
    }
}

// MARK: - Touch Actions

extension MyDrawView {
    
    /// Triggered when touches begin
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let delegate = delegate {
                delegate.touchesBegan!()
        }
        if let touch = touches.first {
            lastPoint = touch.location(in: self)

            if self.currrentDrawingType == .Eraser {

                eraserView.frame = CGRect(x: 0, y: 0, width:settings.width, height: settings.width)
                eraserView.center = lastPoint
                if !self.subviews.contains(eraserView) {
                    self.addSubview(eraserView)
                }
            } else {
                if self.subviews.contains(eraserView) {
                    eraserView.removeFromSuperview()
                }
            }
            
            if isNeedToTouchesEndedCall {
                isNeedToTouchesEndedCall = false
                self.registerUndoDrawing(imageView.image, view: self)
            }
            
        }
        
    }
    /// Triggered when touches move
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let delegate = delegate {
            delegate.touchesMoved!()
        }
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)

            if self.currrentDrawingType == .Eraser {
                    eraserView.center = currentPoint
            }
            isNeedToTouchesEndedCall = true
            drawLineWithContext(fromPoint: lastPoint, toPoint: currentPoint, properties:settings)
            lastPoint = currentPoint
        }
    }

    /// Triggered whenever touches end, resulting in a newly created Stroke
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        
        if let delegate = delegate {
            delegate.touchesEnded!()
            
        }
        
            isNeedToTouchesEndedCall = false
            self.drawLineWithContext(fromPoint: self.lastPoint, toPoint: self.lastPoint, properties:self.settings)
            self.registerUndoDrawing(imageView.image, view: self)
        
    }

    

}


// MARK: - Drawing
fileprivate extension MyDrawView {
    
    /// Begins the image context
    func beginImageContext() {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
    }
    
    /// Ends image context and sets UIImage to what was on the context
    func endImageContext() {
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    /// Draws the current image for context
    func drawCurrentImage() {
        imageView.image?.draw(in: imageView.frame)
    }
    
    /// Draws a line between two points
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint, properties: StrokeSettings) {
        let context = UIGraphicsGetCurrentContext()
        
        context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        context!.setLineWidth(properties.width)
        
        let color = properties.color
        if color != nil {
        
            
            context!.setStrokeColor(red: properties.color!.red,
                                    green: properties.color!.green,
                                    blue: properties.color!.blue,
                                    alpha: properties.color!.alpha)
            context!.setLineCap(.round)
            context!.setBlendMode(.normal)
            context!.setLineJoin(.miter)
            
        } else {
            
            context!.setLineCap(.round)
            context!.setBlendMode(.clear)
            context?.fill(eraserView.frame)

        }
        context!.strokePath()
    }
    
    /// Draws a line between two points (begins/ends context)
    func drawLineWithContext(fromPoint: CGPoint, toPoint: CGPoint, properties: StrokeSettings) {
        beginImageContext()
        drawCurrentImage()
        drawLine(fromPoint: fromPoint, toPoint: toPoint, properties: properties)
        endImageContext()
    }
    
    @objc func registerUndoDrawing(_ image:UIImage?, view: MyDrawView) {
        
        //let oldImage1 = oldImage
        self.drawViewUndoManager.registerUndo(withTarget: self) { (targetSelf) in
            
            targetSelf.registerUndoDrawing(image, view: view)
        }
        self.drawViewUndoManager.setActionName("MyDrawView")
        
        view.imageView.image = image
    }
}
