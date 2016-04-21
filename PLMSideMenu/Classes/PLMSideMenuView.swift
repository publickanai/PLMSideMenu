//
//  PLMSideMenuView.swift
//  PreLaunchMe
//
//  Created by Tatsuhiro Kanai on 2015/08/27.
//  Copyright (c) 2015年 Adways Inc. All rights reserved.
//

import UIKit

// MARK: -
// MARK: - PLMSideMenu Delegate Method

public protocol PLMSideMenuDelegate
{
    func sideMenuWillOpen()
    func sideMenuWillClose()
    func sideMenuDidOpen()
    func sideMenuDidClose()
    func sideMenuShouldOpenSideMenu () -> Bool
}


// MARK: - 
// MARK: - PLMSideMenu Protocol

public protocol PLMSideMenuProtocol
{
    var sideMenu : PLMSideMenu? { get }
    
    // Set ContentViewController
    func setContentViewController( contentViewController : UIViewController )
    
    // for PushViewControler
    func pushContentViewController( contentViewController : UIViewController )
    
}

// MARK: - 
// MARK: - PLMSideMenuAnimationType

public enum PLMSideMenuAnimationType : Int
{
    case None
    case Default
}

/**
The position of the side view on the screen.

- Left:  Left side of the screen
- Right: Right side of the screen
*/

public enum PLMSideMenuPositionType : Int
{
    case Left
    case Right
}

// MARK: -
// MARK: - ViewController Extension 

public extension UIViewController
{
    /**
     * Returns a Boolean value indicating whether the side menu is showed.
     * - :returns: BOOL value
     */
    public func isSideMenuOpen () -> Bool
    {
        let isOpen : Bool = self.sideMenuController()?.sideMenu?.isMenuOpen ?? false
        return isOpen
    }
    
    /** Changes current state of side menu view.
     */
    public func toggleSideMenuView ()
    {
        sideMenuController()?.sideMenu?.bouncingEnabled = false
        sideMenuController()?.sideMenu?.animationDuration = 0.25
        sideMenuController()?.sideMenu?.toggleMenu()
    }
    
    /** Hides the side menu view.
     */
    public func hideSideMenuView ()
    {
        sideMenuController()?.sideMenu?.bouncingEnabled = false
        sideMenuController()?.sideMenu?.animationDuration = 0.25
        sideMenuController()?.sideMenu?.hideSideMenu()
    }
    
    /** Shows the side menu view.
     */
    public func showSideMenuView ()
    {
        sideMenuController()?.sideMenu?.bouncingEnabled = false
        sideMenuController()?.sideMenu?.animationDuration = 0.25
        sideMenuController()?.sideMenu?.showSideMenu()
    }
    
    /**
    * You must call this method from viewDidLayoutSubviews in your content view controlers so it fixes size and position of the side menu when the screen
    * rotates.4
    * A convenient way to do it might be creating a subclass of UIViewController that does precisely that and then subclassing your view controllers from it.
    */
    func updateSideMenuSize() {
        if let navController = self.navigationController as? PLMSideMenuNavigationController {
            navController.sideMenu?.updateFrame()
        }
    }
    
    /**
    * Returns a view controller containing a side menu
    * :returns: A 'UIViewController' responding to 'PLMSideMenuProtocol' protocol
    */
    public func sideMenuController () -> PLMSideMenuProtocol?
    {
        // iteration
        
        var iteration : UIViewController? = self.parentViewController
        if (iteration == nil) {
            return topMostController()
        }
        
        repeat
        {
            if (iteration is PLMSideMenuProtocol)
            {
                return iteration as? PLMSideMenuProtocol
                
            } else if (iteration?.parentViewController != nil && iteration?.parentViewController != iteration)
            {
                iteration = iteration!.parentViewController
            
            } else {
                
                iteration = nil
            }
            
        } while (iteration != nil)
        
        return iteration as? PLMSideMenuProtocol
    }
    
    
    internal func topMostController () -> PLMSideMenuProtocol?
    {
        var topController : UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController
        
        /** If Top is TabBar, Set TabBarController SelectedViewController
         */
        if (topController is UITabBarController)
        {
            topController = (topController as! UITabBarController).selectedViewController
        }
        
        /** Top
         */
        while (topController?.presentedViewController is PLMSideMenuProtocol)
        {
            topController = topController?.presentedViewController
        }
        
        return topController as? PLMSideMenuProtocol
    }
    
}

// MARK: -
// MARK: - PLM SideMenu

public class PLMSideMenu : NSObject, UIGestureRecognizerDelegate
{
    // default MenuWidth
    public static let kDefaultMenuWidth: CGFloat = 160.0
    
    // width of the side menu view.
    public var menuWidth : CGFloat = kDefaultMenuWidth {
        didSet {
            needUpdateSideMenuShadow = true
            updateFrame()
        }
    }
    
