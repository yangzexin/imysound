//
//  SoundSubEditViewController.m
//  imysound
//
//  Created by yzx on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoundSubEditViewController.h"
#import "PlayerStatusView.h"
#import "PlayerControlView.h"
#import "Player.h"
#import "Timer.h"
#import "CommonUtils.h"
#import "SoundSub.h"
#import "SoundSubManager.h"

#define ALERT_TAG_INPUT 1001
#define ALERT_TAG_EXIT_CONFIRM 1002

@interface SoundSubEditViewController () <PlayerStatusViewDelegate, PlayerControlViewDelegate, TimerDelegate, UIAlertViewDelegate, PlayerDelegate>

@property(nonatomic, copy)NSString *soundFilePath;

@property(nonatomic, retain)PlayerStatusView *playerStatusView;
@property(nonatomic, retain)PlayerControlView *playerControlView;

@property(nonatomic, retain)Timer *timer;

@property(nonatomic, assign)NSTimeInterval beginTime;
@property(nonatomic, assign)NSTimeInterval endTime;

@property(nonatomic, retain)UIButton *markBeginTimeBtn;
@property(nonatomic, retain)UIButton *markEndTimeBtn;

@property(nonatomic, retain)Player *player;

- (NSString *)timeFormat:(NSTimeInterval)time;
- (void)updateTimeLabel;

@end

@implementation SoundSubEditViewController

@synthesize soundFilePath = _soundFilePath;

@synthesize playerStatusView = _playerStatusView;
@synthesize playerControlView = _playerControlView;

@synthesize timer = _timer;

@synthesize beginTime = _beginTime;
@synthesize endTime = _endTime;
@synthesize markBeginTimeBtn = _markBeginTimeBtn;
@synthesize markEndTimeBtn = _markEndTimeBtn;

@synthesize player = _player;

- (void)dealloc
{
    [_soundFilePath release];
    
    [_playerStatusView release];
    [_playerControlView release];
    
    [_timer cancel]; [_timer release];
    
    [_markBeginTimeBtn release];
    [_markEndTimeBtn release];
    [_player release];
    [super dealloc];
}

