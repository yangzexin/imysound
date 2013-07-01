//
//  PlayerControlView.h
//  imysound
//
//  Created by gewara on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerControlView;

@protocol PlayerControlViewDelegate <NSObject>

@optional
- (void)playerControlView:(PlayerControlView *)playerControlView didUpdatePlayStatus:(BOOL)playing;
- (void)playerControlViewDidControlToPrevious:(PlayerControlView *)playerControlView;
- (void)playerControlViewDidControlToNext:(PlayerControlView *)playerControlView;

@end

@interface PlayerControlView : UIView {
    id<PlayerControlViewDelegate> _delegate;
    
    UIToolbar *_toolbar;
    
    UIBarButtonItem *_playBtn;
    UIBarButtonItem *_pauseBtn;
    UIBarButtonItem *_previousBtn;
    UIBarButtonItem *_nextBtn;
    
    NSArray *_playingToolbarItemList;
    NSArray *_pausedToolbarItemList;
}

@property(nonatomic, assign)id<PlayerControlViewDelegate> delegate;

- (void)setPlaying:(BOOL)playing;
- (void)hidePreviousButton:(BOOL)hide;
- (void)hideNextButton:(BOOL)hide;

@end