    private var menuPosition : PLMSideMenuPositionType = .Left
    
    // Bouncing Effect is enabled.
    // The default value is TRUE.
    public  var bouncingEnabled :Bool = true
    
    // duration of the slide animation. 
    // Used only when 'bouncingEnabled' is FALSE.(UIViewAnimation)
    public  var animationDuration = 0.4
    private let sideMenuContainerView =  UIView()
    private var menuViewController  : UIViewController!
    private var animator            : UIDynamicAnimator!
    
    // the parentView of the menuViewController
    private var sourceView          : UIView!
    //
    private var needUpdateSideMenuShadow : Bool = false
    
    // delegate of the side menu
    public var delegate    : PLMSideMenuDelegate?
    
    // Is Menu Open
    private(set) var isMenuOpen : Bool = false
    
    // Left swipe is enabled.
    public var allowLeftSwipe : Bool = true
    
    // Right swipe is enabled.
    public var allowRightSwipe : Bool = true
    
    //  to open side menu with swipe
    private var _allowSwipeOpen : Bool = false
    public var allowSwipeOpen : Bool {
        set{ _allowSwipeOpen = newValue
            addGestureRecognizers()
        }
        get{ return _allowSwipeOpen }
    }
    
    //  to close side menu with swipe
    public var allowSwipeClose :Bool = true
    
    // Gesture Recognizer
    var rightSwipeGestureRecognizer :   UISwipeGestureRecognizer!
    var leftSwipeGestureRecognizer  :   UISwipeGestureRecognizer!
    
    /**
    - Init
    :param: sourceView   The parent view of the side menu view.
    :param: menuPosition The position of the side menu view.
    :returns: An initialized 'SideMenu' object, added to the specified view.
    */
    public init( sourceView: UIView , menuPosition: PLMSideMenuPositionType )
    {
        super.init()
        
        self.sourceView = sourceView
        self.menuPosition = menuPosition
        self.setupMenuView()
        
        // Animator
        animator = UIDynamicAnimator(referenceView:sourceView)
        animator.delegate = self
        
        // Right Swipe Gesture Recognizer
        rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        rightSwipeGestureRecognizer.delegate  = self
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        
        // Left Swipe Gesture Recognizer
        leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        leftSwipeGestureRecognizer.delegate  = self
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        // Add Gesture Recognizer
        
        addGestureRecognizers()
        
//        if (menuPosition == .Left)
//        {
//            if(allowSwipeOpen)
//            {
//                sourceView.addGestureRecognizer( rightSwipeGestureRecognizer )
//            }
//            sideMenuContainerView.addGestureRecognizer( leftSwipeGestureRecognizer )
//            
//        } else {
//            
//            sideMenuContainerView.addGestureRecognizer( rightSwipeGestureRecognizer )
//            if(allowSwipeOpen)
//            {
//                sourceView.addGestureRecognizer( leftSwipeGestureRecognizer )
//            }
//        }
        
    }
    
    internal func addGestureRecognizers()
    {
        
        // Add Gesture Recognizer
        
        if (self.isMenuOpen)
        {
            
            if (menuPosition == .Left)
            {
                // remove Open-Gesture from sourceView
                sourceView.removeGestureRecognizer(rightSwipeGestureRecognizer)
                
                
                if(allowSwipeClose)
                {
                    // Add gesture for Left-Swipe-Close
                    sourceView.addGestureRecognizer(leftSwipeGestureRecognizer)
                }
                
            } else {
                
                // remove Open-Gesture from sourceView
                sourceView.removeGestureRecognizer(leftSwipeGestureRecognizer)
                
                if(allowSwipeOpen)
                {
                    // Add gesture for Right-Swipe-Close
                    sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
                }
            }
            
            
        } else {
            
            if (menuPosition == .Left)
            {
                // remove Close-Gesture from sourceView
                sourceView.removeGestureRecognizer(leftSwipeGestureRecognizer)
                
                // add Gesture
                if(allowSwipeOpen)
                {
                    //open
                    sourceView.addGestureRecognizer( rightSwipeGestureRecognizer )
                }
                //close
                sideMenuContainerView.addGestureRecognizer( leftSwipeGestureRecognizer )
                
            } else {
                
                // remove Close-Gesture from sourceView
                sourceView.removeGestureRecognizer(rightSwipeGestureRecognizer)
                
                sideMenuContainerView.addGestureRecognizer( rightSwipeGestureRecognizer )
                if(allowSwipeOpen)
                {
                    sourceView.addGestureRecognizer( leftSwipeGestureRecognizer )
                }
            }
            
            
        }
        
        
        
    }
    
