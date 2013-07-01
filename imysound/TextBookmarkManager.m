//
//  TextBookmarkManager.m
//  imysound
//
//  Created by gewara on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TextBookmarkManager.h"
#import "KeyValueManagerFactory.h"
#import "CodeUtils.h"
#import "SimpleFileKeyValueManager.h"

@interface TextBookmarkManager ()

@end

@implementation TextBookmarkManager


- (void)dealloc
{
    [super dealloc];
}

+ (id<TextBookmarkManager>)createManager
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (NSString *)formatIdentifier:(NSString *)identifier
{
    return [NSString stringWithFormat:@"%@.bookmark", identifier];
}

- (void)addBookmark:(TextBookmark *)bookmark forIdentifier:(NSString *)identifier
{
    NSMutableArray *newBookmarkList = [NSMutableArray array];
    NSArray *existBookmarkList = [self bookmarkListForIdentifier:identifier];
    if(existBookmarkList){
        [newBookmarkList addObjectsFromArray:existBookmarkList];
    }
    [newBookmarkList addObject:bookmark];
    [self setBookmarkList:newBookmarkList forIdentifier:identifier];
}

- (void)setBookmarkList:(NSArray *)bookmarkList forIdentifier:(NSString *)identifier
{
    [[[[SimpleFileKeyValueManager alloc]
       initWithFilePath:[self formatIdentifier:identifier]] autorelease] setValue:[CodeUtils encodeWithData:[NSKeyedArchiver archivedDataWithRootObject:bookmarkList]] forKey:@"bookmarks"];
}

- (NSArray *)bookmarkListForIdentifier:(NSString *)identifier
{
    NSString *dataSting = [[[[SimpleFileKeyValueManager alloc] initWithFilePath:[self formatIdentifier:identifier]] autorelease] valueForKey:@"bookmarks"];
    NSData *objData = [CodeUtils dataDecodedWithString:dataSting];
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:objData];
}

@end
