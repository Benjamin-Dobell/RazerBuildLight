//
// Created by Benjamin Dobell on 10/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Octokit/Octokit.h>
#import "ProjectBuildListViewModel.h"
#import "ProjectBuildViewModel.h"
#import "AppDelegate.h"
#import "ProjectBuild.h"
#import "ProjectBuildList.h"

@interface ProjectBuildListViewModel ()

@property (nonatomic, strong) ProjectBuildList *projectBuildList;

@end

@implementation ProjectBuildListViewModel

- (RACSignal *)projectBuildAdded
{
	return [[self projectBuildList] projectBuildAdded];
}

- (RACSignal *)projectBuildRemoved
{
	return [[self projectBuildList] projectBuildRemoved];
}

- (RACSignal *)projectBuildChanged
{
	return [[self projectBuildList] projectBuildChanged];
}

- (RACSignal *)projectBuildChangedAtIndex
{
	return [[self projectBuildList] projectBuildChangedAtIndex];
}

- (instancetype)init
{
	return [self initWithProjectBuildList:[[ProjectBuildList alloc] init]];
}

- (instancetype)initWithProjectBuildList:(ProjectBuildList *)projectBuildList
{
	if ((self = [super init]))
	{
		[self setProjectBuildList:projectBuildList];
	}

	return self;
}

- (NSUInteger)projectBuildCount
{
	return [[self projectBuildList] projectBuildCount];
}

- (ProjectBuildViewModel *)projectBuildViewModelAtIndex:(NSUInteger)index
{
	return [[ProjectBuildViewModel alloc] initWithProjectBuild:[self projectBuildList][index]];
}

- (void)addProjectBuild:(ProjectBuild *)projectBuild
{
	[[self projectBuildList] addProjectBuild:projectBuild];
}

- (void)removeProjectBuild:(ProjectBuild *)projectBuild
{
	[[self projectBuildList] removeProjectBuild:projectBuild];
}

- (RACSignal *)reloadWithRemoteProjectBuilds
{
	return [[[[AppDelegate authenticatedClient] flattenMap:^RACStream *(OCTClient *client) {
		return [[client fetchUserRepositories] flattenMap:^RACStream *(OCTRepository *repository) {
			return [[client fetchBranchesForRepositoryWithName:[repository name] owner:[repository ownerLogin]] flattenMap:^RACStream *(OCTBranch *branch) {
				return [[client fetchCommitCombinedStatusForRepositoryWithName:[repository name] owner:[repository ownerLogin] reference:[branch name]] map:^id(OCTCommitCombinedStatus *status) {
					NSDictionary *properties = @{
						@"repository" : repository,
						@"branch" : branch,
						@"status" : [status countOfStatuses] > 0 ? [status state] : OCTCommitStatusStateError
					};
					return [[ProjectBuild alloc] initWithDictionary:properties error:NULL];
				}];
			}];
		}];
	}] collect] doNext:^(NSArray *projectBuilds) {
		NSArray *sortedProjectBuilds = [projectBuilds sortedArrayUsingComparator:^NSComparisonResult(ProjectBuild *build1, ProjectBuild *build2) {
			ProjectBuildViewModel *view1 = [[ProjectBuildViewModel alloc] initWithProjectBuild:build1];
			ProjectBuildViewModel *view2 = [[ProjectBuildViewModel alloc] initWithProjectBuild:build2];
			return [[view1 title] caseInsensitiveCompare:[view2 title]];
		}];

		[[self projectBuildList] removeAllProjectBuilds];

		for (ProjectBuild *projectBuild in sortedProjectBuilds)
		{
			[[self projectBuildList] addProjectBuild:projectBuild];
		}
	}];
}

- (RACSignal *)refreshProjectBuildStatuses
{
	NSMutableArray *refreshSignals = [NSMutableArray arrayWithCapacity:[self projectBuildCount]];

	for (NSUInteger i = 0, count = [self projectBuildCount]; i < count; i++)
	{
		RACSignal *refreshSignal = [[self projectBuildViewModelAtIndex:i] refreshStatus];
		[refreshSignals addObject:refreshSignal];
	}

	return [RACSignal zip:refreshSignals reduce:^id {
		return nil;
	}];
}

@end
