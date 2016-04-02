//
// Created by Benjamin Dobell on 10/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <Mantle/Mantle.h>

@class OCTRepository;
@class OCTBranch;

@interface ProjectBuild : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) OCTRepository *repository;
@property (nonatomic, copy) OCTBranch *branch;
@property (nonatomic, copy) NSString *status;

@end
