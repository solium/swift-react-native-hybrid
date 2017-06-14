//
//  SwiftReactNativeBridge.m
//  SwiftReactNativeHybrid
//
//  Created by Jeremy Gale on 2017-06-13.
//  Copyright © 2017 Solium Capital Inc. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(NativeModuleCallSwift, NSObject)

RCT_EXTERN_METHOD(helloSwift:(NSString *)greeting)

@end

@interface RCT_EXTERN_MODULE(NativeModuleBroadcastToJavaScript, RCTEventEmitter)
@end
