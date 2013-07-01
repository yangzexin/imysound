//
//  PlayQueueControlFactory.h
//  imysound
//
//  Created by yzx on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayQueueControl.h"

@interface PlayQueueControlFactory : NSObject

+ (id<PlayQueueControl>)createNormalPlayQueueControl;
+ (id<PlayQueueControl>)createSingleLoopPlayQueueControl;
+ (id<PlayQueueControl>)createLoopPlayQueueControl;

@end
