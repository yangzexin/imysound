//
//  SimpleCacheManager.h
//  imysound
//
//  Created by gewara on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheManager.h"

@interface SimpleCacheManager : NSObject <CacheManager> {
@private
    NSMutableDictionary *_cacheDictionary;
}

@end
