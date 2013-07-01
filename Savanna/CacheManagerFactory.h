//
//  CacheManagerFactory.h
//  imysound
//
//  Created by gewara on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheManager.h"

@interface CacheManagerFactory : NSObject

+ (id<CacheManager>)createSimpleCacheManager;
+ (id<CacheManager>)createLocalCacheManagerWithCacheName:(NSString *)name;

@end
