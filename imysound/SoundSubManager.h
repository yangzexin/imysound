//
//  SoundSubManager.h
//  imysound
//
//  Created by yzx on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyValueManager.h"

@interface SoundSubManager : NSObject {
    id<KeyValueManager> _keyValueMgr;
}

+ (id)sharedManager;
- (void)setSubListWithArray:(NSArray *)subList forIdentifier:(NSString *)identifier;
- (NSArray *)subListForIdentifier:(NSString *)identifier;

@end