    /**
    - Init
     
    :param: sourceView         parent view for the side menu view.
    :param: menuViewController viewController which will be placed in the side menu view.
    :param: menuPosition       position of the side menu view
    
    :returns: initialized 'SideMenu' object, added to the specified view, containing the specified menu view controller.
    */
    public convenience init(sourceView: UIView, menuViewController: UIViewController, menuPosition: PLMSideMenuPositionType)
    {
        self.init(sourceView: sourceView, menuPosition: menuPosition)
        
        self.menuViewController                         = menuViewController
        self.menuViewController.view.frame              = sideMenuContainerView.bounds
        self.menuViewController.view.autoresizingMask   = [.FlexibleWidth, .FlexibleHeight]
        
        sideMenuContainerView.addSubview( self.menuViewController.view )
    }
    
    /** Updates the frame of the side menu view.
     */
    
    func updateFrame()
    {
        var width:CGFloat
        var height:CGFloat
        
        width  = sourceView.frame.size.width
        height = sourceView.frame.size.height
        
        let posX = (menuPosition == .Left) ? isMenuOpen ? 0 : -menuWidth-1.0 : isMenuOpen ? width - menuWidth : width + 1.0
        let menuFrame = CGRectMake( posX, sourceView.frame.origin.y, menuWidth, height )
        
        sideMenuContainerView.frame = menuFrame
    }
    
    /** setup MenuView
     */
    
    private func setupMenuView()
    {
        updateFrame()
        
        sideMenuContainerView.backgroundColor = UIColor.clearColor()
        sideMenuContainerView.clipsToBounds = false
        sideMenuContainerView.layer.masksToBounds = false
        sideMenuContainerView.layer.shadowOffset = (menuPosition == .Left) ? CGSizeMake(1.0, 1.0) : CGSizeMake(-1.0, -1.0)
        sideMenuContainerView.layer.shadowRadius = 1.0
        sideMenuContainerView.layer.shadowOpacity = 0.125
        sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath
        
        // Add SideMenu
        sourceView.addSubview(sideMenuContainerView)
        
        // blur only run on ios8 and later
        if ( NSClassFromString("UIVisualEffectView") != nil)
        {
            // Add Blur View
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
            visualEffectView.frame = sideMenuContainerView.bounds
            visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            sideMenuContainerView.addSubview(visualEffectView)
        }
        
    }
    
    /** toggle Menu
     */
    private func toggleMenu (shouldOpen: Bool)
    {
        // Abort if denied in protocol
        if ( shouldOpen && delegate?.sideMenuShouldOpenSideMenu() == false )
        {
            return
        }
        
        // shadow
        updateSideMenuShadowIfNeeded()
        
        // opening menu
        isMenuOpen = shouldOpen
        
        // call delegate's 'Will' Method
        if (shouldOpen)
        {   // will Open
            delegate?.sideMenuWillOpen()
        } else {
            // will Close
            delegate?.sideMenuWillClose()
        }
        
        /** configure and Start Animation
         */
         
        // sourceView Size
        var width:CGFloat
        var height:CGFloat
        
        width   = sourceView.frame.size.width
        height  = sourceView.frame.size.height
        
        if (bouncingEnabled)
        {
            /** Bouncing Animation
             */
            
            // remove for reset
            animator.removeAllBehaviors()
            
            var gravityDirectionX: CGFloat
            var pushMagnitude: CGFloat
            var boundaryPointX: CGFloat
            var boundaryPointY: CGFloat
            
            if (menuPosition == .Left)
            {
                // Left side menu
                gravityDirectionX   = (shouldOpen) ? 1 : -1
                pushMagnitude       = (shouldOpen) ? 20 : -20
                boundaryPointX      = (shouldOpen) ? menuWidth : -menuWidth-2
                boundaryPointY      = 20
                
            } else {
                
                // Right side menu
                gravityDirectionX   = (shouldOpen) ? -1 : 1
                pushMagnitude       = (shouldOpen) ? -20 : 20
                boundaryPointX      = (shouldOpen) ? width - menuWidth : width + menuWidth + 2
                boundaryPointY      =  -20
            }
            
            // gravity behavior
            let gravityBehavior = UIGravityBehavior(items: [sideMenuContainerView])
            gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX,  0)
            animator.addBehavior(gravityBehavior)
            
            // collision Behavior
            let collisionBehavior = UICollisionBehavior(items: [sideMenuContainerView])
            collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake(boundaryPointX, boundaryPointY),
                toPoint: CGPointMake(boundaryPointX, height))
            animator.addBehavior(collisionBehavior)
            
            // pushBehavior
            let pushBehavior = UIPushBehavior(items: [sideMenuContainerView], mode: UIPushBehaviorMode.Instantaneous)
            pushBehavior.magnitude = pushMagnitude
            animator.addBehavior(pushBehavior)
            
            let menuViewBehavior = UIDynamicItemBehavior(items: [sideMenuContainerView])
            menuViewBehavior.elasticity = 0.25
            
