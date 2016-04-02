//
// Created by Benjamin Dobell on 13/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <AppKit/AppKit.h>

@class ConfigurationViewModel;
@class ProjectBuildListViewModel;

@interface SelectProjectViewController : NSViewController

@property (nonatomic, strong, readonly) ProjectBuildListViewModel *projectBuildListViewModel;

@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSButton *addButton;

@property (nonatomic, strong) ConfigurationViewModel *configurationViewModel;

@end
