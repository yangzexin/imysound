//
//  KeyValueManagerFactory.m
//  imysound
//
//  Created by yzx on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KeyValueManagerFactory.h"
#import "DBKeyValueManager.h"

@implementation KeyValueManagerFactory

+ (id<KeyValueManager>)createLocalDBKeyValueManagerWithName:(NSString *)name
{
    return [[[DBKeyValueManager alloc] initWithDBName:name] autorelease];
}

@end
