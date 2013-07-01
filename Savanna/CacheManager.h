//
//  CacheManager.h
//  imysound
//
//  Created by gewara on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Cache;

@protocol CacheManager <NSObject>

- (void)setCache:(Cache *)cache;
- (Cache *)cacheForKey:(NSString *)key;
- (void)clearAllCache;

@end
