# Swift/React Native Hybrid

This is a small sample application that shows how to mix Swift and React Native within a single iOS app.

It also shows how to communicate back and forth between the two environments using Native Modules.

Lastly, it also shows how to use React Native with Cocoapods, which is not necessarily straightforward (and breaks relatively often).

## Why?

Many large companies like Airbnb, Facebook, and Instagram claim to have a hybrid native/React Native applications, but there are not many open source examples showing how to combine the two.

There are even less that combine Swift with React Native. Most of the RN sample code works with Objective-C

I wanted to create an extremely simple sample app - basically the Hello World of both Swift and React Native combined together.


## How to Build

### Prerequisites

1. Ensure your React Native environment is set up as described in the [RN Gettings Started](https://facebook.github.io/react-native/docs/getting-started.html) docs. (e.g. node installed, react-native-cli installed)
2. Ensure Xcode is installed including Command-Line Tools

### Run the App

1. From the root of the project, in the terminal, run `react-native start`. This will start the React packager.
1. Open `ios/SwiftReactNativeHybrid.xcworkspace` in Xcode
1. Click the Run button.

You're off!

## App Structure

This app makes use of a native UITabBarController with two tabs - one Swift and one React Native.

### App Entry

Like all React Native apps, it requires a native code entry point. However, this one is a typical Swift app.

* AppDelegate.swift uses the `@UIApplicationMain` annotation.
* The `Info.plist` does specify a LaunchScreen storyboard for the splash screen
* The `Info.plist` does not specify a `UIMainStoryboardFile` key. This was done so that the `TabBarController` could be created programatically in the AppDelegate and assigned to the UIWindow `rootViewController`.

### React Native Bridge Interface

* In AppDelegate.swift, the  `application(_:,didFinishLaunchingWithOptions:)` method loads the JavaScript bundle from `index.ios.js` in the standard way for a React Native app. However, instead of creating a `RCTRootView` it creates an `RCTBridge` which will be used when the RN views are loaded.


### Native Tab Bar Controller

The Swift AppDelegate code creates a native `TabBarController` which is a basic subclass of `UITabBarController`. It creates two tabs:

1. `FirstViewController` is an native Swift view controller instantiated from a Storyboard in the standard way.
2. `Second` tab is entirely defined in JavaScript. It is created by making a vanilla `UIViewController`. Its root view is a React Native `RCTRootView` created as follows:

 ```
 let rootView = RCTRootView(bridge: delegate.bridge!,
                            moduleName: "ReactNativeTab",
                            initialProperties: nil)
 ```
  
 As you can see, it was initialized using the `RCTBridge` created and stored in the `AppDelegate`. It also specifies a specifc `moduleName` that must match up with the JavaScript call found in `ios.hybrid.js`.


These two tabs can optionally talk to each other via different means specified below.

### React Native Structure

* The creation of the `RCTBridge` in `AppDelegate` will load and execute the code in `index.ios.js`, which can be used to set up any global state needed for the RN app such as a Redux store and `Provider`. 
* As you can see in this sample app, there is very little in that file, just an empty `View` which never appears on screen.
* The most important line is 

 ```
 AppRegistry.registerComponent('ReactNativeTab', () => ReactNativeTab);
 ```
 
 which registers a new top-level module which is used when the `Second` tab is created in `TabBarController.swift`
* `ReactNativeTab.js` contains all of the JS code for the 2nd tab. Note this is a full screen view, including content that will be hidden behind the native Swift tab bar. For this reason, it uses a `StyleSheet` where the bottom 49 pixels of the tab bar are covered up by a `tabContentBottomSpacer`.


## Communication Between Swift and React Native

This sample app shows 3 ways to communicate between Swift and React Native.

See the React Native [Native Modules](http://facebook.github.io/react-native/releases/0.45/docs/native-modules-ios.html#native-modules) guide for more information.

### Infrastructure

* `BridgingHeader.h` - A standard Objective-C bridging header needed so you can access Objective-C functionality from Swift. It needs to be included in your build settings in the standard way. It's needed because all of the React Native native module magic is done in Objective-C, including macros.
* `SwiftReactNativeBridge.m` - An Objective-C file to declare the Native Modules that are used by JavaScript. 
 * You must used the `RCT_EXTERN_MODULE` macro for any Swift classes that will be called from JavaScript.
 * You must used the `RCT_EXTERN_METHOD` macro for any Swift methods that will be called from JavaScript. These must be in Objective-C format. 
* `NativeModule*.swift` - Example communication methods. A couple of notes:
 * You need a `@objc(MyClassNameHere)` annotatino for the Swift class. Contrary to the React Native docs, you don't need the `objc(addEvent:location:date:)` around each Swift method you want to call. Doing it once for the class is sufficient.
 * You cannot have standard Swift style method signatures like `func helloSwift(greeting: String)`. Objective-C can have unnamed first arguments but Swift can't. So use an underscore for the name of the first parameters, e.g. `func helloSwift(_ greeting: String)`. Thanks to [Stack Overflow](https://stackoverflow.com/questions/39692230/got-is-not-a-recognized-objective-c-method-when-bridging-swift-to-react-native/39840952#39840952) for that one.
 * Note that these classes and methods are basically instantiated statically. They probably shouldn't have any state within them.


### Method 1. Calling Swift from JavaScript

TODO: Document

### Method 2. Calling Swift from JavaScript, with a Callback

TODO: Document

### Method 3. Broadcasting to JavaScript from Swift

TODO: Document

## Limitations

* I don't actually know if there is anything technically risky about this approach. Our team at Solium has been using it for quite a while, with a shipping iOS app, and have not discovered any show stoppers yet. Any feedback on limitations would be welcome, please reach out.
* There hasn't been any effort to keep the Android side of the app working, though the same techniques can definitely be applied.
* This approach doesn't demonstrate React Native views place as children of a native view that takes up only part of a screen. It should be doable, but it hasn't been explored.
* I'm not an expert JavaScript programmer, please excuse any sloppliness.

 
## FAQ

Q. Why is `node_modules/` checked in?

A. The main reason is that the React Native community movies so fast that within a few months, it's quite plausible this sample app will completely fail to build. This was my experience when looking for hybrid app examples on GitHub. Projects that were 1-year old no longer built. This way, it's a self-contained snapshot in time.

_Note:_ I'll do my best to keep this up to date with new RN release.


## TODO

- Document the communication mechanisms
- Fix flow errors in ReactNativeTab.js
- Document the Xcode build scripts
- Document Cocoapods and hacks needed for React

## License

This sample app is licensed under the [MIT License](LICENSE).
