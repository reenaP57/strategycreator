//
//  SelectLanguageViewController.swift
//  Strategy_Creator
//
//  Created by Mac-00016 on 19/04/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

class SelectLanguageViewController: ParentViewController {

    @IBOutlet weak var btnEnglish: GenericButton!
    @IBOutlet weak var btnArabic: GenericButton!
    @IBOutlet weak var imgVSelLanguage: UIImageView!

    var imgCanvas : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set UI based on language selected
        self.initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vwHeader?.lblTitle.text = ""
    }

    func initialize()
    {
        
        if CUserDefaults.value(forKey: UserDefaultLanguageSelected) != nil
        {
            if Localization.sharedInstance.getLanguage() == CLanguageArabic
            {
                imgVSelLanguage.image = UIImage(named: "selLanguageAr")
                btnArabic.isSelected = true
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
            }
            else
            {
                imgVSelLanguage.image = UIImage(named: "selLanguageEn")
                btnEnglish.isSelected = true
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
            }
        }
    }
    
}

//MARK: - Button Click Action
extension SelectLanguageViewController
{
    func setEnglishLanguage() {
        
        self.btnEnglish.isSelected = true
        self.imgVSelLanguage.image = UIImage(named: "selLanguageEn")
        LocalizationSetLanguage(language: CLanguageEnglish)
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.navigateToHome()
        
    }
    
    func setArabicLanguage() {
        btnArabic.isSelected = true
        imgVSelLanguage.image = UIImage(named: "selLanguageAr")
        LocalizationSetLanguage(language: CLanguageArabic)
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        self.navigateToHome()
    }
    
    
    @IBAction func btnEnglishClicked(_ sender: UIButton) {
        
        if CUserDefaults.value(forKey: UserDefaultLanguageSelected) != nil {
            
            DispatchQueue.main.async {
                
                self.presentAlertViewWithThreeButtons(alertTitle: "", alertMessage: CSavedConfimation, btnOneTitle: CSave, btnOneTapped: { (action) in
                    
                    if let image = self.imgCanvas {

                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        self.setEnglishLanguage()

                    }
                    
                }, btnTwoTitle: CDontSave, btnTwoTapped: { (action) in
                    self.setEnglishLanguage()
                    
                }, btnThreeTitle: CCancel, btnThreeTapped: { (action) in
                })
            }
        } else {
            self.setEnglishLanguage()
        }
        
    }
    
    
    @IBAction func btnArabicClicked(_ sender: UIButton) {
       
        if CUserDefaults.value(forKey: UserDefaultLanguageSelected) != nil {
            
            DispatchQueue.main.async {
                
                self.presentAlertViewWithThreeButtons(alertTitle: "", alertMessage: CSavedConfimation, btnOneTitle: CSave, btnOneTapped: { (action) in
                    
                    if let image = self.imgCanvas {

                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        
                        self.setArabicLanguage()
                    }
                    
                }, btnTwoTitle: CDontSave, btnTwoTapped: { (action) in
                    self.setArabicLanguage()

                }, btnThreeTitle: CCancel, btnThreeTapped: { (action) in
                })
            }
        } else {
            self.setArabicLanguage()
        }
    }
    
    func navigateToHome()
    {
        CUserDefaults.setValue(true, forKey: UserDefaultLanguageSelected)
//
//        let vcHome  = CMain_storyboard.instantiateViewController(withIdentifier: "vcHome") as! HomeViewController
//        self.navigationController?.pushViewController(vcHome, animated: true)
        appDelegate?.initHomeController()
    }
}


//MARK:-
//MARK:- Save Image

extension SelectLanguageViewController {
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            self.presentAlertViewWithOneButton(alertTitle: CSaveError, alertMessage: error.localizedDescription, btnOneTitle: COk, btnOneTapped: { (action) in
            })
        } else {
            self.presentAlertViewWithOneButton(alertTitle: "", alertMessage: CSavedSuccessfully, btnOneTitle: COk, btnOneTapped: { (action) in
            })
        }
    }
}
