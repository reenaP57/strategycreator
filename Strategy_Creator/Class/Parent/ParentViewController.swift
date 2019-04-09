//
//  ParentViewController.swift
//  CollectMee
//
//  Created by mac-0007 on 12/12/17.
//  Copyright © 2017 mac-0007. All rights reserved.
//

import UIKit

enum StopAnimationType : Int {
    case dataNotFound
    case errorTapToRetry
    case remove
}

typealias setBlock = (dictData: Dictionary, error: NSError)

class ParentViewController: UIViewController
{
    var vwHeader : HeaderView?
    
    var isNavigateFromSidePanel : Bool = false
    var iObject : Any?
    
    //MARK:- UIStatusBar
    
    var isStatusBarHide = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    var statusBarStyle = UIApplication.shared.statusBarStyle {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
            UIApplication.shared.statusBarStyle = statusBarStyle
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return isStatusBarHide
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return statusBarStyle
        }
    }
    
    
    //MARK:-
    //MARK:- LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!(vwHeader != nil))
        {
            guard let header = HeaderView.viewFromXib as? HeaderView else {return}
            vwHeader = header
        }
        if !self.view.subviews.contains(vwHeader!)
        {
            self.view.insertSubview(vwHeader!, marginInsets: UIEdgeInsetsMake(0, 0, self.view.CViewHeight - vwHeader!.CViewHeight, 0), Index : 0)
            
            if (self.isKind(of: HomeViewController.self)) {
                vwHeader?.showHomeButtons()
                
            } else if (self.isKind(of: SelectLanguageViewController.self)) {
                vwHeader?.imgHeader.isHidden = true
                
                if CUserDefaults.value(forKey: UserDefaultLanguageSelected) == nil {
                    vwHeader?.btnMenu.isHidden = true
                }
                
            } else if (self.isKind(of: CMSViewController.self))  {
                vwHeader?.hideHomeButtons()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewAppearance()
        //self.setRotationAngle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        
        vwHeader?.layoutSubviews()
        vwHeader?.layoutIfNeeded()
    }
    
    //MARK:-
    //MARK:- Header change angle of rotation
//    func setRotationAngle()
//    {
//        if vwHeader != nil
//        {
//            vwHeader?.setRotationAngle()
//        }
//    }
    
    
    //MARK:-
    //MARK:- General Method
    
    fileprivate func setupViewAppearance() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.isUserInteractionEnabled = true
        
        self.statusBarStyle = .lightContent

        //....Generic Navigation Setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationController?.navigationBar.hide(byHeight: true)
        
        if (self.view.tag == 100) {
            
            //..Navigation bar hidden
            self.navigationController?.navigationBar.hide(byHeight: true)
        }
        else
        {
            self.navigationController?.navigationBar.barTintColor = UIColor.purple
            self.navigationController?.navigationBar.tintColor = ColorBlue
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.isTranslucent = false
        }
        
    }
    
    func resignKeyboard() {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    

    //MARK:-
    //MARK:- Helper Method
    
    @objc func leftBurgerMenuClicked() {
//        appDelegate?.sideMenuViewController?.setDrawerState(.opened, animated: true)
    }
    
    func startLoadingAnimation(in view: UIView?)
    {
        if let view = view {
            var animationView = view.viewWithTag(1000)
            
            if animationView == nil {
                
                animationView = UIView(frame: CGRect.zero)
                animationView?.translatesAutoresizingMaskIntoConstraints = false
                animationView?.backgroundColor = UIColor.white
                animationView?.tag = 1000
                
                //....
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                activityIndicator.color = ColorBlue
                activityIndicator.hidesWhenStopped = true
                activityIndicator.center = animationView?.center ?? CGPoint.zero
                activityIndicator.startAnimating()
                activityIndicator.tag = 1001
                animationView?.addSubview(activityIndicator)
                animationView?.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: animationView, attribute: .centerX, multiplier: 1, constant: 0))
                animationView?.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: animationView, attribute: .centerY, multiplier: 1, constant: 0))
                
                //....
                view.addSubview(animationView!)
                view.addConstraint(NSLayoutConstraint(item: animationView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: animationView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: animationView!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: animationView!, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0))
                
            }
        }
        
    }
    
    func stopLoadingAnimation(in view: UIView?)
    {
        if let view = view {
            let animationView = view.viewWithTag(1000)
            if animationView != nil {
                animationView?.removeFromSuperview()
            }
        }
    }
}
