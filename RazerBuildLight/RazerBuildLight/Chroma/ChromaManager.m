//
// Created by Benjamin Dobell on 19/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <GERazerKit/GERazerKit.h>
#import <Foundation/Foundation.h>
#import "ChromaManager.h"

NSString *const ChromaManagerErrorDomain = @"au.com.glassechidna.RazerBuildLight.ChromaManager";

static NSString *const ProfileNameSuccess = @"Build - Success";
static NSString *const ProfileNameBuilding = @"Build - Building";
static NSString *const ProfileNameFailure = @"Build - Failure";

@interface ChromaManager ()

@property (nonatomic, assign) int productId;

@property (nonatomic, strong) NSString *successProfileId;
@property (nonatomic, strong) NSString *buildingProfileId;
@property (nonatomic, strong) NSString *failureProfileId;

@end

@implementation ChromaManager

+ (int)findChromaProductId:(NSArray *)productIds
{
	NSString *dockId = [@(kGERazerLedIdMambaDock) stringValue];
	NSString *mouseId = [@(kGERazerLedIdMambaMouse) stringValue];

	for (NSNumber *productId in productIds)
	{
		NSDictionary *activeProfile = (__bridge_transfer NSDictionary *) GERazerCopyActiveProfile([productId intValue]);
		NSDictionary *ledEffectList = activeProfile[@"LEDEffectList"];

		if (ledEffectList[dockId] && ledEffectList[mouseId])
		{
			return [productId intValue];
		}
	}

	return kCFNotFound;
}

+ (NSDictionary *)findWithinProfileWithName:(NSString *)name withinProfiles:(NSArray *)profiles
{
	for (NSDictionary *profile in profiles)
	{
		if ([profile[@"ProfileName"] isEqualToString:name])
		{
			return profile;
		}
	}

	return nil;
}

+ (NSDictionary *)successEffectList
{
	NSMutableDictionary *dockEffects = [NSMutableDictionary dictionary];
	dockEffects[(__bridge NSString *) kGERazerEffectNameSpectrumCycling] = (__bridge_transfer NSDictionary *) GERazerEffectCreateSpectrumCycling();
	dockEffects[(__bridge NSString *) kGERazerEffectNameBreathing] = (__bridge_transfer NSDictionary *) GERazerEffectCreateBreathing(0.0, 1.0, 0.0, 0.0, 1.0, 0.0);
	dockEffects[(__bridge NSString *) kGERazerEffectNameStatic] = (__bridge_transfer NSDictionary *) GERazerEffectCreateStatic(0.0, 1.0, 0.0);

	NSMutableDictionary *mouseEffects = [NSMutableDictionary dictionary];
	mouseEffects[(__bridge NSString *) kGERazerEffectNameSpectrumCycling] = (__bridge_transfer NSDictionary *) GERazerEffectCreateSpectrumCycling();
	mouseEffects[(__bridge NSString *) kGERazerEffectNameBreathing] = (__bridge_transfer NSDictionary *) GERazerEffectCreateBreathing(0.0, 1.0, 0.0, 0.0, 1.0, 0.0);
	mouseEffects[(__bridge NSString *) kGERazerEffectNameWave] = (__bridge_transfer NSDictionary *) GERazerEffectCreateWave(kGERazerWaveDirectionBackToFront);
	mouseEffects[(__bridge NSString *) kGERazerEffectNameStatic] = (__bridge_transfer NSDictionary *) GERazerEffectCreateStatic(0.0, 1.0, 0.0);
	mouseEffects[(__bridge NSString *) kGERazerEffectNameReactive] = (__bridge_transfer NSDictionary *) GERazerEffectCreateReactive(0.0, 1.0, 0.0, kGERazerReactiveAfterglowDurationMedium);

	NSString *dockId = [@(kGERazerLedIdMambaDock) stringValue];
	NSString *mouseId = [@(kGERazerLedIdMambaMouse) stringValue];

	return @{
		dockId: dockEffects,
		mouseId: mouseEffects
	};
}

