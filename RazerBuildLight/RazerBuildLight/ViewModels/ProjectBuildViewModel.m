//
// Created by Benjamin Dobell on 10/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <OctoKit/OCTRepository.h>
#import <OctoKit/OCTClient.h>
#import <OctoKit/OCTClient+Repositories.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <OctoKit/OCTBranch.h>
#import "ProjectBuildViewModel.h"
#import "ProjectBuild.h"
#import "Configuration.h"
#import "ProjectBuildListViewModel.h"
#import "ConfigurationViewModel.h"
#import "AppDelegate.h"

@interface ProjectBuildViewModel ()

@property (nonatomic, strong) ProjectBuild *projectBuild;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;

@end

@implementation ProjectBuildViewModel

- (instancetype)initWithProjectBuild:(ProjectBuild *)projectBuild
{
	if ((self = [super init]))
	{
		[self setProjectBuild:projectBuild];

		RACSignal *userName = RACObserve(projectBuild, repository.ownerLogin);
		RACSignal *repositoryName = RACObserve(projectBuild, repository.name);
		RACSignal *branchName = RACObserve(projectBuild, branch.name);

		RAC(self, title) = [RACSignal combineLatest:@[userName, repositoryName, branchName]
											 reduce:^id(NSString *user, NSString *repository, NSString *branch) {
			return [NSString stringWithFormat:@"%@/%@:%@", user, repository, branch];
		}];
		RAC(self, status) = RACObserve(projectBuild, status);
	}

	return self;
}

- (void)addToProjectBuildListViewModel:(ProjectBuildListViewModel *)projectBuildListViewModel
{
	[projectBuildListViewModel addProjectBuild:[self projectBuild]];
}

- (void)removeFromProjectBuildListViewModel:(ProjectBuildListViewModel *)projectBuildListViewModel
{
	[projectBuildListViewModel removeProjectBuild:[self projectBuild]];
}

- (RACSignal *)refreshStatus
{
	ProjectBuild *projectBuild = [self projectBuild];
	OCTRepository *repository = [projectBuild repository];
	OCTBranch *branch = [projectBuild branch];

	return [[AppDelegate authenticatedClient] flattenMap:^RACStream *(OCTClient *client) {
		return [[client fetchCommitCombinedStatusForRepositoryWithName:[repository name] owner:[repository ownerLogin] reference:[branch name]] map:^id(OCTCommitCombinedStatus *status) {
			NSString *state = [status countOfStatuses] > 0 ? [status state] : OCTCommitStatusStateError;
			[projectBuild setStatus:state];
			return state;
		}];
	}];
}

@end
