//
//  DrawShapeView.swift
//  Strategy_Creator
//
//  Created by mac-00017 on 30/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

let txtDefaultWidth = 130
let txtDefaultHeight = 50

enum shapeType : Int {
    case Square
    case RoundedRectangle
    case Triangle
    case Circle
    case Lines
    case Oval
    case ImageView
    case textView
}


typealias textViewBecomeFirstResponder = (DrawShapeView) -> ()


class DrawShapeView: UIView {
    

    var currentShapeType: shapeType = .Square
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    var lastCenter: CGPoint?
    var shapeLayer :CAShapeLayer?
    var borderColor : UIColor?
    var fillColor : UIColor?
    var borderWidth : CGFloat!
    
    // For Image view
    var imageView : UIImageView?
    var imageInfo : [String : Any]?
    
    // For Text View
    var txtView : UITextView?
    var oldText = String()
    var txtHandler : textViewBecomeFirstResponder?
    
    /// Used to register undo and redo actions
    var drawShapeViewUndoManager: UndoManager!
    
    init(frame: CGRect, shape: shapeType) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.fillColor = .white
        self.borderColor = .black
        self.currentShapeType = shape
        width = frame.width
        height = frame.height
        
        switch currentShapeType {
            
        case .Square:            drawSquare()
        case .RoundedRectangle:  drawRoundedRectangle()
        case .Triangle:          drawTriangle()
        case .Circle:            drawCircle()
        case .Lines:             drawLines()
        case .Oval:              drawOval()
        case .ImageView:         drawImageView()
        case .textView:          addTextView()
            
        }
    
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
        
    }
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        switch self.currentShapeType {
            
        case .Circle:
            self.layer.cornerRadius = self.CViewHeight / 2
            
        case .ImageView:
            
            if imageView != nil {
                
                imageView?.CViewSetWidth(width: self.bounds.size.width)
                imageView?.CViewSetHeight(height: self.bounds.size.height)
            }
        case .Lines:
            
            if shapeLayer != nil {
                shapeLayer?.path = self.lineBazierPath()
                shapeLayer?.layoutIfNeeded()
            }
        case .Oval:
            
            if shapeLayer != nil {
             
                shapeLayer?.path = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: self.CViewWidth, height: self.CViewHeight)).cgPath
                shapeLayer?.layoutIfNeeded()
            }
            
        case .Triangle :
            
            if shapeLayer != nil {
                
                shapeLayer?.path = self.triAngleBazierPath()
                shapeLayer?.layoutIfNeeded()
                
            }

            
        default:
            break
        }
        
    }
    
    
    func addPinchGesture(target: Any?, action: Selector?)  {
        
        let pinchGesture = UIPinchGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(pinchGesture)
    }
    
    func addTapGesture(target: Any?, action: Selector?)  {
        
        let singleTapGesture = UITapGestureRecognizer(target: target, action: action)
        singleTapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTapGesture)
        
        //if self.currentShapeType != .ImageView {
        
            let doubleTapGesture = UITapGestureRecognizer(target: target, action: action)
            doubleTapGesture.numberOfTapsRequired = 2
            self.addGestureRecognizer(doubleTapGesture)
            
            singleTapGesture.require(toFail: doubleTapGesture)
        //}
        
    }
    
    func addPanGesture(target: Any?, action: Selector?)  {
        
        let panGesture = UIPanGestureRecognizer(target: target, action: action)
        
        self.addGestureRecognizer(panGesture)
    }
    
    func addRotateGesture(target: Any?, action: Selector?)  {
        
        let rotateGesture = UIRotationGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(rotateGesture)
        
    }
}


//MARK:-
//MARK:- Draw Shape Methods

extension DrawShapeView {
    
    func drawSquare() {
        
        self.backgroundColor = .white
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
        borderWidth = 1.0
    }
    
    func drawRoundedRectangle() {
        self.backgroundColor = .white
        self.layer.borderWidth = 1.0
        //self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
        borderWidth = 1.0
    }
    func drawTriangle() {
        
        shapeLayer = CAShapeLayer()
        
        shapeLayer?.path = self.triAngleBazierPath()
        
        // apply other properties related to the path
        shapeLayer?.strokeColor = UIColor.black.cgColor
        
        shapeLayer?.fillColor = UIColor.white.cgColor
        shapeLayer?.lineWidth = 1.0
        
        // add the new layer to our custom view
        self.layer.addSublayer(shapeLayer!)
        borderWidth = 1.0
        self.backgroundColor = UIColor.clear

    }
    
    
    func drawCircle() {
        
        self.backgroundColor = .white
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.CViewHeight / 2
        borderWidth = 1.0
        
    }
    
