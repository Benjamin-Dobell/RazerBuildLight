//
// Created by Benjamin Dobell on 10/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <objc/runtime.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSTableCellView+RACSignalSupport.h"

@implementation NSTableCellView (RACSignalSupport)

- (RACSignal *)rac_prepareForReuseSignal {
	RACSubject *subject = objc_getAssociatedObject(self, @"rac_prepareForReuseSignal");

	if (subject != nil) {
		return subject;
	}

	subject = [RACSubject subject];

	objc_setAssociatedObject(self, _cmd, subject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return subject;
}

- (void)rac_prepareForReuse
{
	RACSubject *subject = objc_getAssociatedObject(self, @"rac_prepareForReuseSignal");
	[subject sendNext:RACUnit.defaultUnit];
}

@end
