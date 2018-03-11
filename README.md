# SideMenu

[![Version](https://img.shields.io/cocoapods/v/SideMenuSwift.svg?style=flat-square)](http://cocoapods.org/pods/SideMenuSwift)
![Swift4](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat")
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/SideMenuSwift.svg?style=flat-square)](http://cocoapods.org/pods/SideMenuSwift)
[![Platform](https://img.shields.io/cocoapods/p/SideMenuSwift.svg?style=flat-square)](http://cocoapods.org/pods/SideMenuSwift)

## Overview

SideMenu is an easy-to-use container view controller written in Swift.

Besides all the features a *SideMenu* will have, it supports:

- Four types of status bar behaviors which adopts by most Apps
- Three different menu position
- Both storyboard and programmatically
- Caching the content view controller and lazy initialization
- Rubber band effect while panning

## Preview

Menu Position / Status Bar Behavior

| Above + None | Below + Slide |
| --- | --- |
| ![](https://raw.githubusercontent.com/kukushi/SideMenu/master/Images/Above%2BNone.gif) | ![](https://raw.githubusercontent.com/kukushi/SideMenu/master/Images/Below%2BSlide.gif) |

| SideBySide + Fade | SideBySide + HideOnMenu |
| --- | --- |
| ![](https://raw.githubusercontent.com/kukushi/SideMenu/master/Images/SideBySide%2BFade.gif) | ![](https://raw.githubusercontent.com/kukushi/SideMenu/master/Images/SideBySide%2BHideOnMenu.gif) |

We call the left/right view controller as the **menu** view controller, the central view controller as **content** view controller.

## Usages

### Storyboard

To set up `SideMenu` in storyboard:

1. Open the initial view controller's identity inspector. Change it's **Class** to `SideMenuController` and change it's **Module** to `SideMenuSwift`.
2. Set up the menu view controller and the initial content view controller in your Storyboard. Add a **Custom**  segue from the `SideMenuController` to both of them.
    - Change the menu segue's identifier to `SideMenu.Menu`, change it's **Class** to `SideMenuSegue` and change it's **Module** to `SideMenuSwift`.
    - Change the content segue's identifier to `SideMenu.Content`, change it's **Class** to `SideMenuSegue` and change it's **Module** to `SideMenuSwift`.
4. (Optional) If you want to use custom segue identifier:
   - Open the `SideMenuController`'s attribute inspector.
   - In the **Side Menu Controller** section, modify the *Content SegueID/Menu SegueID* to the desired value and change the corresponding segue's identifier.
5. It's done.

### Programmatically

To start the app with `SideMenu`:

```swift
import UIKit
import SideMenuSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let contentViewController = ...
        let menuViewController = ...
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SideMenuController(contentViewController: contentViewController, menuViewController: menuViewController)
        window?.makeKeyAndVisible()
        return true
    }
}
```

Use `sm_sideMenuController` provides in `UIViewController`'s  extension to access the parent `SideMenuController`:

```swift
viewController.sm_sideMenuController.revealMenu()
```

### Preferences

All the preferences of SideMenu can be found in `SideMenuController.preferences`. Its recommend to check out the `Example` to see how those options will take effect.

```swift
SideMenuController.preferences.basic.menuWidth = 240
SideMenuController.preferences.basic.statusBarBehavior = .hideOnMenu
SideMenuController.preferences.basic.position = .below
SideMenuController.preferences.basic.direction = .left
SideMenuController.preferences.basic.enablePanGesture = true
SideMenuController.preferences.basic.enablePanGesture = true
// Many other options.
```

### Caching Content

One of the biggest features of SideMenu is caching. 

```swift
# Cache the view controllers somewhere in your code
sideMenuController.cache(viewControllerGenerator: secondViewController, with: "1")
sideMenuController.cache(viewControllerGenerator: thirdViewController, with: "2")

# Switch to it when needed
sm_sideMenuController.setContentViewController(with: "1")
```

What about the content view controller initialized from the Storyboard? We can use the preferences to apply a default key for it!

```swift
SideMenuController.preferences.basic.defaultCacheKey = "0"
```

What if we can't want to load all the content view controllers so early? We can use lazy caching:

```Swift
sm_sideMenuController.cache(viewControllerGenerator: { self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") }, with: "1")
sm_sideMenuController.cache(viewControllerGenerator: { self.storyboard?.instantiateViewController(withIdentifier: "ThirdViewController") }, with: "2")
```

## Requirements

- Xcode 9
- iOS 9 or later

## Installation

## CocoaPods

To install `SideMenu` with [CocoaPods](http://cocoapods.org/), add the below line in your `Podfile`:

```ruby
pod 'SideMenuSwift'
# Note its not 'SideMenu'
```
### Carthage

To install `SideMenu` with [Carthage](https://github.com/Carthage/Carthage), add the below line in your `Cartfile`:

```
github "kukushi/SideMenu" "master"
```
## License

SideMenu is available under the MIT license. See the LICENSE file for more info.
