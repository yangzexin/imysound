//
//  Cache.m
//  imysound
//
//  Created by gewara on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Cache.h"

@implementation Cache

@synthesize key;
@synthesize content;
@synthesize date;

- (void)dealloc
{
    [key release];
    [content release];
    [date release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    static NSDateFormatter *dateFormatter = nil;
    @synchronized(dateFormatter){
        if(dateFormatter == nil){
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        }
    }
    
    self.date = [dateFormatter stringFromDate:[[[NSDate alloc] init] autorelease]];
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@:%@", self.date, self.key, self.content];
}

@end
