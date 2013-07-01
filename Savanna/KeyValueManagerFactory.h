//
//  KeyValueManagerFactory.h
//  imysound
//
//  Created by yzx on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyValueManager.h"

@interface KeyValueManagerFactory : NSObject

+ (id<KeyValueManager>)createLocalDBKeyValueManagerWithName:(NSString *)name;

@end
