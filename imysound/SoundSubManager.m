//
//  SoundSubManager.m
//  imysound
//
//  Created by yzx on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoundSubManager.h"
#import "DBKeyValueManager.h"
#import "CodeUtils.h"
#import "CommonUtils.h"
#import "FileSoundSubManager.h"

@interface SoundSubManager ()

@end

@implementation SoundSubManager

+ (id)sharedManager
{
    static id instance = nil;
    
    @synchronized(instance){
        if(instance == nil){
            instance = [[self.class alloc] init];
        }
    }
    
    return instance;
}

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)setSubListWithArray:(NSArray *)subList forIdentifier:(NSString *)identifier
{
    NSData *subListData = [NSKeyedArchiver archivedDataWithRootObject:subList];
    NSString *subListDataString = [CodeUtils encodeWithData:subListData];
    FileSoundSubManager *tmpManager = [[[FileSoundSubManager alloc] initWithSoundFilePath:identifier] autorelease];
    [tmpManager setValue:subListDataString forKey:@"sublist"];
}

- (NSArray *)subListForIdentifier:(NSString *)identifier
{
    FileSoundSubManager *tmpManager = [[[FileSoundSubManager alloc] initWithSoundFilePath:identifier] autorelease];
    NSString *subListDataString = [tmpManager valueForKey:@"sublist"];
    if(subListDataString){
        NSData *subListData = [CodeUtils dataDecodedWithString:subListDataString];
        NSArray *subList = [NSKeyedUnarchiver unarchiveObjectWithData:subListData];
        return subList;
    }
    
    return nil;
}

@end
