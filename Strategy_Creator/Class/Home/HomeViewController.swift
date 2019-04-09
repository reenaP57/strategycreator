//
//  HomeViewController.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 19/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit


let kCThumbWidthPadding : CGFloat = 14.0
let kCTopPadding : CGFloat = 60.0

class HomeViewController: ParentViewController {
    
    var arrMenuOptions =  [["name": CNewFile,    "image" : "new_file"],
                           ["name": CShapes,     "image" : "shapes"],
                           ["name": CEraser,     "image" : "eraser"],
                           ["name": CColorPad,   "image" : "colorpad"],
                           ["name": CPencil,     "image" : "pensil"],
                           ["name": CText,       "image" : "text"],
                           ["name": CImage,      "image" : "image"],
                           ["name": CChangeBg,   "image" : "change_bg"]]
    
    var activeShapeView : DrawShapeView?
    var selectedShapeIndexpath : IndexPath?

    @IBOutlet  var vwCanvas: GenericView!
    @IBOutlet  var imgVBg: UIImageView!
    
    @IBOutlet weak var btnDelete: GenericButton! {
        didSet {
            btnDelete.isHidden = true
        }
    }
    
    var scratchDrawView: MyDrawView!
    var pencilColor : UIColor? = UIColor.black
    
    var undoRedoManager = UndoManager()
    var isUndoManagerGroupingBegin = false
    //Side menu
    @IBOutlet weak var tblMenu: UITableView!
        {
        didSet{
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerViewConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func initialize(){
        
        if Localization.sharedInstance.getLanguage() == CLanguageArabic {
                imgVBg.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
        self.tblMenu.reloadData()
        self.tblMenu.tableFooterView = UIView(frame: CGRect.zero)
    
        // Add Scratch pad
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            self.addScratchPad()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureShapeView))
        tapGesture.numberOfTapsRequired = 1
        vwCanvas.addGestureRecognizer(tapGesture)
    }
    
    
}




//MARK: - Tableview datasource and delegate
extension HomeViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenuOptions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MenuOptionsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuOptionsTableViewCell
        
        let dictIndex = arrMenuOptions[indexPath.row]
        cell.lblMenu.text = dictIndex["name"]
        cell.imgMenu.image = UIImage(named: dictIndex["image"]!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Remove format tool
        self.removeAllToolsPicker()
        
        let strOptionSelected = (arrMenuOptions[indexPath.row])["name"]
        
        switch strOptionSelected {
            
        case CNewFile?:
            
            var isEditable : Bool = false
            
            if self.vwCanvas.subviews.count > 1 {
               isEditable = true
            } else {
                for subView in (self.vwCanvas.subviews) {
                    if let view = subView as? MyDrawView {
                        
                        if view.imageView.image == nil {
                            isEditable = false
                        } else {
                            isEditable = true
                        }
                    }
                }
            }
            
            
            if !(self.vwCanvas.backgroundColor?.isEqual(UIColor.white))! || isEditable {
                
                DispatchQueue.main.async {
                    
                    self.presentAlertViewWithThreeButtons(alertTitle: "", alertMessage: CNewFileAlertMessage, btnOneTitle: CSave, btnOneTapped: { (action) in
                        
                        self.scratchDrawView.eraserView.removeFromSuperview()
                        if let image = self.vwCanvas.snapshotImage {
                            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        }
                        
                        self.addNewPage()
                        
                    }, btnTwoTitle: CDontSave, btnTwoTapped: { (action) in
                        self.addNewPage()
                    }, btnThreeTitle: CCancel, btnThreeTapped: { (action) in
                        
                    })
                }
            }
            
            
        case CShapes?:
            
            self.scratchDrawView.eraserView.removeFromSuperview()
            // Open shape Picker
            self.openShapePicker({ (selectedShapeType, selectedIndexpath) in
                
                self.selectedShapeIndexpath = selectedIndexpath
                
                if selectedShapeType != nil {
                    self.drawShape(shapeType:selectedShapeType!)
                }
                
                // hide pencil drawing
                self.scratchDrawView.setWidth(0.0)
                
            })
            
        case CEraser?:
            
            self.scratchDrawView.setBrushType(.Eraser)
            
            let rectOfCell = tableView.rectForRow(at: indexPath)
            let rectOfCellInSuperview = tableView.convert(rectOfCell, to: tableView.superview)
            
            self.openPencilWidthPicker(CGPoint(x:tblMenu.CViewWidth , y: rectOfCellInSuperview.origin.y - 25), width: Float(self.scratchDrawView.eraserWidth), maxValue: 50, minValue: 10, complitionHandler: { (sliderValue) in
                
                self.scratchDrawView.setWidth(CGFloat(sliderValue))
                self.scratchDrawView.eraserWidth = sliderValue
                
            })
            
            break
            
        case CColorPad?:
            
            self.scratchDrawView.eraserView.removeFromSuperview()
            self.openColorPicker(frame:CGPoint(x: vwCanvas.CViewWidth - 230, y: vwCanvas.CViewY + 150) , tag: 0, completion: { (color) in
                
                if self.activeShapeView?.currentShapeType == .textView {
                       self.registerUndoTextFontColor(color, view: self.activeShapeView!)
                }
                
                if self.scratchDrawView.currrentDrawingType == .Pencil {
                    
                    self.scratchDrawView.setColor(color)
                    self.scratchDrawView.pencilColor = color
                }
                
            })
            
            
        case CPencil?:
            
            self.scratchDrawView.eraserView.removeFromSuperview()
            self.scratchDrawView.setBrushType(.Pencil)
            
            let rectOfCell = tableView.rectForRow(at: indexPath)
            let rectOfCellInSuperview = tableView.convert(rectOfCell, to: tableView.superview)
            
       
            self.openPencilWidthPicker(CGPoint(x:tblMenu.CViewWidth , y: rectOfCellInSuperview.origin.y - 25), width: Float(self.scratchDrawView.pencilWidth / 2.0), maxValue: 5, minValue: 1 , complitionHandler: { (sliderValue) in
                
                self.scratchDrawView.setWidth(CGFloat(sliderValue * 2))
                self.scratchDrawView.pencilWidth = sliderValue * 2
//                self.scratchDrawView.setColor(self.pencilColor)
//                self.scratchDrawView.pencilColor = self.pencilColor
            })
            
            
            
        case CText?:
            self.scratchDrawView.eraserView.removeFromSuperview()
            self.addTextView()
            self.scratchDrawView.setWidth(0.0)
            
        case CImage?:
            
            self.scratchDrawView.eraserView.removeFromSuperview()
            
            // Open Image Picker
            self.openImagePicker({ (image, data) in
                
                if image != nil {
                    
                    self.drawShapeImageView(shapeType: .ImageView, image: image, data: data)
                }
                
                // hide pencil drawing
                self.scratchDrawView.setWidth(0.0)
            })
            
            
        case CChangeBg?:
            
            self.openColorPicker(frame:CGPoint(x: vwCanvas.CViewWidth - 230, y: vwCanvas.CViewY + 150) , tag: 0, completion: { (color) in
                
                self.registerUndoChangeBackgroundColor(color, view: self.vwCanvas)
                
            })
            
        default:
            break
        }
        
        
    }
}

