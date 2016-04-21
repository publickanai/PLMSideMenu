//
//  ViewController.swift
//  PLMSideMenu
//
//  Created by Tatsuhiro Kanai on 04/21/2016.
//  Copyright (c) 2016 Tatsuhiro Kanai. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /** Button Tapped
     */
    @IBAction func didTapSideMenuButton(sender:AnyObject?)
    {
        if self.navigationController?.isSideMenuOpen() == true
        {
            self.navigationController?.hideSideMenuView()
        }else{
            self.navigationController?.showSideMenuView()
        }
    }
    
    
}

