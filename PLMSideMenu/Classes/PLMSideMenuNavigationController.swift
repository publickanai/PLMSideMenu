//
//  PLMSideMenuNavigationController.swift
//  PreLaunchMe
//
//  Created by Tatsuhiro Kanai on 2015/08/27.
//  Copyright (c) 2015年 Adways Inc. All rights reserved.
//


import UIKit


// MARK: - 
// MARK: - PLMSideMenuNavigationController

public class PLMSideMenuNavigationController: UINavigationController, PLMSideMenuProtocol
{
    
    public var sideMenuAnimationType : PLMSideMenuAnimationType = .Default
    
    /** Init
     */
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    public init( menuViewController: UIViewController, contentViewController: UIViewController?)
    {
        super.init(nibName: nil, bundle: nil)
        
        // setup ContentViewController
        
        if (contentViewController != nil) {
            self.viewControllers = [contentViewController!]
        }
        
        // setup SideMenu
        sideMenu = PLMSideMenu(sourceView: self.view, menuViewController: menuViewController, menuPosition:.Left)
        
        // bring navigationBar from
        view.bringSubviewToFront(navigationBar)
    }
    
    public override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** ViewController LifeCycle
     */
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /** PLMSideMenuProtocol
     */
    //  var sideMenu
    public var sideMenu : PLMSideMenu?
    
    // set ContentViewController
    public func setContentViewController( contentViewController: UIViewController)
    {
        self.sideMenu?.toggleMenu()
        
        switch sideMenuAnimationType
        {
            case .None:
                
                self.viewControllers = [contentViewController]
                break
            
            default:
                
                contentViewController.navigationItem.hidesBackButton = true
                self.setViewControllers([contentViewController], animated: true)
                break
        }
    }
    
    // Transition
    public func pushContentViewController(contentViewController: UIViewController)
    {
        self.sideMenu?.hideSideMenu()
        
        switch sideMenuAnimationType
        {
            case .None:
                self.pushViewController(contentViewController, animated: false)
                break
            default:
                self.pushViewController(contentViewController, animated: true)
                break
        }
        
    }
    
    
}