//MARK: -
//MARK: - Menu Functions

extension HomeViewController {
    
    func addNewPage() {
        
       
        self.undoRedoManager = UndoManager()
        vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
        vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
        vwHeader?.btnSave.isEnabled = false
        vwHeader?.btnShare.isEnabled = false
        
        UIView.animate(withDuration: 1.0, animations: {
            
            let animation = CATransition()
            animation.duration = 1.2
            animation.startProgress = 0.0
            animation.endProgress = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.type = "pageCurl"
            animation.subtype = "fromBottom"
            animation.isRemovedOnCompletion = false
            animation.fillMode = "extended"
            self.vwCanvas.removeAllSubviews()
            self.vwCanvas.layer.add(animation, forKey: "pageFlipAnimation")
            self.undoRedoManager.removeAllActions()
            self.vwCanvas.backgroundColor = UIColor.white
            
        }) { (complete) in
            
            self.addScratchPad()
        }
    }
    
    func addScratchPad() {
        self.scratchDrawView = MyDrawView(frame: CGRect(x: 0, y: 0, width: self.vwCanvas.CViewWidth, height: self.vwCanvas.CViewHeight))
        self.vwCanvas.addSubview(self.scratchDrawView)
        self.scratchDrawView.setBrushType(.Pencil)
        self.scratchDrawView?.backgroundColor = UIColor.clear
        self.scratchDrawView.delegate = self
        self.scratchDrawView.drawViewUndoManager = self.undoRedoManager
    }
    
}
//MARK: -
//MARK: - Shape Draw Function

extension HomeViewController {
    
