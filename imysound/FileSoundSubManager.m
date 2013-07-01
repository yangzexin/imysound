//
//  FileSoundSubManager.m
//  imysound
//
//  Created by yangzexin on 13-4-7.
//
//

#import "FileSoundSubManager.h"
#import "SimpleFileKeyValueManager.h"

@interface FileSoundSubManager ()

@property(nonatomic, copy)NSString *soundFilePath;
@property(nonatomic, retain)id<KeyValueManager> keyValue;

@end

@implementation FileSoundSubManager

- (void)dealloc
{
    self.soundFilePath = nil;
    self.keyValue = nil;
    [super dealloc];
}

- (id)initWithSoundFilePath:(NSString *)soundFilePath
{
    self = [super init];
    
    self.soundFilePath = soundFilePath;
    self.keyValue = [[SimpleFileKeyValueManager alloc] initWithFilePath:[NSString stringWithFormat:@"%@.playlist", self.soundFilePath]];
    
    return self;
}

- (void)setValue:(NSString *)value forKey:(NSString *)key
{
    [self.keyValue setValue:value forKey:key];
}

- (NSString *)valueForKey:(NSString *)key
{
    return [self.keyValue valueForKey:key];
}

- (void)removeValueForKey:(NSString *)key
{
    [self.keyValue removeValueForKey:key];
}

- (void)clear
{
    [self.keyValue clear];
}

- (NSArray *)allKeys
{
    return [self.keyValue allKeys];
}

- (NSArray *)keyListAtIndex:(NSInteger)index size:(NSInteger)size
{
    return [self.keyValue keyListAtIndex:index size:size];
}

@end
