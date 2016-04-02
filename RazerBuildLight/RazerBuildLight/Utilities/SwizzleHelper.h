//
// Created by Benjamin Dobell on 16/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwizzleHelper : NSObject

+ (void)swizzleInstanceMethod:(SEL)fromSel toSelector:(SEL)toSel inClass:(Class)klass;
+ (void)swizzleClassMethod:(SEL)fromSel toSelector:(SEL)toSel inClass:(Class)klass;

@end