+ (NSDictionary *)buildingEffectList
{
	NSMutableDictionary *dockEffects = [NSMutableDictionary dictionary];
	dockEffects[(__bridge NSString *) kGERazerEffectNameSpectrumCycling] = (__bridge_transfer NSDictionary *) GERazerEffectCreateSpectrumCycling();
	dockEffects[(__bridge NSString *) kGERazerEffectNameBreathing] = (__bridge_transfer NSDictionary *) GERazerEffectCreateBreathing(0.0, 0.0, 1.0, 0.0, 0.0, 1.0);
	dockEffects[(__bridge NSString *) kGERazerEffectNameStatic] = (__bridge_transfer NSDictionary *) GERazerEffectCreateStatic(0.0, 0.0, 1.0);

	NSMutableDictionary *mouseEffects = [NSMutableDictionary dictionary];
	mouseEffects[(__bridge NSString *) kGERazerEffectNameSpectrumCycling] = (__bridge_transfer NSDictionary *) GERazerEffectCreateSpectrumCycling();
	mouseEffects[(__bridge NSString *) kGERazerEffectNameBreathing] = (__bridge_transfer NSDictionary *) GERazerEffectCreateBreathing(0.0, 0.0, 1.0, 0.0, 0.0, 1.0);
	mouseEffects[(__bridge NSString *) kGERazerEffectNameWave] = (__bridge_transfer NSDictionary *) GERazerEffectCreateWave(kGERazerWaveDirectionBackToFront);
	mouseEffects[(__bridge NSString *) kGERazerEffectNameStatic] = (__bridge_transfer NSDictionary *) GERazerEffectCreateStatic(0.0, 0.0, 1.0);
	mouseEffects[(__bridge NSString *) kGERazerEffectNameReactive] = (__bridge_transfer NSDictionary *) GERazerEffectCreateReactive(0.0, 0.0, 1.0, kGERazerReactiveAfterglowDurationMedium);

	NSString *dockId = [@(kGERazerLedIdMambaDock) stringValue];
	NSString *mouseId = [@(kGERazerLedIdMambaMouse) stringValue];

	return @{
		dockId: dockEffects,
		mouseId: mouseEffects
	};
}

+ (NSDictionary *)failureEffectList
{
	NSMutableDictionary *dockEffects = [NSMutableDictionary dictionary];
	dockEffects[(__bridge NSString *) kGERazerEffectNameSpectrumCycling] = (__bridge_transfer NSDictionary *) GERazerEffectCreateSpectrumCycling();
	dockEffects[(__bridge NSString *) kGERazerEffectNameBreathing] = (__bridge_transfer NSDictionary *) GERazerEffectCreateBreathing(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
	dockEffects[(__bridge NSString *) kGERazerEffectNameStatic] = (__bridge_transfer NSDictionary *) GERazerEffectCreateStatic(1.0, 0.0, 0.0);

	NSMutableDictionary *mouseEffects = [NSMutableDictionary dictionary];
	mouseEffects[(__bridge NSString *) kGERazerEffectNameSpectrumCycling] = (__bridge_transfer NSDictionary *) GERazerEffectCreateSpectrumCycling();
	mouseEffects[(__bridge NSString *) kGERazerEffectNameBreathing] = (__bridge_transfer NSDictionary *) GERazerEffectCreateBreathing(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
	mouseEffects[(__bridge NSString *) kGERazerEffectNameWave] = (__bridge_transfer NSDictionary *) GERazerEffectCreateWave(kGERazerWaveDirectionBackToFront);
	mouseEffects[(__bridge NSString *) kGERazerEffectNameStatic] = (__bridge_transfer NSDictionary *) GERazerEffectCreateStatic(1.0, 0.0, 0.0);
	mouseEffects[(__bridge NSString *) kGERazerEffectNameReactive] = (__bridge_transfer NSDictionary *) GERazerEffectCreateReactive(1.0, 0.0, 0.0, kGERazerReactiveAfterglowDurationMedium);

	NSString *dockId = [@(kGERazerLedIdMambaDock) stringValue];
	NSString *mouseId = [@(kGERazerLedIdMambaMouse) stringValue];

	return @{
		dockId: dockEffects,
		mouseId: mouseEffects
	};
}

- (NSString *)createProfileWithName:(NSString *)name effectList:(NSDictionary *)effectList basedOnTemplateProfile:(NSDictionary *)templateProfile
{
	int activeEffectId;

	if ([name isEqualToString:ProfileNameSuccess])
	{
		activeEffectId = kGERazerEffectIdStatic;
	}
	else
	{
		activeEffectId = kGERazerEffectIdBreathing;
	}

	NSMutableDictionary *customDeviceSettings = (__bridge_transfer NSMutableDictionary *) GERazerDeviceSettingsCreateWithLedEffectList((__bridge CFDictionaryRef) effectList);
	GERazerDictionaryRecursivelyMergeThenReleaseDictionary((__bridge CFMutableDictionaryRef) customDeviceSettings, GERazerDeviceSettingsCreateWithEnabledLightingEffect(kGERazerLedIdMambaDock, activeEffectId, kGERazerLightingBrightnessNormal));
	GERazerDictionaryRecursivelyMergeThenReleaseDictionary((__bridge CFMutableDictionaryRef) customDeviceSettings, GERazerDeviceSettingsCreateWithEnabledLightingEffect(kGERazerLedIdMambaMouse, activeEffectId, kGERazerLightingBrightnessNormal));

	if (templateProfile[@"LEDChromaFollow"][@"PID"])
	{
		int followingProductId = [templateProfile[@"LEDChromaFollow"][@"PID"] intValue];
		GERazerDictionaryRecursivelyMergeThenReleaseDictionary((__bridge CFMutableDictionaryRef) customDeviceSettings, GERazerDeviceSettingsCreateWithLedFollowingProduct(followingProductId, true));
	}

	NSMutableDictionary *profile = (__bridge_transfer NSMutableDictionary *) GERazerDictionaryCreateMutableDeepCopy((__bridge CFDictionaryRef) templateProfile);
	NSString *profileId = [[NSUUID UUID] UUIDString];

	profile[@"ProfileName"] = name;
	profile[@"ProfileID"] = profileId;

	if (!GERazerSaveProductProfile([self productId], (__bridge CFDictionaryRef) profile))
	{
		return nil;
	}

	GERazerSetProductDeviceSettings([self productId], (__bridge CFStringRef) profileId, (__bridge CFDictionaryRef) customDeviceSettings);

	return profileId;
}

- (BOOL)setupProfiles
{
	NSDictionary *activeProfile = (__bridge_transfer NSDictionary *) GERazerCopyActiveProfile([self productId]);

	if (!activeProfile)
	{
		return NO;
	}

	NSArray *profiles = (__bridge_transfer NSArray *) GERazerCopyProductProfiles([self productId]);

	NSString *successProfileId = [ChromaManager findWithinProfileWithName:ProfileNameSuccess withinProfiles:profiles][@"ProfileID"];
	NSString *buildingProfileId = [ChromaManager findWithinProfileWithName:ProfileNameBuilding withinProfiles:profiles][@"ProfileID"];
	NSString *failureProfileId = [ChromaManager findWithinProfileWithName:ProfileNameFailure withinProfiles:profiles][@"ProfileID"];

	if (!successProfileId)
	{
		successProfileId = [self createProfileWithName:ProfileNameSuccess effectList:[ChromaManager successEffectList] basedOnTemplateProfile:activeProfile];
	}

	if (!buildingProfileId)
	{
		buildingProfileId = [self createProfileWithName:ProfileNameBuilding effectList:[ChromaManager buildingEffectList] basedOnTemplateProfile:activeProfile];
	}

	if (!failureProfileId)
	{
		failureProfileId = [self createProfileWithName:ProfileNameFailure effectList:[ChromaManager failureEffectList] basedOnTemplateProfile:activeProfile];
	}

	if (!successProfileId || !buildingProfileId || !failureProfileId)
	{
		return NO;
	}

	[self setSuccessProfileId:successProfileId];
	[self setBuildingProfileId:buildingProfileId];
	[self setFailureProfileId:failureProfileId];

	return YES;
}

+ (instancetype)sharedInstance
{
	static ChromaManager *chromaManager;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		chromaManager = [[ChromaManager alloc] init];
	});

	return chromaManager;
}

