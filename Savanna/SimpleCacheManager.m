//
//  SimpleCacheManager.m
//  imysound
//
//  Created by gewara on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SimpleCacheManager.h"
#import "Cache.h"

@interface SimpleCacheManager ()

@property(nonatomic, retain)NSMutableDictionary *cacheDictionary;

@end

@implementation SimpleCacheManager

@synthesize cacheDictionary = _cacheDictionary;

- (void)dealloc
{
    [_cacheDictionary release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.cacheDictionary = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)setCache:(Cache *)cache
{
    [self.cacheDictionary setObject:cache forKey:cache.key];
}

- (Cache *)cacheForKey:(NSString *)key
{
    return [self.cacheDictionary objectForKey:key];
}

- (void)clearAllCache
{
    [self.cacheDictionary removeAllObjects];
}

@end
