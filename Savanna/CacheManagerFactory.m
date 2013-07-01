//
//  CacheManagerFactory.m
//  imysound
//
//  Created by gewara on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CacheManagerFactory.h"
#import "SimpleCacheManager.h"
#import "LocalDBCacheManager.h"

@implementation CacheManagerFactory

+ (id<CacheManager>)createSimpleCacheManager
{
    return [[[SimpleCacheManager alloc] init] autorelease];
}

+ (id<CacheManager>)createLocalCacheManagerWithCacheName:(NSString *)name
{
    return [[[LocalDBCacheManager alloc] initWithDBName:name] autorelease];
}

@end
