//
//  PlayViewController.m
//  imysound
//
//  Created by gewara on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"
#import "PlayQueue.h"
#import "PlayerStatusView.h"
#import "PlayerControlView.h"
#import "Player.h"
#import "Timer.h"
#import "PlayItem.h"
#import "PlayQueueControlFactory.h"
#import "NowPlayingViewController.h"
#import "SVDelayControl.h"

#define kTrackDelayTimeInterval     3.0f

NSString *kPlayQueueDidPlayCompletely = @"kPlayQueueDidPlayCompletely";

@interface PlayViewController () <PlayerStatusViewDelegate, PlayerControlViewDelegate, TimerDelegate, UITableViewDelegate, UITableViewDataSource, NowPlayingViewControllerDelegate>

@property(nonatomic, retain)PlayQueue *playQueue;
@property(nonatomic, retain)PlayItem *playItem;

@property(nonatomic, retain)PlayerStatusView *playerStatusView;
@property(nonatomic, retain)PlayerControlView *playerControlView;

@property(nonatomic, retain)Timer *timer;
@property(nonatomic, retain)Timer *trackFinishTimer;

@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)SVDelayControl *decidePreviousDelayControl;
@property(nonatomic, assign)BOOL isInPreviousTrackDelay;

- (void)playWithPlayItem:(PlayItem *)playItem;
- (NSTimeInterval)currentTimeWithPlayItem:(PlayItem *)playItem;
- (NSTimeInterval)totalTimeWithPlayItem:(PlayItem *)playItem;
- (void)onPlayQueueOver;

@end

@implementation PlayViewController

@synthesize playQueue = _playQueue;
@synthesize playItem = _playItem;

@synthesize playerStatusView = _playerStatusView;
@synthesize playerControlView = _playerControlView;

@synthesize timer = _timer;
@synthesize trackFinishTimer = _trackFinishTimer;

@synthesize tableView = _tableView;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playQueue release];
    [_playItem release];
    
    [_playerStatusView release];
    [_playerControlView release];
    
    [_timer cancel]; [_timer release];
    [_trackFinishTimer cancel]; [_trackFinishTimer release];
    
    [_tableView release];
    self.decidePreviousDelayControl = nil;
    [super dealloc];
}

