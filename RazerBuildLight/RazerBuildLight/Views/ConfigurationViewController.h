//
// Created by Benjamin Dobell on 9/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface ConfigurationViewController : NSViewController

@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSButton *addButton;
@property (nonatomic, strong) IBOutlet NSButton *removeButton;

@end