            // Start Animation With Bouncing
            animator.addBehavior(menuViewBehavior)
            
        } else {
            
            /** No Bouncing Animation
             */
            
            var destFrame :CGRect
            
            // destposition for Open and Close
            if (menuPosition == .Left)
            {
                destFrame = CGRectMake((shouldOpen) ? -2.0 : -menuWidth, 0, menuWidth, height)
            } else {
                destFrame = CGRectMake((shouldOpen) ? width - menuWidth : width+2.0, 0, menuWidth, height)
            }
            
            // Start Animation Without Bouncing
            UIView.animateWithDuration (
                animationDuration,
                animations: { () -> Void in
                    
                    self.sideMenuContainerView.frame = destFrame
                    
                },
                completion: { [weak self] (Bool) -> Void in
                    
                    if let weakSelf = self
                    {
                        /** Call delegate's 'Did' Method
                         */
                        
                        if (weakSelf.isMenuOpen)
                        {   // Completed Open
                            weakSelf.delegate?.sideMenuDidOpen()
                        } else {
                            // Completed Close
                            weakSelf.delegate?.sideMenuDidClose()
                        }
                    }
                    
            })
            
        }
        
    }
    
    /** GestureRecognizer Delegate Method
     */
    public func gestureRecognizerShouldBegin( gestureRecognizer : UIGestureRecognizer ) -> Bool
    {
        if gestureRecognizer is UISwipeGestureRecognizer
        {
            let swipeGestureRecognizer = gestureRecognizer as! UISwipeGestureRecognizer
            
            if !self.allowLeftSwipe
            {
                if swipeGestureRecognizer.direction == .Left
                {
                    return false
                }
            }
            
            if !self.allowRightSwipe
            {
                if swipeGestureRecognizer.direction == .Right
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    /** GestureRecognizer Handler Method
     */
    internal func handleSwipeGesture(gesture: UISwipeGestureRecognizer)
    {
        toggleMenu((self.menuPosition == .Right && gesture.direction == .Left)
            || (self.menuPosition == .Left && gesture.direction == .Right))
    }
    
    /** SideMenu Shadow
     */
    private func updateSideMenuShadowIfNeeded()
    {
        if (needUpdateSideMenuShadow)
        {
            var frame = sideMenuContainerView.frame
            frame.size.width = menuWidth
            sideMenuContainerView.frame = frame
            sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath
            needUpdateSideMenuShadow = false
        }
    }
    
    /** Toggles the state of the side menu.
     */
    public func toggleMenu ()
    {
        if (isMenuOpen)
        {
            toggleMenu(false)
        } else {
            updateSideMenuShadowIfNeeded()
            toggleMenu(true)
        }
    }
    
    /** Shows the side menu if the menu is hidden.
     */
    public func showSideMenu ()
    {
        if (!isMenuOpen) {
            toggleMenu(true)
        }
    }
    
    /** Hides the side menu if the menu is showed.
     */
    public func hideSideMenu () {
        if (isMenuOpen) {
            toggleMenu(false)
        }
    }
}

// MARK: -
// MARK: - PLMSideMenu Extension

extension PLMSideMenu: UIDynamicAnimatorDelegate
{
    
    /** dynamicAnimatorDelegate method  which is called when animation finished
     */
    public func dynamicAnimatorDidPause(animator: UIDynamicAnimator)
    {
        if (self.isMenuOpen)
        {
            // Open did Pause
            self.delegate?.sideMenuDidOpen()
            
            if (menuPosition == .Left)
            {
                sourceView.removeGestureRecognizer(rightSwipeGestureRecognizer)
                if (allowSwipeClose)
                {
                    // Add gesture for Left-Swipe-Close
                    sourceView.addGestureRecognizer(leftSwipeGestureRecognizer)
                }
                
            } else
            {
                sourceView.removeGestureRecognizer(leftSwipeGestureRecognizer)
                if (allowSwipeClose)
                {
                    // Add gesture for Right-Swipe-Close
                    sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
                }
            }
            
        } else {
            
            // Close did Pause
            self.delegate?.sideMenuDidClose()
            
            if (menuPosition == .Left)
            {
                sourceView.removeGestureRecognizer(leftSwipeGestureRecognizer)
                if(allowSwipeOpen)
                {
                    // Add gesture for Right-Swipe-Open
                    sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
                }
                
            } else {
                
                sourceView.removeGestureRecognizer(rightSwipeGestureRecognizer)
                if(allowSwipeOpen)
                {
                    // Add gesture for Left-Swipe-Open
                    sourceView.addGestureRecognizer(leftSwipeGestureRecognizer)
                }
            }
            
        }
    }
    
    /** dynamicAnimatorDelegate method which is called when animation resume
     */
    public func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
        //print("resume : ")
    }
    
}