+ (id)sharedInstance
{
    static PlayViewController *instance = nil;
    @synchronized(instance){
        if(instance == nil){
            instance = [[PlayViewController alloc] init];
        }
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    self.title = NSLocalizedString(@"now_playing", nil);
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playerStatusView = [[[PlayerStatusView alloc] init] autorelease];
    [self.view addSubview:self.playerStatusView];
    self.playerStatusView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60.0f);
    self.playerStatusView.delegate = self;
    
    self.playerControlView = [[[PlayerControlView alloc] init] autorelease];
    [self.view addSubview:self.playerControlView];
    CGFloat tmpY = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 44.0f;
    self.playerControlView.frame = CGRectMake(0, tmpY, self.view.bounds.size.width, 44.0f);
    self.playerControlView.delegate = self;
    
    self.tableView = [[[UITableView alloc] init] autorelease];
    [self.view addSubview:self.tableView];
    tmpY = self.playerStatusView.frame.origin.y + self.playerStatusView.frame.size.height;
    self.tableView.frame = CGRectMake(0, 
                                      tmpY, 
                                      self.view.bounds.size.width, 
                                      self.playerControlView.frame.origin.y - tmpY);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIBarButtonItem *nowPlayingButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"playing", nil)
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(onNowPlayingButtonItemTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = nowPlayingButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayNextNotification:) name:kPlayerPlayNextNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayPreviousNotification:) name:kPlayerPlayPreviousNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![Player sharedInstance].playing && ![self.playQueue finished]){
        if([Player sharedInstance].currentTime == 0.0f){
            [self playWithPlayItem:[self.playQueue currentPlayItem]];
        }else{
            if(self.playItem != [self.playQueue currentPlayItem]){
                [self playWithPlayItem:[self.playQueue currentPlayItem]];
            }
//            [[Player sharedInstance] play];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - events
- (void)playerPlayNextNotification:(NSNotification *)n
{
    [self playerControlViewDidControlToNext:self.playerControlView];
}

- (void)playerPlayPreviousNotification:(NSNotification *)n
{
    [self playerControlViewDidControlToPrevious:self.playerControlView];
}

- (void)onPlayerDidStartPlayNotification:(NSNotification *)n
{
    [self.playerControlView setPlaying:YES];
    PlayItem *currentItem = [self.playQueue currentPlayItem];
    if(currentItem){
        self.playerStatusView.currentTime = [self currentTimeWithPlayItem:currentItem];
        self.playerStatusView.totalTime = [self totalTimeWithPlayItem:currentItem];
    }
    
    if(self.timer){
        [self.timer cancel];
        self.timer = nil;
    }
    self.timer = [[[Timer alloc] init] autorelease];
    self.timer.delegate = self;
    [self.timer startWithTimeInterval:0.50f];
    
    if(self.trackFinishTimer){
        [self.trackFinishTimer cancel];
        self.trackFinishTimer = nil;
    }
    self.trackFinishTimer = [[[Timer alloc] init] autorelease];
    self.trackFinishTimer.delegate = self;
    [self.trackFinishTimer startWithTimeInterval:0.01];
    
    [self resetTrackDelay];
    
    [self.tableView reloadData];
}

- (void)resetTrackDelay
{
    self.isInPreviousTrackDelay = NO;
    __block typeof(self) bself = self;
    self.decidePreviousDelayControl = [[[SVDelayControl alloc] initWithInterval:kTrackDelayTimeInterval completion:^{
        bself.isInPreviousTrackDelay = YES;
    }] autorelease];
    [self.decidePreviousDelayControl start];
}

- (void)onPlayerDidPauseNotification:(NSNotification *)n
{
    [self.playerControlView setPlaying:NO];
    
    [self.timer cancel];
    self.timer = nil;
    [self.trackFinishTimer cancel];
    self.trackFinishTimer = nil;
}

- (void)onPlayerDidStopNotification:(NSNotification *)n
{
    [self.playerControlView setPlaying:NO];
    
    self.playItem = nil;
    
    [self.timer cancel];
    self.timer = nil;
    [self.trackFinishTimer cancel];
    self.trackFinishTimer = nil;
    
    self.playerStatusView.currentTime = 0.0f;
    self.playerStatusView.totalTime = 0.0f;
    
    if(!self.playQueue.finished){
        PlayItem *nextItem = [self.playQueue nextPlayItem];
        if(nextItem){
            [self playWithPlayItem:nextItem];
        }
    }
    
    [self.tableView reloadData];
}

- (NSString *)identifierForPlayQueueControl:(id<PlayQueueControl>)control
{
    return NSStringFromClass(control.class);
}

- (id<PlayQueueControl>)playQueueControlForIdentifier:(NSString *)identifier
{
    if([identifier isEqualToString:NSStringFromClass([PlayQueueControlFactory createLoopPlayQueueControl].class)]){
        return [PlayQueueControlFactory createLoopPlayQueueControl];
    }else if([identifier isEqualToString:NSStringFromClass([PlayQueueControlFactory createNormalPlayQueueControl].class)]){
        return [PlayQueueControlFactory createNormalPlayQueueControl];
    }else if([identifier isEqualToString:NSStringFromClass([PlayQueueControlFactory createSingleLoopPlayQueueControl].class)]){
        return [PlayQueueControlFactory createSingleLoopPlayQueueControl];
    }
    return [PlayQueueControlFactory createNormalPlayQueueControl];
}

- (NSString *)titleForPlayQueueControl:(id<PlayQueueControl>)control
{
    NSString *identifier = [self identifierForPlayQueueControl:control];
    if([identifier isEqualToString:NSStringFromClass([PlayQueueControlFactory createLoopPlayQueueControl].class)]){
        return NSLocalizedString(@"loop", nil);
    }else if([identifier isEqualToString:NSStringFromClass([PlayQueueControlFactory createNormalPlayQueueControl].class)]){
        return NSLocalizedString(@"normal", nil);
    }else if([identifier isEqualToString:NSStringFromClass([PlayQueueControlFactory createSingleLoopPlayQueueControl].class)]){
        return NSLocalizedString(@"single", nil);
    }
    return NSLocalizedString(@"normal", nil);
}

- (void)savePlayQueueControl:(id<PlayQueueControl>)control
{
    [[NSUserDefaults standardUserDefaults] setObject:[self identifierForPlayQueueControl:control] forKey:@"play_queue_control"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id<PlayQueueControl>)readPlayQueueControl
{
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"play_queue_control"];
    return [self playQueueControlForIdentifier:identifier];
}

- (void)onNowPlayingButtonItemTapped
{
    NowPlayingViewController *vc = [[[NowPlayingViewController alloc] init] autorelease];
    vc.title = self.playItem.title;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - instance methods
- (void)playWithPlayQueue:(PlayQueue *)playQueue
{
    if(![playQueue.currentPlayItem isEqual:self.playQueue.currentPlayItem]){
        [[Player sharedInstance] stop];
        
        self.playQueue = playQueue;
        self.playQueue.playQueueControl = [self readPlayQueueControl];
    }else{
        if([[Player sharedInstance].currentSoundFilePath isEqualToString:self.currentPlayItem.soundFilePath]){
            if(![Player sharedInstance].playing){
                [[Player sharedInstance] play];
            }
        }else{
            self.playQueue.finished = NO;
            [self playWithPlayItem:self.playQueue.currentPlayItem];
        }
    }
}

- (PlayItem *)currentPlayItem
{
//    return self.playQueue.finished ? nil : [self.playQueue currentPlayItem];
    return self.playItem;
}

- (void)removePlayerObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPlayerDidStartPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPlayerDidPauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPlayerDidStopNotification object:nil];
}

- (void)reset
{
    [self removePlayerObserver];
    [[Player sharedInstance] stop];
    [self onPlayQueueOver];
    [self onPlayerDidStopNotification:nil];
}

#pragma mark - private methods
- (void)playWithPlayItem:(PlayItem *)playItem
{
    [self removePlayerObserver];
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
    self.playItem = playItem;
    self.playQueue.finished = NO;
    Player *player = [Player sharedInstance];
    [player playSoundAtFilePath:playItem.soundFilePath autoPlay:NO];
    player.currentTime = playItem.beginTime;
    [player play];
}

- (NSTimeInterval)currentTimeWithPlayItem:(PlayItem *)playItem
{
    NSTimeInterval position = [Player sharedInstance].currentTime;
    return position - playItem.beginTime;
}

- (NSTimeInterval)totalTimeWithPlayItem:(PlayItem *)playItem
{
    return playItem.endTime - playItem.beginTime;
}

- (void)onPlayQueueOver
{
    [Player sharedInstance].currentTime = 0.0f;
    self.playQueue.finished = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlayQueueDidPlayCompletely object:nil];
    [self.tableView reloadData];
}

