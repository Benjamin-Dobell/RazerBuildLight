//
// Created by Benjamin Dobell on 15/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@class ProjectBuild;
@class Configuration;
@class ProjectBuildViewModel;
@class ProjectBuildListViewModel;

@interface ConfigurationViewModel : NSObject

- (RACSignal *)aggregatedStatus;

- (ProjectBuildListViewModel *)projectBuildListViewModel;

@end
