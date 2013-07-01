//
//  PlayQueue.m
//  imysound
//
//  Created by yzx on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayQueue.h"

@interface PlayQueue ()

@property(nonatomic, retain)NSArray *playItemList;

@property(nonatomic, assign)NSInteger currentIndex;

@end

@implementation PlayQueue

@synthesize playQueueControl = _playQueueControl;

@synthesize playItemList = _playItemList;

@synthesize currentIndex = _currentIndex;

@synthesize finished = _finished;

- (void)dealloc
{
    [_playItemList release];
    
    [_playQueueControl release];
    [super dealloc];
}

- (id)initWithPlayItemList:(NSArray *)playItemList playAtIndex:(NSInteger)index
{
    self = [super init];
    
    self.playItemList = playItemList;
    self.currentIndex = index;
    self.finished = NO;
    
    return self;
}

- (id)initWithPlayItemList:(NSArray *)playItemList
{
    self = [self initWithPlayItemList:playItemList playAtIndex:0];
    
    return self;
}

- (NSInteger)currentPlayingIndex
{
    return self.currentIndex;
}

- (void)setCurrentPlayingIndex:(NSInteger)index
{
    self.currentIndex = index;
}

- (NSInteger)numberOfPlayItems
{
    return self.playItemList.count;
}

- (PlayItem *)playItemAtIndex:(NSInteger)index
{
    return [self.playItemList objectAtIndex:index];
}

- (PlayItem *)nextPlayItem
{
    if(self.playQueueControl){
        return [self.playQueueControl nextPlayItemFromQueue:self];
    }
    
    return nil;
}

- (PlayItem *)goNext
{
    NSInteger nextIndex = self.currentIndex + 1;
    if(nextIndex < self.playItemList.count){
        self.currentIndex = nextIndex;
        return [self.playItemList objectAtIndex:nextIndex];
    }
    return nil;
}

- (PlayItem *)goPrevious
{
    NSInteger previousIndex = self.currentIndex - 1;
    if(previousIndex >= 0){
        self.currentIndex = previousIndex;
        return [self.playItemList objectAtIndex:previousIndex];
    }
    return nil;
}

- (PlayItem *)currentPlayItem
{
    if(self.currentIndex >= 0){
        return [self.playItemList objectAtIndex:self.currentIndex];
    }
    return nil;
}

- (void)reset
{
    self.currentIndex = 0;
    self.finished = NO;
}

@end