- (BOOL)connect:(NSError ** _Nullable)error
{
	SInt32 connectStatus = GERazerConnect(NULL);

	if (connectStatus != kGERazerConnectionSuccess)
	{
		if (error)
		{
			NSMutableDictionary *userInfo = [@{
				NSLocalizedDescriptionKey: @"Failed to connect to the Razer Device Manager"
			} mutableCopy];

			if (connectStatus == kGERazerConnectionSendOnly)
			{
				userInfo[NSLocalizedFailureReasonErrorKey] = @"Could only establish 1-way communication with the Razer Device Engine";
				userInfo[NSLocalizedRecoverySuggestionErrorKey] = @"Please ensure the Synapse Configurator is not running";
			}

			*error = [NSError errorWithDomain:ChromaManagerErrorDomain code:kChromaManagerErrorConnection userInfo:userInfo];
		}

		return NO;
	}

	int chromaProductId = [ChromaManager findChromaProductId:(__bridge_transfer NSArray *) GERazerCopyAttachedProductIds()];

	if (chromaProductId == kCFNotFound)
	{
		if (error)
		{
			*error = [NSError errorWithDomain:ChromaManagerErrorDomain code:kChromaManagerErrorDeviceNotFound userInfo:@{NSLocalizedDescriptionKey : @"Unable to detect any attached Chroma devices"}];
		}

		return NO;
	}

	[self setProductId:chromaProductId];

	if (![self setupProfiles])
	{
		if (error)
		{
			*error = [NSError errorWithDomain:ChromaManagerErrorDomain code:kChromaManagerErrorProfileSetupFailed userInfo:@{NSLocalizedDescriptionKey : @"Failed to setup success, building and failure build light profiles"}];
		}

		return NO;
	}

	return YES;
}

- (void)disconnect
{
	GERazerDisconnect();
}

- (BOOL)activateProfileWithProfileId:(NSString *)profileId
{
	if (!profileId)
	{
		return NO;
	}

	NSDictionary *previousActiveProfile = (__bridge_transfer NSDictionary *) GERazerCopyActiveProfile([self productId]);
	NSMutableDictionary *performanceSettings = [NSMutableDictionary dictionary];

	[@[@"DPIX", @"DPIY", @"IndependentXYOn", @"StageValue", @"PollingRate", @"Acceleration", @"Stages"] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
		performanceSettings[key] = previousActiveProfile[key];
	}];

	if (!GERazerActivateProductProfile([self productId], (__bridge CFStringRef) profileId))
	{
		return NO;
	}

	GERazerSetProductDeviceSettings([self productId], (__bridge CFStringRef) profileId, (__bridge CFDictionaryRef) performanceSettings);
	return YES;
}

@end