    func drawLines() {
        
        shapeLayer = CAShapeLayer()
        
        shapeLayer?.path = self.lineBazierPath()
        
        // apply other properties related to the path
        shapeLayer?.strokeColor = UIColor.black.cgColor
        
        shapeLayer?.fillColor = UIColor.white.cgColor
        shapeLayer?.lineWidth = 5.0
        
        // add the new layer to our custom view
        self.layer.addSublayer(shapeLayer!)
        borderWidth = 5.0
        self.backgroundColor = UIColor.clear
        
    }
    
     func drawOval() {
        
        // Create a CAShapeLayer
        shapeLayer = CAShapeLayer()
        shapeLayer?.path = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 120.0)).cgPath

        // apply other properties related to the path
        shapeLayer?.strokeColor = UIColor.black.cgColor
        shapeLayer?.fillColor = UIColor.white.cgColor
        shapeLayer?.lineWidth = 1.0
        
        // add the new layer to our custom view
        self.layer.addSublayer(shapeLayer!)
        self.CViewSetHeight(height: 120)
        self.CViewSetWidth(width: 200)
        self.width = 200
        self.height = 120
        self.backgroundColor = UIColor.clear
        borderWidth = 1.0
        
     }
    func drawImageView()  {
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageView?.contentMode = .scaleAspectFit
        imageView?.clipsToBounds = true
        self.addSubview(imageView!)
        
    }
    
    func addTextView()  {
        
        txtView = UITextView(frame: CGRect(x: 8, y: 8, width: width - 16, height: height - 8))
        txtView?.textAlignment = .center
        txtView?.placeholder = CTypehere
        txtView?.textColor = UIColor.black
        txtView?.placeholderColor = UIColor.black
        txtView?.placeholderFont = CFontCarterOne(size: 20, type: .Regular)
        txtView?.font = CFontCarterOne(size: 20, type: .Regular)
        
        txtView?.backgroundColor = UIColor.clear
        txtView?.isScrollEnabled = false
        txtView?.autocorrectionType = .no
        txtView?.textContainerInset = .zero
        
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        
        self.addSubview(txtView!)
        borderWidth = 1.0
        borderColor = UIColor.black
        fillColor = UIColor.clear
        txtView?.delegate = self
        self.backgroundColor = UIColor.clear
        
        drawShapeViewUndoManager = undoManager
        if drawShapeViewUndoManager == nil {
            drawShapeViewUndoManager = UndoManager()
        }
        
    }

}
//MARK:-
//MARK:- Helper Method

extension DrawShapeView {
    
    
    func setFillColor(_ color : UIColor )  {
        
        self.fillColor = color
        
        switch self.currentShapeType {
            
        case .Lines :
            
            if self.shapeLayer != nil {
                self.shapeLayer?.strokeColor = color.cgColor
            }
            self.borderColor = color
            
        case .Oval:
            
            if self.shapeLayer != nil {
                self.shapeLayer?.fillColor = color.cgColor
            }
        case .Triangle:
            
            if self.shapeLayer != nil {
                self.shapeLayer?.fillColor = color.cgColor
            }
            
        default:
            self.backgroundColor = color
        }
    }
    
    func setBorderColor(_ color : UIColor , isActive : Bool)  {
        
        
        if !isActive {
            self.borderColor = color
        }
        
        
        switch self.currentShapeType {
            
        case .Lines :
            self.shapeLayer?.strokeColor = color.cgColor
            
        case .Oval:
            self.shapeLayer?.strokeColor = color.cgColor
            
        case .Triangle:
            self.shapeLayer?.strokeColor = color.cgColor
            
        default:
            self.layer.borderColor = color.cgColor
            
            
        }
    }
    
    func setBorderWidth(_ width : Float)  {
        
        self.borderWidth = CGFloat(width)
        
        switch self.currentShapeType {
            
        case .Lines :
            self.shapeLayer?.lineWidth = CGFloat(width)
            
        case .Oval:
            self.shapeLayer?.lineWidth = CGFloat(width)
            
        case .Triangle:
            self.shapeLayer?.lineWidth = CGFloat(width)
            
            
        default:
            self.layer.borderWidth = CGFloat(width)
            
        }
    }
    
    
    func triAngleBazierPath() -> CGPath {
        
        // Create path for drawing a triangle
        let trianglePath = UIBezierPath()
        // First move to the Top point
        trianglePath.move(to: CGPoint(x: self.bounds.width/2, y: 0.0))
        
        // Add line to Bottom Left
        trianglePath.addLine(to: CGPoint(x: 0.0, y: self.bounds.height))
        
        // Add line to Bottom Right
        trianglePath.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        
        // Complete path by close path
        trianglePath.close()
        
        return trianglePath.cgPath
    }
    
