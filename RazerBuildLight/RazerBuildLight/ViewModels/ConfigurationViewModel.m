//
// Created by Benjamin Dobell on 15/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <OctoKit/OctoKit.h>
#import "ConfigurationViewModel.h"
#import "ProjectBuild.h"
#import "Configuration.h"
#import "ProjectBuildListViewModel.h"
#import "AppDelegate.h"
#import "WebHookManager.h"

static NSString *const ProjectBuildListKey = @"ProjectBuildList";

@interface ConfigurationViewModel ()

@property (nonatomic, strong) RACSubject *aggregatedStatus;

@property (nonatomic, strong) Configuration *configuration;

@end

@implementation ConfigurationViewModel

- (NSString *)statusForBranch:(OCTBranch *)branch fromHookData:(NSDictionary *)data
{
	NSString *branchName = [branch name];
	NSString *branchSha = nil;

	for (NSDictionary *branchData in data[@"branches"])
	{
		if ([branchName isEqualTo:branchData[@"name"]])
		{
			branchSha = branchData[@"commit"][@"sha"];
			break;
		}
	}

	if ([branchSha isEqualTo:data[@"sha"]])
	{
		return data[@"state"];
	}

	return nil;
}

- (RACSignal *)createStatusHookForProjectBuild:(ProjectBuild *)projectBuild withClient:(OCTClient *)client
{
	NSString *uuid = [[NSUUID UUID] UUIDString];
	NSURL *hookUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://sockethook.geapp.io/hook/%@", uuid]];
	RACSignal *request = [client createWebHookForEvents:@[OCTHookEventStatus]
												 active:YES
												withURL:hookUrl
											contentType:OCTWebHookContentTypeURLEncodedForm
												 secret:nil
											insecureSSL:NO
										   inRepository:[projectBuild repository]];
	return request;
}

- (void)monitorStatusOfProjectBuild:(ProjectBuild *)projectBuild
{
	RACSignal *removed = [[[self projectBuildListViewModel] projectBuildRemoved] filter:^BOOL(ProjectBuild *removedProjectBuild) {
		return removedProjectBuild == projectBuild;
	}];

	[[[[[[[AppDelegate authenticatedClient] flattenMap:^RACStream *(OCTClient *client) {
		return [[[[[[client fetchHooksForRepository:[projectBuild repository]] filter:^BOOL(OCTHook *hook) {
			return [hook isKindOfClass:[OCTWebHook class]];
		}] filter:^BOOL(OCTWebHook *webHook) {
			NSURL *url = [webHook hookURL];
			return [[url host] isEqualToString:@"sockethook.geapp.io"] && [[url path] hasPrefix:@"/hook/"];
		}] collect] map:^id(NSArray *webHooks) {
			return [webHooks firstObject];
		}] flattenMap:^RACStream *(OCTWebHook *webHook) {
			if (webHook)
			{
				return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
					[subscriber sendNext:webHook];
					[subscriber sendCompleted];
					return nil;
				}];
			}
			else
			{
				return [self createStatusHookForProjectBuild:projectBuild withClient:client];
			}
		}];
	}] flattenMap:^RACStream *(OCTWebHook *webHook) {
		NSString *hookId = [[[[webHook hookURL] path] componentsSeparatedByString:@"/"] lastObject];
		return [[WebHookManager sharedInstance] dataForHookWithId:hookId];
	}] map:^id(NSDictionary *data) {
		return [self statusForBranch:[projectBuild branch] fromHookData:data];
	}] ignore:nil] takeUntil:removed] subscribeNext:^(NSString *status) {
		[projectBuild setStatus:status];
	} error:^(NSError *error) {
		// TODO: Something
	}];
}

- (void)monitorStatusOfProjectBuilds:(id<NSFastEnumeration>)projectBuilds
{
	for (ProjectBuild *projectBuild in projectBuilds)
	{
		[self monitorStatusOfProjectBuild:projectBuild];
	}
}

