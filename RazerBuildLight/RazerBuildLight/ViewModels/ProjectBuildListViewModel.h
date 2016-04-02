//
// Created by Benjamin Dobell on 10/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectBuildViewModel;
@class ProjectBuildList;
@class ProjectBuild;

@interface ProjectBuildListViewModel : NSObject

- (RACSignal *)projectBuildAdded;

- (RACSignal *)projectBuildRemoved;

- (RACSignal *)projectBuildChanged;

- (instancetype)init;

- (instancetype)initWithProjectBuildList:(ProjectBuildList *)projectBuildList;

- (NSUInteger)projectBuildCount;

- (ProjectBuildViewModel *)projectBuildViewModelAtIndex:(NSUInteger)index;

- (void)addProjectBuild:(ProjectBuild *)projectBuild;

- (void)removeProjectBuild:(ProjectBuild *)projectBuild;

- (RACSignal *)reloadWithRemoteProjectBuilds;

- (RACSignal *)refreshProjectBuildStatuses;

@end
