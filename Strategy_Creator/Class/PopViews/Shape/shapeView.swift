//
//  shapeView.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 20/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

typealias selectShapeHandler = ((_ shapeType:shapeType?, _ indexPath:IndexPath) -> Void)

class shapeView: UIView {

    var completionBlock : selectShapeHandler?
    var selectedIndexPath : IndexPath?
    
    @IBOutlet weak var collectionShape: UICollectionView!
        {
        didSet{
            collectionShape.register(UINib(nibName: "ShapeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShapeCell")
        }
    }
    
    var arrShapes = [["name": CSquare, "image" : "Square", "selectimage": "selectsquare"],
                     ["name": CRectangle, "image" : "Rectangle", "selectimage": "selectrectangle"],
                     ["name": CTriangle, "image" : "Triangle", "selectimage": "selecttriangle"],
                     ["name": CRound, "image" : "Round", "selectimage": "selectround"],
                     ["name": CLine, "image" : "line", "selectimage": "selectline"],
                     ["name": COval, "image" : "Oval", "selectimage": "selectoval"]]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionShape.allowsMultipleSelection = false
    }
    
    func updateOrigin(frame: CGRect, completion: selectShapeHandler?)  {
        
        self.frame = frame
        self.completionBlock = completion
        self.collectionShape.reloadData()
    }
    
    
    @IBAction func btnCloseClicked(_ sender : UIButton) {
        
        self.removeFromSuperview()
    }
}

//MARK:-
//MARK:- Collection delegate and datasource

extension shapeView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrShapes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.CViewWidth - 20.0)/2, height: (collectionView.CViewWidth - 20.0)/2)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShapeCell", for: indexPath as IndexPath) as! ShapeCollectionViewCell
        
        let dictIndex = arrShapes[indexPath.row]
        
        if selectedIndexPath == indexPath {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
            cell.imgShape.image = UIImage(named: dictIndex["selectimage"]!)
            cell.lblShapeName.textColor = ColorSkyBlue
        } else {
            cell.imgShape.image = UIImage(named: dictIndex["image"]!)
            cell.lblShapeName.textColor = ColorBlack
        }

        cell.lblShapeName.text = dictIndex["name"]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = self.collectionShape.cellForItem(at: indexPath) as! ShapeCollectionViewCell
        
        let dictShape = arrShapes[indexPath.row]
        
        selectedIndexPath = indexPath

        if self.completionBlock != nil {
        
            switch dictShape["name"] {
            case CSquare?:
                self.completionBlock!(.Square, selectedIndexPath!)
            
            case CRectangle?:
                self.completionBlock!(.RoundedRectangle, selectedIndexPath!)
                
            case CTriangle?:
                self.completionBlock!(.Triangle, selectedIndexPath!)
                
            case CRound?:
                self.completionBlock!(.Circle, selectedIndexPath!)
                
            case CLine?:
                self.completionBlock!(.Lines, selectedIndexPath!)
                
            case COval?:
                self.completionBlock!(.Oval, selectedIndexPath!)
                
            default:
                break
            }
            
            cell.imgShape.image = UIImage(named: dictShape["selectimage"]!)
            cell.lblShapeName.textColor = ColorSkyBlue
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = self.collectionShape.cellForItem(at: indexPath) as! ShapeCollectionViewCell
        
        let dictShape = arrShapes[indexPath.row]
        cell.imgShape.image = UIImage(named: dictShape["image"]!)
        cell.lblShapeName.textColor = ColorBlack
    }

}

