# PLMSideMenu

[![CI Status](http://img.shields.io/travis/tatsuhiro kanai/PLMSideMenu.svg?style=flat)](https://travis-ci.org/tatsuhiro kanai/PLMSideMenu)
[![Version](https://img.shields.io/cocoapods/v/PLMSideMenu.svg?style=flat)](http://cocoapods.org/pods/PLMSideMenu)
[![License](https://img.shields.io/cocoapods/l/PLMSideMenu.svg?style=flat)](http://cocoapods.org/pods/PLMSideMenu)
[![Platform](https://img.shields.io/cocoapods/p/PLMSideMenu.svg?style=flat)](http://cocoapods.org/pods/PLMSideMenu)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.


import PLMSideMenu module.

```swift
import PLMSideMenu
```


Define your Navigation Controller class with PLMSideMenuNavigationController.

```swift
class MainNavigationController: PLMSideMenuNavigationController, PLMSideMenuDelegate , UINavigationControllerDelegate
{
```

Setup SideMenu

```swift
override func viewDidLoad()
{
    super.viewDidLoad()
    
    // set UINavigationControllerDelegate
    self.delegate = self
    
    // setup SideMenu
    self.setupSideMenu()
}

/** Setup SideMenu
*/
private func setupSideMenu()
{
    // init with parent view of the sidemenu and menu view controller
    self.sideMenu       = PLMSideMenu( sourceView : self.view , menuViewController : MenuViewController(), menuPosition:.Right)
    sideMenu?.delegate  = self // optional, PLMSideMenuDelegate
    sideMenu?.menuWidth = 180.0 // custom SideMenu Width, default is 160
    //sideMenu?.allowSwipeOpen = true

    // make navigation bar showing over side menu
    view.bringSubviewToFront(navigationBar)
}

```

## Requirements

## Installation

PLMSideMenu is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PLMSideMenu"
```

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod "PLMSideMenu"
```

Then, run the following command:

```bash
$ pod install
```

## Author

tatsuhiro kanai, kanai.tatsuhiro@adways.net

## License

PLMSideMenu is available under the MIT license. See the LICENSE file for more info.
