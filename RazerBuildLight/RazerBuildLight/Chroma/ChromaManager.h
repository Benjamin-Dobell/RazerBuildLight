//
// Created by Benjamin Dobell on 19/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ChromaManagerErrorDomain;

enum {
	kChromaManagerErrorConnection = 1,
	kChromaManagerErrorDeviceNotFound = 2,
	kChromaManagerErrorProfileSetupFailed = 3
};

@interface ChromaManager : NSObject

@property (nonatomic, strong, readonly) NSString *successProfileId;
@property (nonatomic, strong, readonly) NSString *buildingProfileId;
@property (nonatomic, strong, readonly) NSString *failureProfileId;

+ (instancetype)sharedInstance;

- (BOOL)connect:(NSError **)error;

- (void)disconnect;

- (BOOL)activateProfileWithProfileId:(NSString *)profileId;

@end
