//
//  PlayQueue.h
//  imysound
//
//  Created by yzx on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayQueueControl.h"

@interface PlayQueue : NSObject {
    NSArray *_playItemList;
    
    id<PlayQueueControl> _playQueueControl;
    
    NSInteger _currentIndex;
    BOOL _finished;
}

@property(nonatomic, retain)id<PlayQueueControl> playQueueControl;

@property(nonatomic, assign)BOOL finished;

- (id)initWithPlayItemList:(NSArray *)playItemList;
- (id)initWithPlayItemList:(NSArray *)playItemList playAtIndex:(NSInteger)index;

- (NSInteger)currentPlayingIndex;
- (void)setCurrentPlayingIndex:(NSInteger)index;
- (NSInteger)numberOfPlayItems;
- (PlayItem *)playItemAtIndex:(NSInteger)index;

- (PlayItem *)nextPlayItem;

- (PlayItem *)goNext;
- (PlayItem *)goPrevious;

- (PlayItem *)currentPlayItem;

- (void)reset;

@end
