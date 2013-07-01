//
//  ProviderPool.h
//  GWV2
//
//  Created by gewara on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SVProviderPool;

@protocol SVProviderPoolable <NSObject>

@required
- (void)providerWillRemoveFromPool;
@optional
- (BOOL)providerShouldBeRemoveFromPool;
- (BOOL)providerIsExecuting;

@end

@interface SVProviderPool : NSObject

- (void)addProvider:(id<SVProviderPoolable>)provider;
- (void)tryToReleaseProvider;

+ (id)providerInPoolWithIdentifier:(id)identifier;
+ (void)addProviderToSharedPool:(id<SVProviderPoolable>)provider identifier:(id)identifier;
+ (void)cleanWithIdentifier:(id)identifier;

@end
