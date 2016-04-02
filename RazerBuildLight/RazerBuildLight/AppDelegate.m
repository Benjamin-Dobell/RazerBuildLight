//
//  AppDelegate.m
//  RazerBuildLight
//
//  Created by Benjamin Dobell on 21/02/2016.
//  Copyright © 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <OctoKit/Octokit.h>
#import "AppDelegate.h"

NSString *const kGithubRawLoginKey = @"github_raw_login";
NSString *const kGithubTokenKey = @"github_token";

@interface AppDelegate ()

@property(weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

+ (RACSignal *)authenticatedClient
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *rawLogin = [userDefaults objectForKey:kGithubRawLoginKey];
	NSString *token = [userDefaults objectForKey:kGithubTokenKey];

	if (rawLogin && token)
	{
		OCTUser *user = [OCTUser userWithRawLogin:rawLogin server:[OCTServer dotComServer]];
		OCTClient *authenticatedClient = [OCTClient authenticatedClientWithUser:user token:token];
		return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
			[subscriber sendNext:authenticatedClient];
			[subscriber sendCompleted];
			return nil;
		}];
	}
	else
	{
		OCTClientAuthorizationScopes scopes = OCTClientAuthorizationScopesRepositoryStatus | OCTClientAuthorizationScopesRepositoryHooksAdmin;
		RACSignal *signal = [OCTClient signInToServerUsingWebBrowser:[OCTServer dotComServer] scopes:scopes];
		return [signal doNext:^(OCTClient *authenticatedClient) {
			[userDefaults setObject:[[authenticatedClient user] rawLogin] forKey:kGithubRawLoginKey];
			[userDefaults setObject:[authenticatedClient token] forKey:kGithubTokenKey];
		}];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

	[OCTClient setClientID:@"5c72cb1ee6d456af5b49" clientSecret:@"e23b77c0448603650e3609d6ab5176f2786d7a46"];

	[NSApp activateIgnoringOtherApps:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// Insert code here to tear down your application
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];

	if ([[url host] isEqualToString:@"oauth"])
	{
		if ([[url path] isEqualToString:@"/github"])
		{
			[OCTClient completeSignInWithCallbackURL:url];
		}
	}
}

@end