    func drawShape(shapeType : shapeType) {
        
        var frame : CGRect!
        
        switch shapeType {
            
        case .Lines:
            frame  = CGRect(x: 0, y: 0, width:300, height: 50)
            
        case .RoundedRectangle:
            frame  = CGRect(x: 0, y: 0, width:200, height: 130)
            
        case .Triangle:
            
            frame  = CGRect(x: 0, y: 0, width:200, height: 105)
            
        default:
            frame  = CGRect(x: 0, y: 0, width:150, height: 150)
        
        }
        
        
        let shapeVW = DrawShapeView(frame:frame, shape: shapeType)
        
        self.registerUndoAddSubview(shapeVW, canvas: vwCanvas)
        shapeVW.center = vwCanvas.center
        
        shapeVW.addPinchGesture(target: self, action: #selector(self.pinchGestureShapeView(_:)))
        shapeVW.addTapGesture(target: self, action: #selector(self.tapGestureShapeView(_:)))
        shapeVW.addPanGesture(target: self, action: #selector(self.panGestureShapeView(_:)))
        shapeVW.addRotateGesture(target: self, action: #selector(self.rotateGestureShapeView(_:)))
        
        super.vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
        super.vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
        super.vwHeader?.btnSave.isEnabled = true
        super.vwHeader?.btnShare.isEnabled = true
        
        
        if activeShapeView != nil {
            activeShapeView?.setBorderColor((activeShapeView?.borderColor)!, isActive: false)
            
            if activeShapeView?.currentShapeType == .textView && activeShapeView?.txtView != nil {
                
                activeShapeView?.txtView?.resignFirstResponder()
                activeShapeView?.setBorderWidth(0)
            }
            
        }
        
        activeShapeView = shapeVW
        activeShapeView?.setBorderColor(UIColor.blue, isActive: true)
        btnDelete.isHidden = false
        
        
        
        
    }
    
    // Draw image view
    func drawShapeImageView(shapeType : shapeType, image : UIImage?, data :[String : Any]? ) {
        
        var cHeight : CGFloat!
        var cWidth : CGFloat!
        
        if image!.size.width > image!.size.height {
            cWidth = 200
            cHeight = (image!.size.height / image!.size.width) * cWidth
            
        } else if image!.size.height > image!.size.width {
            
            cHeight = 200
            cWidth  = (image!.size.width / image!.size.height) * cHeight
            
        } else {
            
            cWidth = 200
            cHeight = 200
        }
        
        let frame  = CGRect(x: 0, y: 0, width:cWidth, height: cHeight)
        let shapeVW = DrawShapeView(frame:frame, shape: shapeType)
        shapeVW.imageView?.image = image
        shapeVW.imageInfo = data
        
        
        self.registerUndoAddSubview(shapeVW, canvas: vwCanvas)
        shapeVW.center = vwCanvas.center
        shapeVW.layer.borderWidth = 1.0
        
        shapeVW.addPinchGesture(target: self, action: #selector(self.pinchGestureShapeView(_:)))
        shapeVW.addTapGesture(target: self, action: #selector(self.tapGestureShapeView(_:)))
        shapeVW.addPanGesture(target: self, action: #selector(self.panGestureShapeView(_:)))
        shapeVW.addRotateGesture(target: self, action: #selector(self.rotateGestureShapeView(_:)))
        
        super.vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
        super.vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
        super.vwHeader?.btnSave.isEnabled = true
        super.vwHeader?.btnShare.isEnabled = true
        
        
        if activeShapeView != nil {
            activeShapeView?.setBorderColor((activeShapeView?.borderColor)!, isActive: false)
            
            if activeShapeView?.currentShapeType == .textView && activeShapeView?.txtView != nil {
                
                activeShapeView?.txtView?.resignFirstResponder()
                activeShapeView?.setBorderWidth(0)
            }
            
        }
        
        activeShapeView = shapeVW
        activeShapeView?.setBorderColor(UIColor.blue, isActive: true)
        btnDelete.isHidden = false
        
        
    }
    
    
    func addTextView() {
        
        let frame  = CGRect(x:(Int(vwCanvas.center.x - CGFloat(txtDefaultWidth / 2))) , y: 16, width:txtDefaultWidth, height: txtDefaultHeight)
        
        let shapeVW = DrawShapeView(frame:frame, shape: .textView)
        
        self.registerUndoAddSubview(shapeVW, canvas: vwCanvas)
        
        shapeVW.addTapGesture(target: self, action: #selector(self.tapGestureShapeView(_:)))
        shapeVW.addPanGesture(target: self, action: #selector(self.panGestureShapeView(_:)))
        shapeVW.addRotateGesture(target: self, action: #selector(self.rotateGestureShapeView(_:)))
        
        shapeVW.txtHandler = {(activeShapeVW) -> () in
            
            self.removeAllToolsPicker()
            
            if self.activeShapeView != nil && self.activeShapeView != shapeVW {
               self.activeShapeView?.setBorderColor((self.activeShapeView?.borderColor)!, isActive: false)
                self.btnDelete.isHidden = true
                
                if self.activeShapeView?.currentShapeType == .textView && self.activeShapeView?.txtView != nil {
                    
                    self.activeShapeView?.txtView?.resignFirstResponder()
                    self.activeShapeView?.setBorderWidth(0)
                }
                
            }
            
            self.activeShapeView = activeShapeVW
            self.activeShapeView?.setBorderWidth(2.0)
            self.activeShapeView?.setBorderColor(UIColor.blue, isActive: true)
            self.btnDelete.isHidden = false
        }
        
        shapeVW.drawShapeViewUndoManager = undoRedoManager
        
        super.vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
        super.vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
        super.vwHeader?.btnSave.isEnabled = true
        super.vwHeader?.btnShare.isEnabled = true
        
        
        if activeShapeView != nil {
            activeShapeView?.setBorderColor((activeShapeView?.borderColor)!, isActive: false)
            
            if activeShapeView?.currentShapeType == .textView && activeShapeView?.txtView != nil {
                
                activeShapeView?.txtView?.resignFirstResponder()
                activeShapeView?.setBorderWidth(0)
            }
            
        }
        
        activeShapeView = shapeVW
        activeShapeView?.setBorderColor(UIColor.blue, isActive: true)
        btnDelete.isHidden = false
        
    }
    
    
    // Pinch Gesture
    @objc func pinchGestureShapeView(_ sender : UIPinchGestureRecognizer) {
        
        guard let shapeView = sender.view as? DrawShapeView else {
            return
        }
        
        switch sender.state {
        case .began :
            
            shapeView.lastCenter = shapeView.center
            shapeView.width = shapeView.bounds.size.width
            shapeView.height = shapeView.bounds.size.height
            
            self.undoRedoManager.beginUndoGrouping()
            
        case .changed :
            
            
            
            let newWidth = shapeView.width * sender.scale
            var newHeight = shapeView.height * sender.scale
            
            if shapeView.currentShapeType == .Lines {
                newHeight = shapeView.height
            }
            let newX = (shapeView.lastCenter?.x)! - (newWidth / 2)
            let newY = (shapeView.lastCenter?.y)! - (newHeight / 2)
            
            let newFrame = CGRect(x:newX , y: newY , width: newWidth, height: newHeight)
            
            
            let temp = UIView(frame: newFrame)
            temp.transform = shapeView.transform
            
            // Frame contains in Canvas
           // if vwCanvas.bounds.contains(temp.frame) {
                self.registerUndoPinchGesture(temp, view: shapeView)
            //}
            
            
        case  .ended :
            
            shapeView.height = shapeView.bounds.size.height
            shapeView.width = shapeView.bounds.size.width
            shapeView.lastCenter  = shapeView.center
            self.undoRedoManager.endUndoGrouping()
            vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
            vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
            
            
        default:
            
            break
        }
        
    }
    
    @objc func tapGestureShapeView(_ sender : UITapGestureRecognizer) {
        
        // For canvas tap gesture
        if sender.view == vwCanvas {
            
            // Remove if already added  all tools in Window
            self.removeAllToolsPicker()
            
            if activeShapeView != nil {
                activeShapeView?.setBorderColor((activeShapeView?.borderColor)!, isActive: false)
                btnDelete.isHidden = true
                
                if activeShapeView?.currentShapeType == .textView && activeShapeView?.txtView != nil {
                    
                    activeShapeView?.txtView?.resignFirstResponder()
                    activeShapeView?.setBorderWidth(0)
                }
                
            }
            return
        }
        
        
        guard let shapeView = sender.view as? DrawShapeView else {
            return
        }
        // Single Tap
        
        if sender.numberOfTapsRequired == 1 {
            
            switch sender.state {
            case .ended :
                
                if activeShapeView != nil {
                    activeShapeView?.setBorderColor((activeShapeView?.borderColor)!, isActive: false)
                    
                    if activeShapeView?.currentShapeType == .textView && activeShapeView?.txtView != nil {
                        
                        activeShapeView?.txtView?.resignFirstResponder()
                        activeShapeView?.setBorderWidth(0)
                    }
                    
                }
               
                btnDelete.isHidden = false
                activeShapeView = shapeView
                activeShapeView?.setBorderColor(UIColor.blue, isActive: true)
                removeAllToolsPicker()
                
            default:
                break
            }
            
            
        } else if sender.numberOfTapsRequired == 2 {
            
            // Double Tap
            
            switch sender.state {
                
                
            case .ended :
                
                if activeShapeView?.currentShapeType != .textView {
                    
                    // Open format tool
                    self.openFormatTool(shapeView)
                }
                
                
                
            default:
                break
            }
        }
        
    }
    
    @objc func panGestureShapeView(_ sender : UIPanGestureRecognizer) {
        
        guard let shapeView = sender.view as? DrawShapeView else {
            return
        }
        
        //this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
        
        let xFromCenter = sender.translation(in: shapeView.superview).x //positive for right swipe, negative for left
        
        let yFromCenter = sender.translation(in: shapeView.superview).y //positive for up, negative for down
        
        
        switch sender.state {
        case .began :
            
            shapeView.superview?.bringSubview(toFront: shapeView)
            shapeView.lastCenter = shapeView.center
            shapeView.width = shapeView.CViewWidth
            shapeView.height = shapeView.CViewHeight
            self.undoRedoManager.beginUndoGrouping()
            
            
        case .changed :
            
            
            let origin = CGPoint(
                
                x: (shapeView.lastCenter?.x)! - (shapeView.width / 2)  + xFromCenter,
                y: (shapeView.lastCenter?.y)! - (shapeView.height / 2) + yFromCenter
            )
            
            
            let newFrame = CGRect(x:origin.x , y: origin.y , width: shapeView.width, height: shapeView.height)
            let temp = UIView(frame: newFrame)
            
              // Frame contains in Canvas
           // if vwCanvas.bounds.contains(newFrame) {
                
                self.registerUndoPanGesture(temp.center, view: shapeView)
//            }
            
            
        case  .ended :
            
            
            // Frame contains in Canvas
          //  if vwCanvas.bounds.contains(shapeView.frame) {
                shapeView.lastCenter = shapeView.center
            //}
            self.undoRedoManager.endUndoGrouping()
            vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
            vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
            
        default:
            break
        }
        
    }
    
    @objc func rotateGestureShapeView(_ sender : UIRotationGestureRecognizer) {
        
        guard let shapeView = sender.view as? DrawShapeView else {
            return
        }
        
        switch sender.state {
        case .began :
            
            self.undoRedoManager.beginUndoGrouping()
            
        case .changed :
            
            
            let viewTemp = UIView()
            viewTemp.bounds = shapeView.bounds
            viewTemp.center = shapeView.center
            viewTemp.transform = shapeView.transform
            viewTemp.transform = shapeView.transform.rotated(by: sender.rotation)
            
          //  if vwCanvas.frame.contains(viewTemp.frame) {
                
                self.registerUndoRotationGesture(shapeView.transform.rotated(by: sender.rotation), view: shapeView)
                
            //}
            sender.rotation = 0
            
            
            
        case  .ended :
            
            shapeView.width =  shapeView.CViewWidth
            shapeView.height = shapeView.CViewHeight
            shapeView.lastCenter = shapeView.center
            
            self.undoRedoManager.endUndoGrouping()
            vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
            vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
            
        default:
            
            break
        }
    }
    
}

//MARK: -
//MARK: - Action Event

extension HomeViewController {
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        
        if activeShapeView != nil {
            
            self.presentAlertViewWithTwoButtons(alertTitle: "", alertMessage: CDeleteShape, btnOneTitle: CNo, btnOneTapped: { (action) in
                
            }, btnTwoTitle: CYes, btnTwoTapped: { (action) in
                
                self.registerUndoDelete(self.activeShapeView!,  canvas: self.vwCanvas)
                self.activeShapeView = nil
                self.btnDelete.isHidden = true
         
                for subView in (appDelegate?.window.subviews)! {
                    if let view = subView as? ShapeFormatTool {
                        view.removeFromSuperview()
                    }
                }
                
            })
        }
    }
}


//MARK: -
//MARK: - MyDrawViewDelegate

extension HomeViewController : MyDrawViewDelegate {
    
    
    /// triggered when touchs Began
    func touchesBegan() {
        
        self.removeAllToolsPicker()
        if activeShapeView?.currentShapeType == .textView && activeShapeView?.txtView != nil {
            
            activeShapeView?.txtView?.resignFirstResponder()
            activeShapeView?.setBorderWidth(0)
        }
        super.vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
        super.vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
        super.vwHeader?.btnSave.isEnabled = true
        super.vwHeader?.btnShare.isEnabled = true
    }
    
    /// triggered when touches Moved
    func touchesMoved() {
        
    }
    
    /// triggered when touches Ended
    func touchesEnded() {
        
        super.vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
        super.vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
    }
    
}

//MARK:-
//MARK:- Save and Share Image

extension HomeViewController {
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            self.presentAlertViewWithOneButton(alertTitle: CSaveError, alertMessage: error.localizedDescription, btnOneTitle: COk, btnOneTapped: { (action) in
                
            })
        } else {
            
            for subView in (appDelegate?.window.subviews)! {
                
                if let view = subView as? HomePreviewView {
                    view.removeFromSuperview()
                    
                    self.presentAlertViewWithOneButton(alertTitle: "", alertMessage: CSavedSuccessfully, btnOneTitle: COk, btnOneTapped: { (action) in
                    })
                }
            }
        }
    }
    
    func sharePreviewImage(sender : UIButton) {
        
        //let shareText = "Strategy Creator"
        let shareImg = vwCanvas.snapshotImage
        
        let activityVC = UIActivityViewController(activityItems: [shareImg as Any], applicationActivities: nil)
        // activityVC.excludedActivityTypes = []
        
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.popoverPresentationController?.sourceRect = sender.frame
        
        self.present(activityVC, animated: true, completion: nil)
        
    }
}


//MARK: -
//MARK: - Pencil Width Picker

extension HomeViewController {
    
    func openPencilWidthPicker(_ origin : CGPoint, width:Float, maxValue:Float, minValue:Float, complitionHandler: sliderUpdatedValue?)  {
        
        if let pencilWidhtPicker = PencilWidthView.viewFromXib as? PencilWidthView {
            
            var cX : CGFloat = 0
            if Localization.sharedInstance.getLanguage() == CLanguageArabic {
                cX = vwCanvas.CViewWidth - (pencilWidhtPicker.CViewWidth - 45)
            } else {
                cX = origin.x
            }
            

            pencilWidhtPicker.updateOrigin(x:cX, y: origin.y, completion:complitionHandler)
            pencilWidhtPicker.slider.maximumValue = maxValue
            pencilWidhtPicker.slider.minimumValue = minValue
            pencilWidhtPicker.sliderPreFillWidth(width)
            
            if width == 1.0 {
                pencilWidhtPicker.layoutConstCenterViewCount.constant = -16
            }
            
            self.view.addSubview(pencilWidhtPicker)
        }
    }
    
}

//MARK:-
//MARK:- Shape Picker

extension HomeViewController {
    
    func openShapePicker(_ complitionHandler : selectShapeHandler?)  {
        
        if let shapesVW  = shapeView.viewFromXib as? shapeView {
            
            shapesVW.selectedIndexPath = selectedShapeIndexpath
            var cX : CGFloat = 0
            
            if Localization.sharedInstance.getLanguage() == CLanguageArabic {
                cX = vwCanvas.CViewWidth - 300
                shapesVW.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            } else {
                cX = tblMenu.CViewWidth
            }
            
            
            let cY = vwCanvas.superview!.CViewY + 10
            let frame = CGRect(x: cX, y: cY, width: 345, height: vwCanvas.CViewHeight)
            shapesVW.updateOrigin(frame:frame, completion: complitionHandler)
            self.view.addSubview(shapesVW)
        }
    }
}

//MARK:-
//MARK:- Image Picker

extension HomeViewController {
    
    func openImagePicker(_ complitionHandler : selectImageHandler?)  {
        
        if let imagePicker = SelectImageView.viewFromXib as? SelectImageView {
            
            var cX : CGFloat = 0
            
            if Localization.sharedInstance.getLanguage() == CLanguageArabic {
                cX = vwCanvas.CViewWidth - 200
                imagePicker.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            } else {
                cX = tblMenu.CViewWidth
            }
            
            imagePicker.updateOrigin(x:cX, y: (CScreenHeight - imagePicker.CViewHeight - kCTopPadding)  , completion:complitionHandler)
            self.view.addSubview(imagePicker)
        }
        
    }
}


//MARK:-
//MARK:- Shape Format Tool

extension HomeViewController {
    
    
    func openFormatTool(_ shapeView : DrawShapeView)  {
        
        // Remove if already added a shapeFormatTool in Window
        self.removeFormatTool()
        
        if let formatTool = ShapeFormatTool.viewFromXib as? ShapeFormatTool {
            formatTool.CViewSetOrigin(x: CScreenCenter.x, y: CScreenCenter.y)
            
            switch shapeView.currentShapeType {
            case .Lines :
                formatTool.disableShapeFormatToolOption(.BorderColorDisable)
                
            case .ImageView :
                formatTool.disableShapeFormatToolOption(.FillColorDisable)
                
            default :
                formatTool.disableShapeFormatToolOption(.AllEnable)
                
            }
    
            
            appDelegate?.window.addSubview(formatTool)
            if shapeView.borderWidth != nil {
                
                formatTool.sliderPreFillWidth(Float(shapeView.borderWidth))
            }
            
            
            if appDelegate?.FormatToolFrame != nil {
                formatTool.frame = appDelegate!.FormatToolFrame!
            } else {
                appDelegate!.FormatToolFrame = formatTool.frame
            }
            
            formatTool.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            UIView.animate(withDuration: 0.1) {
                formatTool.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            //... Set slider border width
            formatTool.completionBlock = {(width) -> () in
                
                
                self.registerUndoChangeBorderWidth(width < 1.0 ? 0.0 : width , view: shapeView)
            }
            
            formatTool.sliderTouchesEventBlock = { (event) -> () in
                
                if event == .Begin {
                    if self.isUndoManagerGroupingBegin {
                        self.undoRedoManager.endUndoGrouping()
                        self.isUndoManagerGroupingBegin = false
                        super.vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
                        super.vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
                    }
                    self.undoRedoManager.beginUndoGrouping()
                    self.isUndoManagerGroupingBegin = true
                }
                
                if event == .Ended {
                    self.undoRedoManager.endUndoGrouping()
                    self.isUndoManagerGroupingBegin = false
                    super.vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
                    super.vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
                }
            }
            
            //... set Fill Color of shape
            
            formatTool.btnFillColor.touchUpInside(genericTouchUpInsideHandler: { (sender) in
                
                let point = CGPoint(x: sender.frame.midX - 115, y: sender.frame.minY - 50)
                self.openColorPicker(frame: point, tag: 1, completion: { (color) in
                    
                    self.registerUndoChangeFillColor(color, view: shapeView)
                })
                
            })
            //... set Border Color of shape
            formatTool.btnBorderColor.touchUpInside(genericTouchUpInsideHandler: { (sender) in
                let point = CGPoint(x: sender.frame.midX - 115, y: sender.frame.minY - 50)
                
                self.openColorPicker(frame: point, tag: 0, completion: { (color) in
                    
                    self.registerUndoChangeBorderColor(color, view: shapeView)
                    
                })
            })
        }
    }
}
//MARK:-
//MARK:- Color Picker

extension HomeViewController {
    
    func openColorPicker (frame : CGPoint, tag : Int,  completion: (( _ color: UIColor) -> Void)?) {
        
        let rappleColorPicker = RappleColorPicker.sharedInstance
        
        if rappleColorPicker.background != nil {
            RappleColorPicker.close()
        }
        
        let attributes : [RappleCPAttributeKey : AnyObject] = [
            .BGColor : UIColor.white,
            .TintColor : UIColor.clear,
            .Style : RappleCPStyleCircle as AnyObject,
            .BorderColor : ColorBlue,
            .ScreenBGColor : UIColor.clear
        ]
        
        RappleColorPicker.openColorPallet(onViewController: self, origin: frame, attributes: attributes) { (color, _) in
            
            if completion != nil {
                completion!(color)
                self.pencilColor = color
            }
            RappleColorPicker.close()
        }
    }
}


//MARK:-
//MARK:-  Preview View

extension HomeViewController {
    
    fileprivate func headerViewConfiguration()  {
        
        vwHeader?.lblTitle.text = CStrategyCreator
        
        //... Headerview action
        vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
        vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
        vwHeader?.btnSave.isEnabled = false
        vwHeader?.btnShare.isEnabled = false
        
        vwHeader?.btnShare.touchUpInside(genericTouchUpInsideHandler: { (sender) in
            
            self.previewViewConfiguration()
        })
        
        vwHeader?.btnSave.touchUpInside(genericTouchUpInsideHandler: { (sender) in
            
            self.previewViewConfiguration()
            
        })
        
        vwHeader?.btnUndo.touchUpInside(genericTouchUpInsideHandler: { (sender) in
            
            // Remove format tool
            self.removeAllToolsPicker()
            
            if self.undoRedoManager.canUndo {
                self.undoRedoManager.undo()
            }
            
            
            super.vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
            super.vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
            
            
        })
        vwHeader?.btnRedo.touchUpInside(genericTouchUpInsideHandler: { (sender) in
            
            // Remove format tool
            self.removeAllToolsPicker()
            
            if self.undoRedoManager.canRedo {
                self.undoRedoManager.redo()
            }
            
            super.vwHeader?.btnRedo.isEnabled = self.undoRedoManager.canRedo
            super.vwHeader?.btnUndo.isEnabled = self.undoRedoManager.canUndo
            
        })
        
    }
    
    fileprivate func previewViewConfiguration() {
        
        if activeShapeView != nil {
            activeShapeView?.setBorderColor((activeShapeView?.borderColor)!, isActive: false)
            btnDelete.isHidden = true
            
            if activeShapeView?.currentShapeType == .textView && activeShapeView?.txtView != nil {
                
                activeShapeView?.txtView?.resignFirstResponder()
                activeShapeView?.setBorderWidth(0)
            }
            
        }
        
      
        if self.vwCanvas.subviews.count > 1 {
            
            for subView in self.vwCanvas.subviews {
                
                if let view = subView as? DrawShapeView {
                   
                    if view.currentShapeType == .textView {
                        view.setBorderWidth(0)
                    }
                }
            }
        }
        
        
        self.scratchDrawView.eraserView.removeFromSuperview()
        
        if let previewView = HomePreviewView.viewFromXib as? HomePreviewView {
            
            previewView.CViewSetSize(width: CScreenWidth, height: CScreenHeight)
            
            previewView.imgVPreview.image = vwCanvas.snapshotImage
            
            appDelegate?.window.addSubview(previewView)
            
            previewView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            UIView.animate(withDuration: 0.1) {
                previewView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            
            previewView.btnSave.touchUpInside(genericTouchUpInsideHandler: { (btnSave) in
            
                UIImageWriteToSavedPhotosAlbum(previewView.imgVPreview.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            })
            
            previewView.btnShare.touchUpInside(genericTouchUpInsideHandler: { (btnShare) in
                previewView.removeFromSuperview()
                
                self.sharePreviewImage(sender: previewView.btnShare)
            })
            
            previewView.btnClose.touchUpInside(genericTouchUpInsideHandler: { (btnClose) in
                previewView.removeFromSuperview()
            })
        }
        
    }
    
}
//MARK:-
//MARK:-  Register UndoManager

extension HomeViewController {
    
    
    @objc func registerUndoPanGesture(_ newCenter:CGPoint, view: DrawShapeView) {
        
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            targetSelf.registerUndoPanGesture(newCenter, view: view)
        }
        
        self.undoRedoManager.setActionName("Move")        
        view.center = newCenter
        
    }
    
    @objc func registerUndoPinchGesture(_ newFrameView:UIView, view: DrawShapeView) {
        
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            targetSelf.registerUndoPinchGesture(newFrameView, view: view)
        }
        
        self.undoRedoManager.setActionName("Pinch")
        view.bounds = newFrameView.bounds
        view.center = newFrameView.center
        
    }
    
    @objc func registerUndoRotationGesture(_ rotation:CGAffineTransform, view: DrawShapeView) {
        
        let lastTransform = view.transform
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            targetSelf.registerUndoRotationGesture(lastTransform, view: view)
        }
        
        self.undoRedoManager.setActionName("Rotation")
        view.transform = rotation
    }
    
    @objc func registerUndoChangeBackgroundColor(_ color:UIColor, view: UIView) {
        
        let oldColor = view.backgroundColor ?? UIColor.white
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            targetSelf.registerUndoChangeBackgroundColor(oldColor, view: view)
        }
        
        self.undoRedoManager.setActionName("ChangeBG")
        view.backgroundColor = color
    }
    
    @objc func registerUndoChangeFillColor(_ color:UIColor, view: DrawShapeView) {
        
        let oldColor = view.fillColor
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            targetSelf.registerUndoChangeFillColor(oldColor!, view: view)
        }
        
        self.undoRedoManager.setActionName("ChangeFillColor")
        view.setFillColor(color)
    }
    
    @objc func registerUndoChangeBorderColor(_ color:UIColor, view: DrawShapeView) {
        
        let oldColor = view.borderColor
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            targetSelf.registerUndoChangeBorderColor(oldColor!, view: view)
        }
        
        self.undoRedoManager.setActionName("ChangeBorderColor")
        view.setBorderColor(color, isActive: false)
    }
    
    @objc func registerUndoDelete(_ view: DrawShapeView, canvas : UIView) {
        
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            
            targetSelf.registerUndoDelete(view, canvas: canvas)
        }
        
        self.undoRedoManager.setActionName("Delete")
        
        if self.undoRedoManager.isUndoing  {
            canvas.addSubview(view)
            
        } else {
            
            view.removeFromSuperview()
        }
    }
    
    @objc func registerUndoChangeBorderWidth(_ width : Float, view: DrawShapeView) {
        
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            targetSelf.registerUndoChangeBorderWidth(width, view: view)
        }
        
        
        self.undoRedoManager.setActionName("ChangeBorderWidht")
        view.setBorderWidth(width)
        
        
    }
    
    @objc func registerUndoTextFontColor(_ color:UIColor, view: DrawShapeView) {
        
        let oldColor = view.txtView?.textColor
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            targetSelf.registerUndoTextFontColor(oldColor!, view: view)
        }
        
        self.undoRedoManager.setActionName("ChangeFontColor")
        view.txtView?.textColor = color
    }
    
    
    @objc func registerUndoAddSubview(_ view: DrawShapeView, canvas : UIView) {
        
        self.undoRedoManager.registerUndo(withTarget: self) { (targetSelf) in
            
            targetSelf.registerUndoAddSubview(view, canvas: canvas)
        }
        
        self.undoRedoManager.setActionName("AddSubView")
        
        if self.undoRedoManager.isUndoing  {
            view.removeFromSuperview()
            
        } else {
            
            canvas.addSubview(view)
            view.superview?.bringSubview(toFront: view)
        }
    }
}

//MARK:-
//MARK:- Remove Tools view

extension HomeViewController {
    
    func removeFormatTool()  {
        
        for subView in (appDelegate?.window.subviews)! {
            if let view = subView as? ShapeFormatTool {
                view.removeFromSuperview()
            }
        }
    }
    func removePencilWidthView()  {
        
        for subView in (self.view.subviews) {
            if let view = subView as? PencilWidthView {
                view.removeFromSuperview()
            }
        }
    }
    func removeShapePickerView()  {
        
        for subView in (self.view.subviews) {
            if let view = subView as? shapeView {
                view.removeFromSuperview()
            }
        }
    }
    
    func removeImagePickerView()  {
        
        for subView in (self.view.subviews) {
            if let view = subView as? SelectImageView {
                view.removeFromSuperview()
            }
        }
    }
    
    func removeAllToolsPicker()  {
        
        for subView in (self.view.subviews) {
            
            if let view = subView as? SelectImageView {
                view.removeFromSuperview()
            } else if let view = subView as? shapeView {
                view.removeFromSuperview()
            }else if let view = subView as? PencilWidthView {
                view.removeFromSuperview()
            }
            
        }
        for subView in (appDelegate?.window.subviews)! {
            if let view = subView as? ShapeFormatTool {
                view.removeFromSuperview()
            }
        }
    }
}

