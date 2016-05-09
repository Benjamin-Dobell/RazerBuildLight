//
// Created by Benjamin Dobell on 18/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SocketRocket/SRWebSocket.h>
#import "WebHookManager.h"

NSString *const WebHookManagerErrorDomain = @"au.com.glassechidna.RazerBuildLight.WebHookManager";

@interface WebHookManager () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;

@property (nonatomic, strong) NSMutableSet *monitoredHookIds;

@property (nonatomic, assign, getter=isConnected) BOOL connected;
@property (nonatomic, strong) RACSubject *connectSubject;
@property (nonatomic, strong) RACSubject *hookSubject;

@end

@implementation WebHookManager

+ (instancetype)sharedInstance
{
	static WebHookManager *webHookManager;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		webHookManager = [[WebHookManager alloc] init];
	});

	return webHookManager;
}

- (void)registerForHookWithId:(NSString *)hookId
{
	if (![[self monitoredHookIds] containsObject:hookId])
	{
		[[self monitoredHookIds] addObject:hookId];
	}

	if ([self isConnected])
	{
		NSDictionary *registerDictionary = @{
			@"type" : @"register",
			@"id" : hookId
		};
		NSData *data = [NSJSONSerialization dataWithJSONObject:registerDictionary options:0 error:NULL];
		[[self webSocket] send:data];
	}
}

- (instancetype)init
{
	if ((self = [super init]))
	{
		[self setHookSubject:[[RACSubject alloc] init]];
		[self setMonitoredHookIds:[NSMutableSet set]];
	}

	return self;
}

- (RACSignal *)connect
{
	return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
		@synchronized (self)
		{
			if (![self connectSubject])
			{
				[self setConnectSubject:[[RACSubject alloc] init]];

				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://sockethook.geapp.io"]];
				SRWebSocket *socket = [[SRWebSocket alloc] initWithURLRequest:request];
				[socket setDelegate:self];
				[socket open];
				[self setWebSocket:socket];
			}
		}

		[subscriber sendNext:[self connectSubject]];
		[subscriber sendCompleted];

		if ([[self webSocket] readyState] == SR_OPEN)
		{
			[[self connectSubject] sendNext:nil];
		}

		return nil;
	}] flatten];
}

- (RACSignal *)dataForHookWithId:(NSString *)hookId
{
	hookId = [hookId lowercaseString];

	return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
		@synchronized (self)
		{
			if (![[self monitoredHookIds] containsObject:hookId])
			{
				[self registerForHookWithId:hookId];
			}
		}

		RACSignal *hookDataSignal = [[[self hookSubject] filter:^BOOL(NSDictionary *message) {
			return [message[@"id"] isEqualToString:hookId];
		}] map:^id(NSDictionary *message) {
			NSDictionary *data = message[@"data"];

			if (data[@"payload"])
			{
				NSData *payloadData = [data[@"payload"] dataUsingEncoding:NSUTF8StringEncoding];
				data = [NSJSONSerialization JSONObjectWithData:payloadData options:0 error:NULL];
			}

			return data;
		}];

		[subscriber sendNext:hookDataSignal];
		[subscriber sendCompleted];

		return nil;
	}] flatten];
}

#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
	NSData *data = [message isKindOfClass:[NSData class]] ? message : [message dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *messageContent = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
	NSString *type = messageContent[@"type"];

	if ([type isEqualToString:@"hook"])
	{
		[[self hookSubject] sendNext:messageContent];
	}
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
	@synchronized (self)
	{
		for (NSString *hookId in [self monitoredHookIds])
		{
			[self registerForHookWithId:hookId];
		}

		[self setConnected:YES];
	}

	[[self connectSubject] sendNext:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
	RACSubject *connectSubject = [self connectSubject];

	[self setWebSocket:nil];
	[self setConnectSubject:nil];

	[connectSubject sendError:error];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
	RACSubject *connectSubject = [self connectSubject];

	[self setWebSocket:nil];
	[self setConnectSubject:nil];

	[connectSubject sendError:[NSError errorWithDomain:WebHookManagerErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : reason}]];
}

@end
