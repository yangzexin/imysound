//
//  SoundSubEditViewController.h
//  imysound
//
//  Created by yzx on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@class PlayerStatusView;
@class PlayerControlView;
@class Timer;
@class Player;

@interface SoundSubEditViewController : BaseViewController {
    NSString *_soundFilePath;
    
    PlayerStatusView    *_playerStatusView;
    PlayerControlView   *_playerControlView;
    
    Timer *_timer;
    
    NSTimeInterval _beginTime;
    NSTimeInterval _endTime;
    
    UIButton *_markBeginTimeBtn;
    UIButton *_markEndTimeBtn;
    
    Player *_player;
}

- (id)initWithSoundFilePath:(NSString *)soundFilePath;

@end
