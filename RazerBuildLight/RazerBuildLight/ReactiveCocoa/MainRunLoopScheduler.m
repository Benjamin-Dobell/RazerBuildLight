//
// Created by Benjamin Dobell on 15/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import "MainRunLoopScheduler.h"
#import "SwizzleHelper.h"

@interface MainRunLoopSchedulable : NSObject

@property (nonatomic, copy) void(^block)(void);
@property (nonatomic, strong) RACDisposable *disposable;

@property (nonatomic, copy) NSDate *date;

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, assign) NSTimeInterval leeway;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MainRunLoopSchedulable

- (instancetype)initWithBlock:(void (^)(void))block disposable:(RACDisposable *)disposable
{
	if ((self = [super init]))
	{
		[self setBlock:block];
		[self setDisposable:disposable];
	}

	return self;
}

- (void)executeWithScheduler:(MainRunLoopScheduler *)scheduler
{
	if (![[self disposable] isDisposed])
	{
		[scheduler performAsCurrentScheduler:[self block]];
	}
}

- (void)executeWithUserInfo:(NSDictionary *)userInfo
{
	[self executeWithScheduler:userInfo[@"scheduler"]];
}

- (void)scheduleWithScheduler:(MainRunLoopScheduler *)scheduler
{
	if ([self date])
	{
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[[self date] timeIntervalSinceNow] target:self selector:@selector(executeWithUserInfo:) userInfo:@{@"scheduler" : scheduler} repeats:YES];
		[self setTimer:timer];
	}
	else
	{
		[self executeWithScheduler:scheduler];
	}
}

@end

NSMutableArray *schedulerStack;
volatile BOOL racSchedulerSwizzled = NO;

// This is kinda crazy, but by default ReactiveCocoa uses GCD, GCD queues are not reentrant.
// So, we need this class so we can schedule signals when we're already inside a GCD queue.
// i.e. We still want to be able to use ReactiveCocoa in modals presented by a RACSubscriber.
@implementation MainRunLoopScheduler

+ (void)load
{
	[super load];

	schedulerStack = [[NSMutableArray alloc] init];
}

+ (void)pushMainRunLoopScheduler:(MainRunLoopScheduler *)scheduler
{
	@synchronized (schedulerStack)
	{
		if (!racSchedulerSwizzled)
		{
			[SwizzleHelper swizzleClassMethod:@selector(mainThreadScheduler) toSelector:@selector(_swizzled_mainRunLoopScheduler_mainThreadScheduler) inClass:[RACScheduler class]];
			racSchedulerSwizzled = YES;
		}

		[schedulerStack addObject:scheduler];
	}
}

+ (void)popMainRunLoopScheduler
{
	@synchronized (schedulerStack)
	{
		[schedulerStack removeLastObject];
	}
}

+ (MainRunLoopScheduler *)activeMainRunLoopScheduler
{
	@synchronized (schedulerStack)
	{
		return [schedulerStack lastObject];
	}
}

- (RACDisposable *)schedule:(void (^)(void))block
{
	RACDisposable *disposable = [[RACDisposable alloc] init];
	MainRunLoopSchedulable *schedulable = [[MainRunLoopSchedulable alloc] initWithBlock:block disposable:disposable];
	[schedulable performSelectorOnMainThread:@selector(scheduleWithScheduler:) withObject:self waitUntilDone:NO];
	return disposable;
}

- (RACDisposable *)after:(NSDate *)date schedule:(void (^)(void))block
{
	RACDisposable *disposable = [[RACDisposable alloc] init];
	MainRunLoopSchedulable *schedulable = [[MainRunLoopSchedulable alloc] initWithBlock:block disposable:disposable];
	[schedulable setDate:date];
	[schedulable performSelectorOnMainThread:@selector(scheduleWithScheduler:) withObject:self waitUntilDone:NO];
	return disposable;
}

- (RACDisposable *)after:(NSDate *)date repeatingEvery:(NSTimeInterval)interval withLeeway:(NSTimeInterval)leeway schedule:(void (^)(void))block
{
	MainRunLoopSchedulable *schedulable = [[MainRunLoopSchedulable alloc] init];
	[schedulable setBlock:block];
	[schedulable setDate:date];
	[schedulable setInterval:interval];
	[schedulable setLeeway:leeway];

	[schedulable setDisposable:[RACDisposable disposableWithBlock:^{
		[[schedulable timer] invalidate];
		[schedulable setTimer:nil];
		[schedulable setDisposable:nil];
	}]];

	[schedulable performSelectorOnMainThread:@selector(scheduleWithScheduler:) withObject:self waitUntilDone:NO];

	return [schedulable disposable];
}

- (void)performAsCurrentScheduler:(void (^)(void))block
{
	[MainRunLoopScheduler pushMainRunLoopScheduler:self];
	[super performAsCurrentScheduler:block];
	[MainRunLoopScheduler popMainRunLoopScheduler];
}

@end

@implementation RACScheduler (MainRunLoopScheduler)

+ (RACScheduler *)_swizzled_mainRunLoopScheduler_mainThreadScheduler
{
	RACScheduler *scheduler = [MainRunLoopScheduler activeMainRunLoopScheduler];

	if (scheduler)
	{
		return scheduler;
	}
	else
	{
		return [RACScheduler _swizzled_mainRunLoopScheduler_mainThreadScheduler];
	}
}

@end
