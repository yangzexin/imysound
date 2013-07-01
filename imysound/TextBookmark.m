//
//  TextBookmark.m
//  imysound
//
//  Created by gewara on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TextBookmark.h"

@implementation TextBookmark

@synthesize title;
@synthesize scrollPosition;

- (void)dealloc
{
    [title release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeFloat:self.scrollPosition forKey:@"scrollPosition"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.scrollPosition = [aDecoder decodeFloatForKey:@"scrollPosition"];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    
    return self;
}

@end
