//
//  ProviderPool.m
//  GWV2
//
//  Created by gewara on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SVProviderPool.h"

@interface SVProviderPool ()

@property(nonatomic, retain)NSMutableArray *providerList;
- (void)releaseAllProvider;

@end

@implementation SVProviderPool

@synthesize providerList;

- (void)dealloc
{
    [self releaseAllProvider];
    self.providerList = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.providerList = [NSMutableArray array];
    
    return self;
}

- (void)addProvider:(id<SVProviderPoolable>)provider
{
    [self.providerList addObject:provider];
}

- (void)tryToReleaseProvider
{
    NSMutableArray *wantReleaseList = [NSMutableArray array];
    for(id<SVProviderPoolable> provider in self.providerList){
        if([provider respondsToSelector:@selector(providerShouldBeRemoveFromPool)] && [provider providerShouldBeRemoveFromPool]){
            [provider providerWillRemoveFromPool];
            [wantReleaseList addObject:provider];
        }
    }
    for(id<SVProviderPoolable> provider in wantReleaseList){
        NSLog(@"recycle remove:%@", provider);
        [self.providerList removeObject:provider];
    }
}

- (void)releaseAllProvider
{
    for(id<SVProviderPoolable> provider in self.providerList){
        [provider providerWillRemoveFromPool];
        NSLog(@"force remove:%@", provider);
    }
    [self.providerList removeAllObjects];
}

#pragma mark - SharedPool
+ (SVProviderPool *)sharedPool
{
    static SVProviderPool *instance = nil;
    if(instance == nil){
        @synchronized(self.class){
            instance = [[self.class alloc] init];
        }
    }
    
    return instance;
}

+ (NSMutableDictionary *)sharedPoolDictionary
{
    static NSMutableDictionary *dictionary = nil;
    if(dictionary == nil){
        @synchronized(self.class){
            dictionary = [[NSMutableDictionary dictionary] retain];
        }
    }
    return dictionary;
}

+ (NSString *)identifierForObj:(id)obj
{
    return [NSString stringWithFormat:@"id_%@", obj];
}

+ (id)providerInPoolWithIdentifier:(id)identifier
{
    NSString *key = [self identifierForObj:identifier];
    
    return [[self sharedPoolDictionary] objectForKey:key];
}

+ (void)addProviderToSharedPool:(id<SVProviderPoolable>)provider identifier:(id)identifier
{
    @synchronized(self.class){
        SVProviderPool *pool = [self sharedPool];
        [[self sharedPoolDictionary] setObject:provider forKey:[self identifierForObj:identifier]];
        [pool addProvider:provider];
        if(pool.providerList.count > 5){
            [pool tryToReleaseProvider];
        }
    }
}

+ (void)cleanWithIdentifier:(id)identifier
{
    @synchronized(self.class){
        SVProviderPool *pool = [self sharedPool];
        id<SVProviderPoolable> provider = [[self sharedPoolDictionary] objectForKey:[self identifierForObj:identifier]];
        if(provider){
            [provider providerWillRemoveFromPool];
            [pool.providerList removeObject:provider];
        }
        [pool tryToReleaseProvider];
    }
}

@end
