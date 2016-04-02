//
// Created by Benjamin Dobell on 13/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Configuration.h"

@interface Configuration ()

@property (nonatomic, strong) ProjectBuildList *projectBuildList;

@end

@implementation Configuration

- (instancetype)init
{
	return [self initWithProjectBuildList:nil];
}

- (instancetype)initWithProjectBuildList:(ProjectBuildList *)projectBuildList
{
	if ((self = [super init]))
	{
		if (!projectBuildList)
		{
			projectBuildList = [[ProjectBuildList alloc] init];
		}

		[self setProjectBuildList:projectBuildList];
	}

	return self;
}

@end
