//
//  DBKeyValueCache.m
//  imyvoa
//
//  Created by yzx on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBKeyValueManager.h"
#import "CommonUtils.h"
#import "CodeUtils.h"

@interface DBKeyValueManager ()

@property(nonatomic, copy)NSString *dbName;
@property(nonatomic, copy)NSString *dbFilePath;

- (void)openDatabase:(NSString *)dbFilePath;

@end

@implementation DBKeyValueManager

@synthesize dbName = _dbName;
@synthesize dbFilePath = _dbFilePath;

- (void)dealloc
{
    [_dbName release];
    [_dbFilePath release];
    
    sqlite3_close(_db);
    [super dealloc];
}

- (id)init
{
    NSString *randomCacheName = [CommonUtils randomString];
    
    self = [self initWithDBName:randomCacheName];
    
    return self;
}

- (id)initWithDBName:(NSString *)dbName
{
    NSString *filePath = [[CommonUtils libraryPath] 
                          stringByAppendingPathComponent:[CodeUtils encodeWithString:dbName]];
    self = [self initWithDBName:dbName atFilePath:filePath];
    
    return self;
}

- (id)initWithDBName:(NSString *)dbName atFilePath:(NSString *)filePath
{
    self = [super init];
    
    self.dbName = dbName;
    self.dbFilePath = filePath;
    
    [self openDatabase:self.dbFilePath];
    
    return self;
}

#pragma mark - private methods
- (void)openDatabase:(NSString *)dbFilePath
{
    BOOL dbExists = [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];
    if(sqlite3_open([dbFilePath UTF8String], &_db) == SQLITE_OK){
        if(!dbExists){
            NSLog(@"create cache:%@", self.dbName);
            const char *sql_create_table = {
                "create table default_table("
                "uid INTEGER primary key AUTOINCREMENT,"
                "column_key TEXT,"
                "column_value TEXT"
                ")"
            };
            if(sqlite3_exec(_db, sql_create_table, NULL, NULL, NULL) == SQLITE_OK){
                NSLog(@"create table for cache:%@ succeed", self.dbName);
            }else{
                NSLog(@"create table for cache:%@ failed", self.dbName);
            }
        }
    }
}

#pragma mark - KeyValueCache
- (void)setValue:(NSString *)value forKey:(NSString *)key
{
    if([self valueForKey:key].length != 0){
        [self removeValueForKey:key];
    }
    
    value = [CodeUtils encodeWithString:value];
    key = [CodeUtils encodeWithString:key];
    
    NSString *sql = @"insert into default_table(column_key, column_value) values(\"$key\", \"$value\")";
    sql = [sql stringByReplacingOccurrencesOfString:@"$key" withString:key];
    sql = [sql stringByReplacingOccurrencesOfString:@"$value" withString:value];
    
    char *errMsg = NULL;
    if(sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &errMsg) == SQLITE_OK){
//        NSLog(@"%@", sql);
    }
    if(errMsg){
        NSLog(@"%@", [NSString stringWithUTF8String:errMsg]);
    }
}

- (NSString *)valueForKey:(NSString *)key
{
    key = [CodeUtils encodeWithString:key];
    
    NSString *sql = @"select column_value from default_table where column_key=\"$key\"";
    sql = [sql stringByReplacingOccurrencesOfString:@"$key" withString:key];
    
    NSString *value = nil;
    
    sqlite3_stmt *stmt = NULL;
    if(sqlite3_prepare(_db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK){
        if(sqlite3_step(stmt) == SQLITE_ROW){
//            NSLog(@"%@", sql);
            value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
        }
    }
    
    if(stmt){
        sqlite3_finalize(stmt);
    }
    
    if(value){
        value = [CodeUtils stringDecodedWithString:value];
    }
    
    return value;
}

- (void)removeValueForKey:(NSString *)key
{
    key = [CodeUtils encodeWithString:key];
    
    NSString *sql = @"delete from default_table where column_key=\"$key\"";
    sql = [sql stringByReplacingOccurrencesOfString:@"$key" withString:key];
    if(sqlite3_exec(_db, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK){
//        NSLog(@"%@", sql);
    }
}

- (void)clear
{
    sqlite3_close(_db);
    _db = NULL;
    NSString *dbFilePath = [[CommonUtils documentPath] stringByAppendingPathComponent:[CodeUtils encodeWithString:self.dbName]];
    [[NSFileManager defaultManager] removeItemAtPath:dbFilePath error:nil];
    [self openDatabase:self.dbFilePath];
}

- (NSArray *)selectKeyBySQL:(NSString *)sql
{
    sqlite3_stmt *stmt = NULL;
    NSMutableArray *keyList = nil;
    if(sqlite3_prepare(_db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK){
        keyList = [NSMutableArray array];
        while(sqlite3_step(stmt) == SQLITE_ROW){
            NSString *key = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
            key = [CodeUtils stringDecodedWithString:key];
            [keyList addObject:key];
        }
    }
    if(stmt){
        sqlite3_finalize(stmt);
    }
    return keyList;
}

- (NSArray *)allKeys
{
    NSString *sql = @"select column_key from default_table";
    
    return [self selectKeyBySQL:sql];
}

- (NSArray *)keyListAtIndex:(NSInteger)index size:(NSInteger)size
{
    NSString *sql = [NSString stringWithFormat:@"select column_key from default_table limit %d, %d", index, size];
    
    return [self selectKeyBySQL:sql];
}

@end
