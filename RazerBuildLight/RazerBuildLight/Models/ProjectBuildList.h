//
// Created by Benjamin Dobell on 17/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectBuild;
@class RACSignal;

@interface ProjectBuildList : NSObject <NSCoding, NSFastEnumeration>

- (RACSignal *)projectBuildAdded;

- (RACSignal *)projectBuildRemoved;

- (RACSignal *)projectBuildChanged;

- (RACSignal *)projectBuildAddedAtIndex;

- (RACSignal *)projectBuildRemovedAtIndex;

- (RACSignal *)projectBuildChangedAtIndex;

- (instancetype)init;

- (instancetype)initWithProjectBuilds:(id<NSFastEnumeration>)projectBuilds;

- (ProjectBuild *)objectAtIndexedSubscript:(NSUInteger)idx;

- (NSUInteger)projectBuildCount;

- (ProjectBuild *)projectBuildAtIndex:(NSUInteger)index;

- (BOOL)containsProjectBuild:(ProjectBuild *)projectBuild;

- (void)addProjectBuild:(ProjectBuild *)projectBuild;

- (void)removeProjectBuild:(ProjectBuild *)projectBuild;

- (void)removeAllProjectBuilds;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;

@end
