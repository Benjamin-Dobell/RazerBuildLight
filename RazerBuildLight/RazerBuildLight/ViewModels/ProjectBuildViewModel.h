//
// Created by Benjamin Dobell on 10/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCTRepository;
@class OCTClient;
@class ProjectBuild;
@class ProjectBuildListViewModel;

@interface ProjectBuildViewModel : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *status;

- (instancetype)initWithProjectBuild:(ProjectBuild *)projectBuild;

- (void)addToProjectBuildListViewModel:(ProjectBuildListViewModel *)projectBuildListViewModel;

- (void)removeFromProjectBuildListViewModel:(ProjectBuildListViewModel *)projectBuildListViewModel;

- (RACSignal *)refreshStatus;

@end
