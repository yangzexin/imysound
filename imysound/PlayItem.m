//
//  PlayItem.m
//  imysound
//
//  Created by yzx on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayItem.h"

@implementation PlayItem

@synthesize soundFilePath;
@synthesize title;
@synthesize beginTime;
@synthesize endTime;

- (void)dealloc
{
    [soundFilePath release];
    [title release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.title = @"";
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %f->%f", soundFilePath, title, beginTime, endTime];
}

- (BOOL)isEqual:(id)object
{
    PlayItem *item = object;
    return [item.soundFilePath isEqualToString:self.soundFilePath] 
        && [item.title isEqualToString:title] 
        && self.beginTime == item.beginTime 
        && self.endTime == item.endTime;
}

@end
