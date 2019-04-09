//
//  AppDelegate.swift
//  DemoBase
//
//  Created by Mac-00016 on 25/01/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let window = UIWindow(frame: UIScreen.main.bounds)
    var FormatToolFrame : CGRect?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.initiateWithLaunchOptions(launchOptions: launchOptions)

        self.window.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    
    // Manage orientation for imagepicker
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        // when image picker is present
        let topMostVC = UIApplication.shared.topMostViewController
        if topMostVC is UIImagePickerController  && !(topMostVC.isBeingDismissed || topMostVC.isMovingFromParentViewController){
            return UIInterfaceOrientationMask.portrait
        }
    
        return UIInterfaceOrientationMask.landscape
        
    }
    //MARK:-
    //MARK:- General
    
    func initiateWithLaunchOptions(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        UIApplication.shared.isStatusBarHidden = false
        //.....Monitoring Internet Reachability.....
        
        //set UI based on language selected
        if Localization.sharedInstance.getLanguage() == CLanguageArabic
        {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }
        else
        {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        //.....
        self.initiateApplicationRoot()
    }
    
    func initiateApplicationRoot() {
        
        if CUserDefaults.value(forKey: UserDefaultLanguageSelected) == nil
        {
            let vcRoot = CMain_storyboard.instantiateViewController(withIdentifier: "SelectLanguageViewController")
            self.setWindowRootViewController(rootVC: vcRoot, animated: false, completion: nil)
        }
        else{
            initHomeController()
        }
    }

    func initHomeController()
    {
        let vcRoot  = CMain_storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        self.setWindowRootViewController(rootVC: vcRoot, animated: false, completion: nil)
    }
    
    //MARK:-
    //MARK:- Root & Main
    func setWindowRootViewController(rootVC:UIViewController?, animated:Bool, completion: ((Bool) -> Void)?) {
        
        guard rootVC != nil else {
            return
        }
        
        UIView.transition(with: self.window, duration: animated ? 0.6 : 0.0, options: .transitionCrossDissolve, animations: {
            
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            
            self.window.rootViewController = rootVC
            UIView.setAnimationsEnabled(oldState)
        }) { (finished) in
            if let handler = completion {
                handler(true)
            }
        }
    }
    

    //MARK:-
    //MARK:- Set Fonts
    func convertToAppFont(font:UIFont) -> UIFont {
        
        let fontSize = font.pointSize
        var type = CFontCarterOneType.Regular
        
        if(font.fontName.contains("Regular"))
        {
            type = CFontCarterOneType.Regular
        }
        return CFontCarterOne(size: fontSize, type: type)
        
//        if IS_iPhone_5
//        {
//            return  CFontRoboto(size: fontSize - 2, type: type)
//        }
//        else
//        {
//            return  CFontRoboto(size: fontSize, type: type)
//        }
    }

}

