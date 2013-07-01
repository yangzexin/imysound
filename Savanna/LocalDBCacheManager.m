//
//  LocalDBCacheManager.m
//  imysound
//
//  Created by gewara on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocalDBCacheManager.h"
#import "CommonUtils.h"
#import "CodeUtils.h"
#import "Cache.h"
#import "DBKeyValueManager.h"

#define SEPARATOR @"__s_p__"

@interface LocalDBCacheManager ()

@property(nonatomic, retain)DBKeyValueManager *dbKeyValueMgr;

@end

@implementation LocalDBCacheManager

@synthesize dbKeyValueMgr = _dbKeyValueMgr;

- (void)dealloc
{
    [_dbKeyValueMgr release];
    [super dealloc];
}

- (id)init
{
    NSString *randomString = [CommonUtils randomString];
    self = [self initWithDBName:randomString];
    
    return self;
}

- (id)initWithDBName:(NSString *)dbName
{
    self = [super init];
    
    NSString *filePath = [[CommonUtils libraryPath] stringByAppendingPathComponent:[CodeUtils encodeWithString:dbName]];
    self.dbKeyValueMgr = [[[DBKeyValueManager alloc] initWithDBName:dbName atFilePath:filePath] autorelease];
    
    return self;
}

- (void)setCache:(Cache *)cache
{
    NSString *key = cache.key;
    NSString *value = [NSString stringWithFormat:@"%@%@%@", cache.content, SEPARATOR, cache.date];
    [self.dbKeyValueMgr setValue:value forKey:key];
}

- (Cache *)cacheForKey:(NSString *)key
{
    NSString *value = [self.dbKeyValueMgr valueForKey:key];
    NSArray *valueArray = [value componentsSeparatedByString:SEPARATOR];
    if(valueArray.count == 2){
        Cache *cache = [[[Cache alloc] init] autorelease];
        cache.key = key;
        cache.content = [valueArray objectAtIndex:0];
        cache.date = [valueArray objectAtIndex:1];
        
        return cache;
    }
    return nil;
}

- (void)clearAllCache
{
    
}

@end
