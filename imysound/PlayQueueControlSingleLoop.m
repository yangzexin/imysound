//
//  PlayQueueControlSingleLoop.m
//  imysound
//
//  Created by gewara on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayQueueControlSingleLoop.h"
#import "PlayQueue.h"

@implementation PlayQueueControlSingleLoop

- (PlayItem *)nextPlayItemFromQueue:(PlayQueue *)queue
{
    return [queue playItemAtIndex:queue.currentPlayingIndex];
}

@end