#pragma mark - NowPlayingViewControllerDelegate
- (NSString *)currentPlayQueueControlTitleForNowPlayingViewController:(NowPlayingViewController *)nowPlayingVC
{
    return [self titleForPlayQueueControl:self.playQueue.playQueueControl];
}

- (NSString *)nextPlayQueueControlTitleForNowPlayingViewController:(NowPlayingViewController *)nowPlayingVC
{
    NSString *title = [self titleForPlayQueueControl:self.playQueue.playQueueControl];
    if([title isEqualToString:NSLocalizedString(@"loop", nil)]){
        self.playQueue.playQueueControl = [PlayQueueControlFactory createNormalPlayQueueControl];
    }else if([title isEqualToString:NSLocalizedString(@"normal", nil)]){
        self.playQueue.playQueueControl = [PlayQueueControlFactory createSingleLoopPlayQueueControl];
    }else if([title isEqualToString:NSLocalizedString(@"single", nil)]){
        self.playQueue.playQueueControl = [PlayQueueControlFactory createLoopPlayQueueControl];
    }
    [self savePlayQueueControl:self.playQueue.playQueueControl];
    return [self titleForPlayQueueControl:self.playQueue.playQueueControl];
}

#pragma mark - TimerDelegate
- (void)timer:(Timer *)timer timerRunningWithInterval:(CGFloat)interval
{
    PlayItem *currentItem = [self.playQueue currentPlayItem];
    if(timer == self.timer){
        if(currentItem){
            self.playerStatusView.currentTime = [self currentTimeWithPlayItem:currentItem];
            self.playerStatusView.totalTime = [self totalTimeWithPlayItem:currentItem];
        }
//        NSLog(@"%@", timer);
    }else if(timer == self.trackFinishTimer){
        if(currentItem){
            NSTimeInterval currentTime = [self currentTimeWithPlayItem:currentItem];
            NSTimeInterval totalTime = [self totalTimeWithPlayItem:currentItem];
            if(currentTime >= totalTime){
                PlayItem *nextItem = [self.playQueue nextPlayItem];
                if(nextItem){
                    [self playWithPlayItem:nextItem];
                }else{
                    [[Player sharedInstance] stop];
                    [self onPlayerDidStopNotification:nil];
                    [self onPlayQueueOver];
                }
            }else{
//                NSLog(@"%@:%f->%f", timer, [self currentTimeWithPlayItem:currentItem], [self totalTimeWithPlayItem:currentItem]);
            }
        }
    }
}

