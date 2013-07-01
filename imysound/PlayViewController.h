//
//  PlayViewController.h
//  imysound
//
//  Created by gewara on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@class PlayQueue;
@class PlayerStatusView;
@class PlayerControlView;
@class Timer;
@class PlayItem;

OBJC_EXPORT NSString *kPlayQueueDidPlayCompletely;

@interface PlayViewController : BaseViewController {
    PlayQueue *_playQueue;
    PlayItem *_playItem;
    
    PlayerStatusView *_playerStatusView;
    PlayerControlView *_playerControlView;
    
    Timer *_timer;
    Timer *_trackFinishTimer;
    
    UITableView *_tableView;
}

+ (id)sharedInstance;

- (void)playWithPlayQueue:(PlayQueue *)playQueue;

- (PlayItem *)currentPlayItem;

- (void)reset;

@end