- (instancetype)init
{
	if ((self = [super init]))
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSData *restoreData = [userDefaults dataForKey:ProjectBuildListKey];
		ProjectBuildList *projectBuildList = restoreData ? [NSKeyedUnarchiver unarchiveObjectWithData:restoreData] : [[ProjectBuildList alloc] init];

		Configuration *configuration = [[Configuration alloc] initWithProjectBuildList:projectBuildList];
		[self setConfiguration:configuration];

		[self monitorStatusOfProjectBuilds:projectBuildList];

		[[projectBuildList projectBuildAdded] subscribeNext:^(ProjectBuild *projectBuild) {
			[self monitorStatusOfProjectBuild:projectBuild];
		}];

		[[RACSignal merge:@[
			[projectBuildList projectBuildAdded],
			[projectBuildList projectBuildRemoved],
			[projectBuildList projectBuildChanged],
		]] subscribeNext:^(id x) {
			NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:projectBuildList];
			[userDefaults setObject:saveData forKey:ProjectBuildListKey];
			[userDefaults synchronize];
		}];

		__block void(^connectWebHooks)(NSError *) = [^(NSError *error) {
			[[[WebHookManager sharedInstance] connect] subscribeError:connectWebHooks];
		} copy];

		connectWebHooks(nil);

		[self setAggregatedStatus:[[RACSubject alloc] init]];
		[self monitorAggregatedStatus];
	}

	return self;
}

- (void)dealloc
{
	[(RACSubject *)[self aggregatedStatus] sendCompleted];
}

- (void)monitorAggregatedStatus
{
	ProjectBuildList *projectBuildList = [[self configuration] projectBuildList];
	NSMutableArray *statusChangeSignals = [NSMutableArray array];

	for (ProjectBuild *projectBuild in projectBuildList)
	{
		[statusChangeSignals addObject:RACObserve(projectBuild, status)];
	}

	RACSignal *projectBuildListChanged = [RACSignal merge:@[
		[projectBuildList projectBuildAdded],
		[projectBuildList projectBuildRemoved]
	]];

	__weak ConfigurationViewModel *weak_self = self;

	RACSignal *combinedStatus;

	if ([statusChangeSignals count] > 1)
	{
		combinedStatus = [RACSignal combineLatest:statusChangeSignals reduce:^(NSString *reducedStatus, NSString *status) {
			if ([reducedStatus isEqualToString:OCTCommitStatusStatePending] || [status isEqualToString:OCTCommitStatusStatePending])
			{
				return OCTCommitStatusStatePending;
			}

			if ([reducedStatus isEqualToString:OCTCommitStatusStateError] || [status isEqualToString:OCTCommitStatusStateError])
			{
				return OCTCommitStatusStateError;
			}

			if ([reducedStatus isEqualToString:OCTCommitStatusStateFailure] || [status isEqualToString:OCTCommitStatusStateFailure])
			{
				return OCTCommitStatusStateFailure;
			}

			if ([reducedStatus isEqualToString:OCTCommitStatusStateSuccess] || [status isEqualToString:OCTCommitStatusStateSuccess])
			{
				return OCTCommitStatusStateSuccess;
			}

			return OCTCommitStatusStateError;
		}];
	}
	else if ([statusChangeSignals count] == 1)
	{
		combinedStatus = statusChangeSignals[0];
	}
	else
	{
		combinedStatus = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
			[subscriber sendNext:OCTCommitStatusStateError];
			[subscriber sendCompleted];
			return nil;
		}];
	}

	[[combinedStatus takeUntil:projectBuildListChanged] subscribeNext:^(NSString *status) {
		[(RACSubject *)[self aggregatedStatus] sendNext:status];
	} completed:^() {
		[weak_self monitorAggregatedStatus];
	}];
}

- (ProjectBuildListViewModel *)projectBuildListViewModel
{
	return [[ProjectBuildListViewModel alloc] initWithProjectBuildList:[[self configuration] projectBuildList]];
}

@end