#pragma mark - PlayerStatusViewDelegate
- (void)playerStatusView:(PlayerStatusView *)playerStatusView didChangeToNewPosition:(float)value
{
    PlayItem *playItem = [self.playQueue currentPlayItem];
    if(playItem){
        [Player sharedInstance].currentTime = playItem.beginTime + value;
    }
}

#pragma mark - PlayerControlViewDelegate
- (void)playerControlView:(PlayerControlView *)playerControlView didUpdatePlayStatus:(BOOL)playing
{
    if(!self.playQueue.finished){
        Player *player = [Player sharedInstance];
        if(playing){
            [player resume];
        }else{
            [player pause];
        }
    }else{
        [self.playQueue reset];
        [self playWithPlayItem:self.playQueue.currentPlayItem];
    }
}

- (void)playerControlViewDidControlToPrevious:(PlayerControlView *)playerControlView
{
    if(self.isInPreviousTrackDelay){
        [Player sharedInstance].currentTime = self.currentPlayItem.beginTime;
        [self resetTrackDelay];
        return;
    }
    PlayItem *previousItem = [self.playQueue goPrevious];
    if(previousItem){
        [self playWithPlayItem:previousItem];
    }else{
        [[Player sharedInstance] stop];
        [self onPlayQueueOver];
        [self onPlayerDidStopNotification:nil];
    }
}

- (void)playerControlViewDidControlToNext:(PlayerControlView *)playerControlView
{
    PlayItem *nextItem = [self.playQueue goNext];
    if(nextItem){
        [self playWithPlayItem:nextItem];
    }else{
        [[Player sharedInstance] stop];
        [self onPlayQueueOver];
        [self onPlayerDidStopNotification:nil];
    }
}

#pragma mark - UITableViewDelegate & UIITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlayItem *playItem = [self.playQueue playItemAtIndex:indexPath.row];
    [self playWithPlayItem:playItem];
    self.playQueue.currentPlayingIndex = indexPath.row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playQueue.numberOfPlayItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:identifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    PlayItem *item = [self.playQueue playItemAtIndex:indexPath.row];
    
    if([item isEqual:self.currentPlayItem]){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%02d %@", indexPath.row + 1, item.title];
    
    return cell;
}

@end
