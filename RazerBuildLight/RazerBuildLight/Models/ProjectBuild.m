//
// Created by Benjamin Dobell on 10/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <OctoKit/OctoKit.h>
#import <ReactiveCocoa/RACSignal.h>
#import "ProjectBuild.h"

@implementation ProjectBuild

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
	return @{
		@"repository": @"repository",
		@"branches": @"branches",
		@"status": @"status",
	};
}

+ (NSValueTransformer *)repositoryJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:OCTRepository.class];
}

+ (NSValueTransformer *)branchesJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:OCTBranch.class];
}

@end
