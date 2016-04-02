//
// Created by Benjamin Dobell on 13/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectBuildList.h"

@class ProjectBuild;

@interface Configuration : NSObject

@property (nonatomic, strong, readonly) ProjectBuildList *projectBuildList;

- (instancetype)initWithProjectBuildList:(ProjectBuildList *)projectBuildList;

@end
