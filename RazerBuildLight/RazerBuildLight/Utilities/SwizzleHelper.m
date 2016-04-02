//
// Created by Benjamin Dobell on 16/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import "SwizzleHelper.h"
#import <objc/runtime.h>

@implementation SwizzleHelper

+ (void)swizzleInstanceMethod:(SEL)fromSel toSelector:(SEL)toSel inClass:(Class)klass
{
	Method originalMethod = class_getInstanceMethod(klass, fromSel);
	Method swizzledMethod = class_getInstanceMethod(klass, toSel);

	BOOL didAddMethod = class_addMethod(klass, fromSel,
		method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

	if (didAddMethod)
	{
		class_replaceMethod(klass,
			toSel,
			method_getImplementation(originalMethod),
			method_getTypeEncoding(originalMethod));
	}
	else
	{
		method_exchangeImplementations(originalMethod, swizzledMethod);
	}
}


+ (void)swizzleClassMethod:(SEL)fromSel toSelector:(SEL)toSel inClass:(Class)klass
{
	Class metaclass = object_getClass(klass);
	[self swizzleInstanceMethod:fromSel toSelector:toSel inClass:metaclass];
}

@end
