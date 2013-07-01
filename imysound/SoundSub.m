//
//  SoundSub.m
//  iSang
//
//  Created by yangzexin on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SoundSub.h"
#import <AVFoundation/AVFoundation.h>

@implementation SoundSub

@synthesize title;
@synthesize beginTime;
@synthesize endTime;

- (id)init
{
    self = [super init];
    if (self) {
        beginTime = 0.0f;
        endTime = 0.0f;
        self.title = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:beginTime forKey:@"BeginTime"];
    [aCoder encodeDouble:endTime forKey:@"EndTime"];
    [aCoder encodeObject:title forKey:@"Title"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    beginTime = [aDecoder decodeDoubleForKey:@"BeginTime"];
    endTime = [aDecoder decodeDoubleForKey:@"EndTime"];
    title = [[aDecoder decodeObjectForKey:@"Title"] retain];
    return self;
}

- (void)dealloc
{
    [title release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%.2f-%.2f, %@", beginTime, endTime, title];
}

@end