- (id)initWithSoundFilePath:(NSString *)soundFilePath
{
    self = [super init];
    
    self.title = NSLocalizedString(@"edit_sound_sub", nil);
    
    self.soundFilePath = soundFilePath;
    
    self.beginTime = 0.0f;
    self.endTime = 0.0f;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                             target:self 
                                                                             action:@selector(onDoneBtnTapped)];
    self.navigationItem.rightBarButtonItem = doneBtn;
    [doneBtn release];
    
    self.playerStatusView = [[[PlayerStatusView alloc] init] autorelease];
    [self.view addSubview:self.playerStatusView];
    self.playerStatusView.delegate = self;
    self.playerStatusView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    
    self.playerControlView = [[[PlayerControlView alloc] init] autorelease];
    [self.view addSubview:self.playerControlView];
    self.playerControlView.delegate = self;
    self.playerControlView.frame = CGRectMake(0, 
                                              self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 44, 
                                              self.view.frame.size.width, 
                                              44);
    [self.playerControlView hideNextButton:YES];
    [self.playerControlView hidePreviousButton:YES];
    
    UIButton *previousBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:previousBtn];
    previousBtn.frame = CGRectMake(10, 70, (self.view.bounds.size.width - 30) / 2, 40);
    [previousBtn setTitle:@"< 2s" forState:UIControlStateNormal];
    [previousBtn addTarget:self action:@selector(onPreviousBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:nextBtn];
    nextBtn.frame = CGRectMake(previousBtn.frame.origin.x + previousBtn.frame.size.width + 10, 
                               previousBtn.frame.origin.y, 
                               previousBtn.frame.size.width, 
                               previousBtn.frame.size.height);
    [nextBtn setTitle:@"> 2s" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(onNextBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.markBeginTimeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:self.markBeginTimeBtn];
    self.markBeginTimeBtn.frame = CGRectMake(10, 120, (self.view.bounds.size.width - 30) / 2, 40);
    [self.markBeginTimeBtn setTitle:NSLocalizedString(@"mark_begin_time", nil) forState:UIControlStateNormal];
    [self.markBeginTimeBtn addTarget:self action:@selector(onMarkBeginTimeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.markEndTimeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:self.markEndTimeBtn];
    self.markEndTimeBtn.frame = CGRectMake(self.markBeginTimeBtn.frame.origin.x + self.markBeginTimeBtn.frame.size.width + 10, 
                                           self.markBeginTimeBtn.frame.origin.y, 
                                           self.markBeginTimeBtn.frame.size.width, 
                                           self.markBeginTimeBtn.frame.size.height);
    [self.markEndTimeBtn setTitle:NSLocalizedString(@"mark_end_time", nil) forState:UIControlStateNormal];
    [self.markEndTimeBtn addTarget:self action:@selector(onMarkEndTimeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:saveBtn];
    saveBtn.frame = CGRectMake(60, 220, 200, 40);
    [saveBtn setTitle:NSLocalizedString(@"save_sound_sub", nil) forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(onSaveBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerDidStartPlayNotification:) 
                                                 name:kPlayerDidStartPlayNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerDidPauseNotification:) 
                                                 name:kPlayerDidPauseNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerDidStopNotification:) 
                                                 name:kPlayerDidStopNotification 
                                               object:nil];
    self.player = [[[Player alloc] init] autorelease];
    self.player.delegate = self;
    [self.player playSoundAtFilePath:self.soundFilePath autoPlay:NO];
    [self updateTimeLabel];
}

#pragma mark - private methods
- (NSString *)timeFormat:(NSTimeInterval)time
{
    NSInteger minute = time / 60;
    NSInteger second = (NSInteger)time % 60;
    NSTimeInterval dot = time - (NSInteger)time;
    NSString *dotString = [NSString stringWithFormat:@"%f", dot];
    dotString = [dotString substringFromIndex:1];
    return [NSString stringWithFormat:@"%@:%@%@", [CommonUtils formatTimeNumber:minute], 
            [CommonUtils formatTimeNumber:second], dotString];
}

- (void)updateTimeLabel
{
    self.playerStatusView.currentTime = self.player.currentTime;
    self.playerStatusView.totalTime = self.player.duration;
}

#pragma mark - events
- (void)onDoneBtnTapped
{
//    if(self.beginTime == 0.0f && self.endTime == 0.0f){
//        [self.player stop];
//        [self dismissModalViewControllerAnimated:YES];
//    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"exit_sound_edit_confirm", nil) 
                                                            message:nil 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alertView.tag = ALERT_TAG_EXIT_CONFIRM;
        [alertView show];
        [alertView release];
//    }
}

- (void)onPlayerDidStartPlayNotification:(NSNotification *)n
{
//    [self.playerControlView setPlaying:YES];
//    self.playerStatusView.totalTime = self.player.duration;
//    
//    if(self.timer){
//        [self.timer cancel];
//        self.timer = nil;
//    }
//    self.timer = [[[Timer alloc] init] autorelease];
//    self.timer.delegate = self;
//    [self.timer startWithTimeInterval:0.50f];
}

- (void)onPlayerDidPauseNotification:(NSNotification *)n
{
//    [self.playerControlView setPlaying:NO];
//    
//    [self.timer cancel];
//    self.timer = nil;
}

- (void)onPlayerDidStopNotification:(NSNotification *)n
{
//    [self.playerControlView setPlaying:NO];
//    self.playerStatusView.currentTime = 0.0f;
//    self.playerStatusView.totalTime = 0.0f;
//    
//    [self.timer cancel];
//    self.timer = nil;
}

- (void)onMarkBeginTimeBtnTapped
{
    self.beginTime = self.player.currentTime;
    [self.markBeginTimeBtn setTitle:[self timeFormat:self.beginTime] 
                           forState:UIControlStateNormal];
}

- (void)onMarkEndTimeBtnTapped
{
    self.endTime = self.player.currentTime;
    [self.markEndTimeBtn setTitle:[self timeFormat:self.endTime] 
                         forState:UIControlStateNormal];
}

- (void)onSaveBtnTapped
{
    if(self.endTime == 0.0f){
        [self alert:NSLocalizedString(@"end_time_zero_error", nil)];
        return;
    }
    if(self.beginTime > self.endTime){
        [self alert:NSLocalizedString(@"begin_time_later_than_end_time", nil)];
        return;
    }
    if(self.beginTime != 0.0f || self.endTime != 0.0f){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"enter_sub_name", nil) 
                                                            message:@"\n" 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alertView.tag = ALERT_TAG_INPUT;
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 43, 252, 30)];
        [alertView addSubview:textField];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.tag = 27;
        textField.text = [NSString stringWithFormat:@"%@-%@", [self timeFormat:self.beginTime], [self timeFormat:self.endTime]];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [alertView show];
        [textField becomeFirstResponder];
        [alertView release];
    }
}

