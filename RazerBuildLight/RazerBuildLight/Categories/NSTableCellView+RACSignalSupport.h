//
// Created by Benjamin Dobell on 10/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class RACSignal;

@interface NSTableCellView (RACSignalSupport)

@property (nonatomic, strong, readonly) RACSignal *rac_prepareForReuseSignal;

// Must be called manually, triggers rac_prepareForReuseSignal.
- (void)rac_prepareForReuse;

@end