    func lineBazierPath() -> CGPath {
        
        // Create path for drawing a line
        let linePath = UIBezierPath()
        // First move to the Top point
        linePath.move(to: CGPoint(x: self.bounds.width, y: 0.0))
        
        // Add line to Bottom Left
        linePath.addLine(to: CGPoint(x: 0.0, y: self.bounds.height))
        
        return linePath.cgPath
    }
    
}

//MARK:-
//MARK:- UndoManager
extension DrawShapeView {
    
    func registerUndoTextViewValueChange(_ textViewText : String?)  {
        
        let oldTextVIew = oldText
        
        drawShapeViewUndoManager.registerUndo(withTarget: self) { (targetSelf) in
            
            self.registerUndoTextViewValueChange(oldTextVIew)
        }
        
        drawShapeViewUndoManager.setActionName("TextViewValueChanged")
    
        self.textViewFrameUpdate(textViewText)
    }
    
    
    func textViewFrameUpdate(_ text : String?) {
        
        txtView?.text = text
        
        if txtView?.text.count ?? 0 > 0 {
            txtView?.placeholder = ""
            self.lastCenter = self.center
        } else {
            
            txtView?.placeholder = CTypehere
            self.frame = CGRect(x: 0, y: 0, width: txtDefaultWidth, height: txtDefaultHeight)
            self.center = self.lastCenter!
            return
        }
        
        
        var rectNeeded = txtView?.text.boundingRect(with: CGSize(width: self.superview!.bounds.width - 40, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: CFontCarterOne(size: 20, type: .Regular)], context: nil)
        
        
        if rectNeeded == nil {
            rectNeeded = CGRect(x: 0, y: 0, width:txtDefaultWidth , height: txtDefaultHeight)
        }
        
        
        var cWidth = CGFloat(txtDefaultWidth)
        var cHeight = CGFloat(txtDefaultHeight)
        
        
        if rectNeeded!.width + 40 > cWidth {
            
            cWidth = rectNeeded!.width + CGFloat(40)
            
            if cWidth > self.superview!.frame.width {
                cWidth = self.superview!.frame.width
            }
        }
        
        let sizeToFitIn =  CGSize(width: cWidth, height: CGFloat(MAXFLOAT))
        let size = txtView?.sizeThatFits(sizeToFitIn) ?? .zero
        
        cHeight = max(size.height, rectNeeded!.height )
        
        cHeight = max(cHeight, CGFloat(txtDefaultHeight))
        
        
        var newFrame = CGRect(x: self.lastCenter!.x - cWidth/2, y: self.lastCenter!.y - cHeight/2, width: cWidth, height: (cHeight > CGFloat(txtDefaultHeight) ? cHeight + 8 : cHeight))
        
        if self.superview!.bounds.contains(newFrame) {
            
            self.frame = newFrame
            txtView?.CViewSetWidth(width:cWidth - 30)
            txtView?.CViewSetHeight(height:cHeight)
            self.center = self.lastCenter!
            self.width = cWidth
            self.height = cHeight
            
        } else{
            
            if newFrame.origin.x < 0 {
                
                newFrame.origin.x = 0
            } else if newFrame.origin.x + newFrame.size.width > self.superview!.bounds.width {
                
                newFrame.origin.x = self.superview!.bounds.width - newFrame.size.width
            }
            
            if newFrame.origin.y < 0 {
                
                newFrame.origin.y = 0
            } else if newFrame.origin.y + newFrame.size.height > self.superview!.bounds.height {
                
                newFrame.origin.y = self.superview!.bounds.height - newFrame.size.height
            }
            
            if self.superview!.bounds.contains(newFrame) {
                
                self.frame = newFrame
                txtView?.CViewSetWidth(width:cWidth - 30)
                txtView?.CViewSetHeight(height:cHeight)
                self.lastCenter! = self.center
                self.width = cWidth
                self.height = cHeight
                
            }
        }
    }
}

//MARK:-
//MARK:- UITextViewDelegate

extension DrawShapeView : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if self.txtHandler != nil {
            self.lastCenter = self.center
            self.txtHandler!(self)
            
        }
        oldText = textView.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.registerUndoTextViewValueChange(textView.text)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        
        self.textViewFrameUpdate(textView.text)
    }
}