- (void)onPreviousBtnTapped
{
    self.player.currentTime -= 2.0f;
    [self updateTimeLabel];
}

- (void)onNextBtnTapped
{
    self.player.currentTime += 2.0f;
    [self updateTimeLabel];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_TAG_INPUT){
        if(buttonIndex == 1){
            UITextField *textField = (id)[alertView viewWithTag:27];
            if(textField.text.length != 0){
                [self saveCurrentSoundSubWithTitle:textField.text];
            }else{
                [self onSaveBtnTapped];
            }
        }
    }else if(alertView.tag == ALERT_TAG_EXIT_CONFIRM){
        if(buttonIndex == 1){
            [self.player stop];
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

#pragma mark - TimerDelegate
- (void)timer:(Timer *)timer timerRunningWithInterval:(CGFloat)interval
{
    [self updateTimeLabel];
}

#pragma mark - instance methods
- (void)saveCurrentSoundSubWithTitle:(NSString *)title
{
    SoundSub *sub = [[[SoundSub alloc] init] autorelease];
    sub.title = title;
    sub.beginTime = self.beginTime;
    sub.endTime = self.endTime;
    
    NSArray *subList = [[SoundSubManager sharedManager] subListForIdentifier:self.soundFilePath];
    NSMutableArray *newSubList = nil;
    if(subList){
        newSubList = [NSMutableArray arrayWithArray:subList];
        [newSubList addObject:sub];
    }else{
        newSubList = [NSMutableArray arrayWithObject:sub];
    }
    [[SoundSubManager sharedManager] setSubListWithArray:newSubList forIdentifier:self.soundFilePath];
    [self alert:NSLocalizedString(@"sound_sub_save_succeed", nil)];
}

#pragma mark - PlayerStatusViewDelegate
- (void)playerStatusView:(PlayerStatusView *)playerStatusView didChangeToNewPosition:(float)value
{
    self.player.currentTime = value;
}

#pragma mark - PlayerControlViewDelegate
- (void)playerControlView:(PlayerControlView *)playerControlView didUpdatePlayStatus:(BOOL)playing
{
    Player *player = self.player;
    if(playing){
        if([player.currentSoundFilePath isEqualToString:self.soundFilePath] && !player.playing){
            [player resume];
        }else{
            [player play];
        }
    }else{
        [player pause];
    }
}

#pragma mark - PlayerDelegate
- (void)playerDidStartPlay:(Player *)player
{
    [self.playerControlView setPlaying:YES];
    self.playerStatusView.totalTime = self.player.duration;
    
    if(self.timer){
        [self.timer cancel];
        self.timer = nil;
    }
    self.timer = [[[Timer alloc] init] autorelease];
    self.timer.delegate = self;
    [self.timer startWithTimeInterval:0.50f];
}

- (void)playerDidPause:(Player *)player
{
    [self.playerControlView setPlaying:NO];
    
    [self.timer cancel];
    self.timer = nil;
}

- (void)playerDidStop:(Player *)player
{
    [self.playerControlView setPlaying:NO];
    self.playerStatusView.currentTime = 0.0f;
    self.playerStatusView.totalTime = 0.0f;
    
    [self.timer cancel];
    self.timer = nil;
}

@end
