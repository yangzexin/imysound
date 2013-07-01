//
//  PlayQueueControlAllLoop.m
//  imysound
//
//  Created by gewara on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayQueueControlAllLoop.h"
#import "PlayQueue.h"

@implementation PlayQueueControlAllLoop

- (PlayItem *)nextPlayItemFromQueue:(PlayQueue *)queue
{
    NSInteger nextIndex = [queue currentPlayingIndex] + 1;
    if(nextIndex == [queue numberOfPlayItems]){
        nextIndex = 0;
    }
    queue.currentPlayingIndex = nextIndex;
    return [queue playItemAtIndex:nextIndex];
}

@end
