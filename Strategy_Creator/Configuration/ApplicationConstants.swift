//
//  ApplicationConstants.swift
//  CollectMee
//
//  Created by mac-0016 on 12/12/17.
//  Copyright © 2017 mac-0007. All rights reserved.
//

import Foundation
import UIKit


//MARK:-
//MARK:- Status

let CJsonResponse       = "response"
let CJsonMessage        = "message"
let CJsonStatus         = "status"
let CStatusCode         = "status_code"
let CJsonTitle          = "title"
let CJsonData           = "data"

let CLimit              = 20

let CStatusZero         = 0
let CStatusOne          = 1
let CStatusTwo          = 2
let CStatusThree        = 3
let CStatusFour         = 4
let CStatusFive         = 5
let CStatusEight        = 8
let CStatusNine         = 9
let CStatusTen          = 10
let CStatusEleven       = 11

let CStatusTwoHundred   = NSNumber(value: 200 as Int)       //  Success
let CStatusFourHundredAndOne = NSNumber(value: 401 as Int)     //  Unauthorized user access
let CStatusFiveHundredAndFiftyFive = NSNumber(value: 555 as Int)   //  Invalid request
let CStatusFiveHundredAndFiftySix = NSNumber(value: 556 as Int)   //  Invalid request
let CStatusFiveHundredAndFifty = NSNumber(value: 550 as Int)        //  Inactive/Delete user
let CStatusFiveHunred   = NSNumber(value: 500 as Int)



//MARK:-
//MARK:- Fonts
enum CFontCarterOneType:Int {
    case Regular
}

func CFontCarterOne(size: CGFloat, type: CFontCarterOneType) -> UIFont {
    switch type {
    case .Regular:
        return UIFont.init(name: "CarterOne", size: size)!
//    default:
//        return UIFont.init(name: "CarterOne-Regular", size: size)!
    }
}


//MARK:-
//MARK:- UI constants
let cornerRadius           =        ""
let shadow                 =        ""


//MARK:-
//MARK:- Notification Constants

let NotificationDidUpdateLocation       = "NotificationDidUpdateLocation"
let NotificationDidUpdateUserDetail     = "NotificationDidUpdateUserDetail"



//MARK:-
//MARK:- UserDefaults Keys
let UserDefaultLanguageSelected           = "UserDefaultLanguageSelected"



//MARK:-
//MARK:- Color
let ColorBlue           = CRGB(r: 0, g: 149, b: 207)
let ColorLightBlue      = CRGB(r: 0, g: 211, b: 246)
let ColorGreen          = CRGB(r: 0, g: 204, b: 132)
let ColorBlack          = CRGB(r: 1, g: 12, b: 40)
let ColorWhite          = CRGB(r: 255, g: 255, b: 255)
let ColorSkyBlue        = CRGB(r: 176, g: 236, b: 252)


//MARK:-
//MARK:- UIStoryboard Constant
let CMain_storyboard         =   UIStoryboard(name: "Main", bundle: nil)


//MARK:-
//MARK:- Application Language
let CLanguageArabic            = "ar"
let CLanguageEnglish           = "en"



//MARK:-
//MARK:- Other
let CComponentJoinedString          = ", "

let CAccountTypeNormal       = 0
let CAccountTypeFacebook     = 1
let CAccountTypeGoogle       = 2
let CAccountTypeInstagram    = 3


