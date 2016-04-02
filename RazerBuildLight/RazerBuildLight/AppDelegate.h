//
//  AppDelegate.h
//  RazerBuildLight
//
//  Created by Benjamin Dobell on 21/02/2016.
//  Copyright © 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

+ (RACSignal *)authenticatedClient;

@end

