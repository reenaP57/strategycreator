//
//  CMSViewController.swift
//  Strategy_Creator
//
//  Created by mac-00017 on 01/05/18.
//  Copyright © 2018 Mac-00016. All rights reserved.
//

import UIKit

class CMSViewController: ParentViewController {

    @IBOutlet weak var webContent : UIWebView!
    
    var strTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initialize() {
        
        vwHeader?.lblTitle.text =  strTitle
        
        let str = "In hac habitasse platea dictumst. Vivamus adipiscing fermentum quam volutpat aliquam. Integer et elit eget elit facilisis tristique. Nam vel iaculis mauris. Sed ullamcorper tellus erat, non ultrices sem tincidunt euismod. Fusce rhoncus porttitor velit, eu bibendum nibh aliquet vel. Fusce lorem leo, vehicula at nibh quis, facilisis accumsan turpis.Sed ullamcorper tellus erat, non ultrices sem tincidunt euismod. Fusce rhoncus porttitor velit, eu bibendum nibh aliquet vel. Fusce lorem leo, vehicula at nibh quis, facilisis accumsan turpis. Sed ullamcorper tellus erat, non ultrices sem tincidunt euismod. Fusce rhoncus porttitor velit, eu bibendum nibh aliquet vel. Fusce lorem leo, vehicula at nibh quis, facilisis accumsan turpis. Asse platea dictumst. Vivamus adipiscing fermentum quam volutpat aliquam.Onteger et elit eget elit facilisis tristique. Nam vel iaculis mauris. Sed ullamcorper tellus erat, non ultrices sem tincidunt euismod. Fusce rhoncus porttitor velit, eu biben" as String
        
        
        let html = "<html>" + "<head>" + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" + "<style> body { font-family: CarterOne; font-size: 150%; } </style>" + "</head>" + "<body>" + str + "</body>" + "</html>"
        
        self.webContent.loadHTMLString(html, baseURL: nil)

    }

}
