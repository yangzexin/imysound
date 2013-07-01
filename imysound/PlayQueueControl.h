//
//  PlayQueueControl.h
//  imysound
//
//  Created by yzx on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlayItem;
@class PlayQueue;

@protocol PlayQueueControl <NSObject>

- (PlayItem *)nextPlayItemFromQueue:(PlayQueue *)queue;

@end
