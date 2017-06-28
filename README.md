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

### Xcode Build Phase

If you are adding React Native to an existing iOS project, there are is an Xcode build phase you need.

1. There is a RN  standard phase to package all the JavaScripts assets into a single file. This script was copied directly from the standard, `react-native init HelloWorld` project.

 * Xcode > Click Project > Click Build Phases
 * New Run Script Phase
 * Name: "Bundle React Native code and images"
 * Script:
   
   ```
   export NODE_BINARY=node
   ../node_modules/react-native/packager/react-native-xcode.sh
   ```

 This will ensure all the JS and images assets are bundled when building for release. It also provides an App Transport Security override (during Debug only) so that you can talk to your JavaScript packager running on your computer.

### Cocoapods

This app also demonstrates using Cocoapods, as is the norm for most iOS Swift projects. React Native is installed via Cocoapods, which is probably safe to say is not The Happy Path(™), especially with the use of `use_frameworks!` directive. React Native has some docs on this: [Integrating with Existing Apps](https://facebook.github.io/react-native/docs/integration-with-existing-apps.html) (be sure to click on Swift).

See [ios/Podfile](ios/Podfile) for the sample setup. Things to note:

* React Native itself is installed in `node_modules` and the Podspec for RN takes it from node_modules, not from the standard Cocoapods repo
* You need certain subspecs that you may not expect. This list frequently changes with new RN releases. For instance, RN 0.45 required the addition of the `DevSupport` podspec to get the RN Debug menu working in the Simulator. Keep an eye on those RN Release Notes!
* As the RN docs mention, you need to explicity include `Yoga` as it's own Pod.


#### Cocoapods Breakages

Fairly often when upgrading to a new version of React Native, some header will fail to compile, likely due to working differently with Cocoapods / `use_frameworks!` than including React Native directly as a sub-project.

As an instructive example, I'll walk you through the most recent one I found with this sample project and React Native 0.45. We were seeing compilation errors like:

```
'RCTAnimation/RCTValueAnimatedNode.h' file not found
```

Here is the React Native GitHub issue: [React Native Issue #13198](https://github.com/facebook/react-native/issues/13198)

Perusing the bug, you'll see people reporting that if you change the header imports to use quotes instead of angle brackets, it works. You'll also see reports of a fix, which didn't actually fix it. This is a trying, semi-frequent occurence when using React Native via Cocoapods.

Typically, I google these errors as much as possible and hope to find an RN issue with a workaround. Here is the one that is currently included in this sample project. There is a hack to add a postinstall script to package.json:

```
$ git diff 63402214a8e2f5bcc39ac74edbff62fdca00c099..327ee8d75b0d864e409cfda10bd0d40648fd8b41 package.json
index 148c3e1e..24aad398 100644
--- a/package.json
+++ b/package.json
@@ -3,6 +3,7 @@
        "version": "0.0.1",
        "private": true,
        "scripts": {
+                "postinstall": "sed -i '' 's\/#import <RCTAnimation\\/RCTValueAnimatedNode.h>\/#import \"RCTValueAnimatedNode.h\"\/' ./node_modules/react-native/Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h",
                "start": "node node_modules/react-native/local-cli/cli.js start",
                "test": "jest"
        },
```

This will manually change the imports after installing React Native via `yarn` or `npm`.

Hopefully this be removed in a future React Native release.

## Communication Between Swift and React Native

This sample app shows 3 ways to communicate between Swift and React Native.

See the React Native [Native Modules](http://facebook.github.io/react-native/releases/0.45/docs/native-modules-ios.html#native-modules) guide for more information.

### Infrastructure

* `BridgingHeader.h` - A standard Objective-C bridging header needed so you can access Objective-C functionality from Swift. It needs to be included in your build settings in the standard way. It's needed because all of the React Native native module magic is done in Objective-C, including macros.
* `SwiftReactNativeBridge.m` - An Objective-C file to declare the Native Modules that are used by JavaScript. 
 * You must used the `RCT_EXTERN_MODULE` macro for any Swift classes that will be called from JavaScript.
 * You must used the `RCT_EXTERN_METHOD` macro for any Swift methods that will be called from JavaScript. These must be in Objective-C format. 
* `NativeModule*.swift` - Example communication methods. A couple of notes:
 * You need a `@objc(MyClassNameHere)` annotation for the Swift class. Contrary to the React Native docs, you don't need the `objc(addEvent:location:date:)` around each Swift method you want to call. Doing it once for the class is sufficient.
 * You cannot have standard Swift style method signatures like `func helloSwift(greeting: String)`. Objective-C can have unnamed first arguments but Swift can't. So use an underscore for the name of the first parameters, e.g. `func helloSwift(_ greeting: String)`. Thanks to [Stack Overflow](https://stackoverflow.com/questions/39692230/got-is-not-a-recognized-objective-c-method-when-bridging-swift-to-react-native/39840952#39840952) for that one.
 * Note that these classes and methods are basically instantiated statically. They probably shouldn't have any state within them.
 *  Note that you will not be on the main thread when the Swift methods are called, so if updating the UI, you must dispatch onto the main thread using `DispatchQueue.main.async`.


### Method 1. Calling Swift from JavaScript

This approach documents how you can call a Swift function from JavaScript.

__How to See it in Action__

1. On the Second tab, enter some text in the text entry where it says "Enter text to send to Swift".
2. Press the Call Swift with Text button
3. Switch to the native First tab and see that the string passed from JavaScript has been displayed on the UILabel

__NativeModuleCallSwift.swift:__

 * This has a single Swift function that will get called statically, `helloSwift`.
 * The string will be passsed in as a parameter.
 * This updates the UILabel created in the Storyboard on the First tab, while ensuring it's on the main thread.

__ReactNativeTab.js:__

* `Button` has an `onPress` handler which calls `this.callIntoSwift()`. 
* `callIntoSwift` uses the RN NativeModule, then the NativeModuleCallSwift class we externed, then the method we externed.
* Easy!

### Method 2. Calling Swift from JavaScript, with a Callback

This approach documents how you can call a Swift function from JavaScript, and receive a callback once the native code has completed something.

__How to See it in Action__

1. On the Second tab, press the Toggle Swift Increment Button Enabled
2. Switch to the First tab and check the enabled state of the "Increment and Broadcast" button, i.e. is it greyed out or not?
3. Switch back to the Second tab and view the "Swift button currently enabled: false" Text, which has the result of the callback.

__NativeModuleJavaScriptCallback.swift:__

 * This has a single Swift function that will get called statically, `toggleSwiftButtonEnabled`
 * The only parameter is a callback function to JavaScript. Note: It's perfectly acceptable to have other parameters as well if the JS wants to pass them to Swift, like in Method 1.
 * This updates the `isEnabled` state of the button defined in the Storyboard.
 * It then calls back to JavaScript, with a dictionary with a predefined key name "swiftButtonEnabled" and the true/false boolean value.


__ReactNativeTab.js:__

* `Button` has an `onPress` handler which calls `toggleSwiftButtonEnabledState()`. 
* `toggleSwiftButtonEnabledState()` uses the RN NativeModule, then the NativeModuleJavaScriptCallback.swift class we externed, then the method we externed.
* For the callback, it takes in a `newStateDict` parameter of a dictionary. It then calls a the [RN setState method](https://facebook.github.io/react-native/docs/state.html) to update this Component's state property with the current button enabled state by accessing `newStateDict.swiftButtonEnabled`.
* A `Text` component in the `render()` function displays the current state of the Component that was updated by the callback.

          <Text style={{textAlign: 'center', marginTop: 30}}>
            Swift button currently enabled: {this.state.swiftButtonCurrentlyEnabled.toString()}
          </Text>
          

### Method 3. Broadcasting to JavaScript from Swift

This approach documents how you can broadcast data from Swift to JavaScript.

__How to See it in Action__

1. On the Second tab, make sure the Swift button is currently enabled.
2. On the First tab, press the "Increment and Broadcast" button.
3. Switch back to Second tab and see the how the current Swift counter value is displayed 

__NativeModuleBroadcastToJavaScript.swift:__

 * This class derives from `RCTEventEmitter` which is needed to broadcast to JavaScript.
 * `supportedEvents()` method is overridden to document when events can be broadcast to JS
 * `broadcastCounterChanged` is a static method that first gets the `RCTBridge` from the `AppDelegate` and then asks for the `NativeModuleBroadcastToJavaScript` module.
 * It uses that module and calls the `sendEvent` method to emit an event.
 * It passes in the predefined event name "SwiftCounterChanged" (which must be shared with the JavaScript) and a basic `[String: Any]` dictionary which contains the key ("count") and the count value passed into this method.
 
__ReactNativeTab.js:__

* The Component defines a `counterChangedEventEmitter` and `counterChangedEventSubscriber`. 
* `componentWillMount` calls `setupSwiftCounterChangedEventListener()` which initializes that emitter and subscriber. 
* It calls `addListener` for a callback that runs when Swift calls `sendEvent` with the "SwiftCounterChanged" event. This listener simply uses the React Native [RN setState method](https://facebook.github.io/react-native/docs/state.html) to update the Component's state with the current count that was broadcast from Swift.
* A `Text` component in the `render()` function displays the current state of the Component that was updated by the callback.

          <Text style={{textAlign: 'center', marginTop: 30}}>
            3. Swift counter value: {this.state.swiftCounterValue.toString()}
          </Text>
* `componentWillUnmount` removes the subscriber when this component is unloaded.

## Limitations

* I don't actually know if there is anything technically risky about this approach. Our team at Solium has been using it for quite a while, with a shipping iOS app, and have not discovered any show stoppers yet. Any feedback on limitations would be welcome, please reach out.
* There hasn't been any effort to keep the Android side of the app working, though the same techniques can definitely be applied.
* This approach doesn't demonstrate React Native views place as children of a native view that takes up only part of a screen. It should be doable, but it hasn't been explored.
* I'm not an expert JavaScript programmer, please excuse any sloppiness.

 
## FAQ

Q. Why is `node_modules/` checked in?

A. The main reason is that the React Native community movies so fast that within a few months, it's quite plausible this sample app will completely fail to build. This was my experience when looking for hybrid app examples on GitHub. Projects that were 1-year old no longer built. This way, it's a self-contained snapshot in time.

_Note:_ I'll do my best to keep this up to date with new RN release.


## License

This sample app is licensed under the [MIT License](LICENSE).
