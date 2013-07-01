//
//  LocalDBCacheManager.h
//  imysound
//
//  Created by gewara on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheManager.h"

@class DBKeyValueManager;

@interface LocalDBCacheManager : NSObject <CacheManager> {
    DBKeyValueManager *_dbKeyValueMgr;
}

- (id)initWithDBName:(NSString *)dbName;

@end
