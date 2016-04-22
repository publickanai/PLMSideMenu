//
//  MainNavigationController.swift
//  PLMSideMenu
//
//  Created by Tatsuhiro Kanai on 2016/04/21.
//  Copyright © 2016年 Tatsuhiro Kanai. All rights reserved.
//

import UIKit
import PLMSideMenu

class MainNavigationController: PLMSideMenuNavigationController, PLMSideMenuDelegate , UINavigationControllerDelegate
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // set UINavigationControllerDelegate
        self.delegate = self
        self.setupSideMenu()
    }
    
    /** Setup SideMenu
     */
    private func setupSideMenu()
    {
        // init with sideMenu's parent view and MenuVIewController
        self.sideMenu       = PLMSideMenu( sourceView : self.view , menuViewController : MenuViewController(), menuPosition:.Right)
        sideMenu?.delegate  = self // optional, PLMSideMenuDelegate
        sideMenu?.menuWidth = 180.0 // custom SideMenu Width, default is 160
        //sideMenu?.allowSwipeOpen = true
        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
    }
    
    /** PLMSideMenu Delegate Method
     */
    func sideMenuWillOpen() {
        print("Main SideMenu Delegate sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("Main SideMenu Delegate sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("Main SideMenu Delegate sideMenuShouldOpenSideMenu")
        return true
    }
    
    func sideMenuDidClose() {
        print("Main SideMenu Delegate sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("Main SideMenu Delegate sideMenuDidOpen")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** UINavigationController Delegate Method
     */
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool)
    {
        print("Main SideMenu Delegate willShowViewController")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
