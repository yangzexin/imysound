//
//  SimpleFileKeyValueManager.m
//  imysound
//
//  Created by yangzexin on 13-4-8.
//
//

#import "SimpleFileKeyValueManager.h"

@interface SimpleFileKeyValueManager ()

@property(nonatomic, copy)NSString *dictionaryFilePath;
@property(nonatomic, retain)NSMutableDictionary *keyValue;

@end

@implementation SimpleFileKeyValueManager

- (void)dealloc
{
    self.keyValue = nil;
    [super dealloc];
}

- (id)initWithFilePath:(NSString *)filePath
{
    self = [super init];
    
    self.dictionaryFilePath = filePath;
    self.keyValue = [NSMutableDictionary dictionaryWithContentsOfFile:self.dictionaryFilePath];
    if(!self.keyValue){
        self.keyValue = [NSMutableDictionary dictionary];
        [self save];
    }
    return self;
}

- (void)save
{
    [self.keyValue writeToFile:self.dictionaryFilePath atomically:NO];
}

- (void)setValue:(NSString *)value forKey:(NSString *)key
{
    [self.keyValue setObject:value forKey:key];
    [self save];
}

- (NSString *)valueForKey:(NSString *)key
{
    return [self.keyValue valueForKey:key];
}

- (void)removeValueForKey:(NSString *)key
{
    [self.keyValue removeObjectForKey:key];
    [self save];
}

- (void)clear
{
    [self.keyValue removeAllObjects];
    [self save];
}

- (NSArray *)allKeys
{
    return [self.keyValue allKeys];
}

- (NSArray *)keyListAtIndex:(NSInteger)index size:(NSInteger)size
{
    NSMutableArray *arr = [NSMutableArray array];
    NSArray *allKeys = [self allKeys];
    NSInteger endIndex = index + size > allKeys.count ? allKeys.count : index + size;
    for(NSInteger i = index; i < endIndex; ++i){
        [arr addObject:[allKeys objectAtIndex:i]];
    }
    return arr;
}

@end
