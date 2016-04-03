//
// Created by Benjamin Dobell on 17/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ProjectBuild.h"
#import "ProjectBuildList.h"

static NSString *const ProjectBuildsKey = @"projectBuilds";

@interface ProjectBuildList ()

@property (nonatomic, strong) NSMutableOrderedSet<ProjectBuild *> *projectBuilds;

@property (nonatomic, strong) RACSubject *projectBuildAdded;
@property (nonatomic, strong) RACSubject *projectBuildRemoved;
@property (nonatomic, strong) RACSubject *projectBuildChanged;

@property (nonatomic, strong) RACSubject *projectBuildAddedAtIndex;
@property (nonatomic, strong) RACSubject *projectBuildRemovedAtIndex;
@property (nonatomic, strong) RACSubject *projectBuildChangedAtIndex;

@end

@implementation ProjectBuildList

- (void)monitorProjectBuildChangesAtIndex:(NSUInteger)index
{
	ProjectBuild *projectBuild = [[self projectBuilds] objectAtIndex:index];
	RACTuple *tuple = [RACTuple tupleWithObjects:projectBuild, @(index), nil];

	RACSignal *removed = [[self projectBuildRemoved] filter:^BOOL(ProjectBuild *removedProjectBuild) {
		return removedProjectBuild == projectBuild;
	}];

	[[[RACSignal merge:@[
		[RACObserve(projectBuild, repository) skip:1],
		[RACObserve(projectBuild, branch) skip:1],
		[RACObserve(projectBuild, status) skip:1]
	]] takeUntil:removed] subscribeNext:^(id x) {
		[(RACSubject *)[self projectBuildChangedAtIndex] sendNext:tuple];
		[(RACSubject *)[self projectBuildChanged] sendNext:projectBuild];
	}];
}

- (instancetype)init
{
	return [self initWithProjectBuilds:nil];
}

- (instancetype)initWithProjectBuilds:(id<NSFastEnumeration>)projectBuilds
{
	if ((self = [super init]))
	{
		NSMutableOrderedSet<ProjectBuild *> *projectBuildSet = [NSMutableOrderedSet orderedSet];

		for (ProjectBuild *projectBuild in projectBuilds)
		{
			[projectBuildSet addObject:projectBuild];
		}

		[self setProjectBuilds:projectBuildSet];

		[self setProjectBuildAdded:[[RACSubject alloc] init]];
		[self setProjectBuildRemoved:[[RACSubject alloc] init]];
		[self setProjectBuildChanged:[[RACSubject alloc] init]];
		[self setProjectBuildAddedAtIndex:[[RACSubject alloc] init]];
		[self setProjectBuildRemovedAtIndex:[[RACSubject alloc] init]];
		[self setProjectBuildChangedAtIndex:[[RACSubject alloc] init]];

		for (NSUInteger i = 0, count = [[self projectBuilds] count]; i < count; i++)
		{
			[self monitorProjectBuildChangesAtIndex:i];
		}
	}

	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	return [self initWithProjectBuilds:[coder decodeObjectForKey:ProjectBuildsKey]];
}

- (void)dealloc
{
	[(RACSubject *)[self projectBuildAdded] sendCompleted];
	[(RACSubject *)[self projectBuildRemoved] sendCompleted];
	[(RACSubject *)[self projectBuildChanged] sendCompleted];

	[(RACSubject *)[self projectBuildAddedAtIndex] sendCompleted];
	[(RACSubject *)[self projectBuildRemovedAtIndex] sendCompleted];
	[(RACSubject *)[self projectBuildChangedAtIndex] sendCompleted];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self projectBuilds] forKey:ProjectBuildsKey];
}

- (NSUInteger)projectBuildCount
{
	return [[self projectBuilds] count];
}

- (BOOL)containsProjectBuild:(ProjectBuild *)projectBuild
{
	return [[self projectBuilds] containsObject:projectBuild];
}

- (void)addProjectBuild:(ProjectBuild *)projectBuild
{
	[[self projectBuilds] addObject:projectBuild];

	NSUInteger index = [[self projectBuilds] indexOfObject:projectBuild];
	RACTuple *tuple = [RACTuple tupleWithObjects:projectBuild, @(index), nil];

	[(RACSubject *)[self projectBuildAddedAtIndex] sendNext:tuple];
	[(RACSubject *)[self projectBuildAdded] sendNext:projectBuild];

	[self monitorProjectBuildChangesAtIndex:index];
}

- (void)removeProjectBuild:(ProjectBuild *)projectBuild
{
	NSUInteger index = [[self projectBuilds] indexOfObject:projectBuild];

	if (index != NSNotFound)
	{
		[[self projectBuilds] removeObjectAtIndex:index];

		RACTuple *tuple = [RACTuple tupleWithObjects:projectBuild, @(index), nil];

		[(RACSubject *)[self projectBuildRemovedAtIndex] sendNext:tuple];
		[(RACSubject *)[self projectBuildRemoved] sendNext:projectBuild];
	}
}

- (void)removeAllProjectBuilds
{
	ProjectBuild *projectBuild;

	while ((projectBuild = [[self projectBuilds] lastObject]))
	{
		[self removeProjectBuild:projectBuild];
	}
}

- (ProjectBuild *)projectBuildAtIndex:(NSUInteger)index
{
	return [[self projectBuilds] objectAtIndex:index];
}

- (ProjectBuild *)objectAtIndexedSubscript:(NSUInteger)idx
{
	return [self projectBuildAtIndex:idx];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
	return [[self projectBuilds] countByEnumeratingWithState:state objects:buffer count:len];
}

@end
