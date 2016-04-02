//
// Created by Benjamin Dobell on 18/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const WebHookManagerErrorDomain;

@interface WebHookManager : NSObject

+ (instancetype)sharedInstance;

- (RACSignal *)connect;

- (RACSignal *)dataForHookWithId:(NSString *)hookId;

@end
