//
//  NowPlayingViewController.m
//  imysound
//
//  Created by yangzexin on 12-10-15.
//
//

#import "NowPlayingViewController.h"
#import "Player.h"

@interface NowPlayingViewController ()

@property(nonatomic, retain)UIBarButtonItem *playButtonItem;
@property(nonatomic, retain)UIBarButtonItem *pauseButtonItem;
@property(nonatomic, retain)UIBarButtonItem *previousButtonItem;
@property(nonatomic, retain)UIBarButtonItem *nextButtonItem;
@property(nonatomic, retain)UIToolbar *toolbar;
@property(nonatomic, retain)UIBarButtonItem *playControlButtonItem;

@end

@implementation NowPlayingViewController

- (void)dealloc
{
    self.playButtonItem = nil;
    self.pauseButtonItem = nil;
    self.previousButtonItem = nil;
    self.nextButtonItem = nil;
    self.toolbar = nil;
    self.playControlButtonItem = nil;
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    self.playButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                        target:self action:@selector(onPlayButtonItemTapped)];
    self.pauseButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                                         target:self action:@selector(onPauseButtonTapped)];
    self.previousButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                            target:self action:@selector(onPreviousButtonItemTapped)];
    self.nextButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                        target:self action:@selector(onNextButtonItemTapped)];
    
    self.toolbar = [[[UIToolbar alloc] init] autorelease];
    self.toolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 44.0f, CGRectGetWidth(self.view.frame), 44.0f);
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.toolbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:self.toolbar];
    
    self.playControlButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
    self.playControlButtonItem.action = @selector(onPlayControlButtonItemTapped);
    self.playControlButtonItem.target = self;
    self.playControlButtonItem.style = UIBarButtonItemStyleDone;
    self.playControlButtonItem.title = [self.delegate currentPlayQueueControlTitleForNowPlayingViewController:self];
    self.navigationItem.rightBarButtonItem = self.playControlButtonItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.toolbar.items = [Player sharedInstance].playing ? [self toolbarItemsForPlaying] : [self toolbarItemsForPaused];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - events
- (void)onPlayButtonItemTapped
{
    [[Player sharedInstance] resume];
    self.toolbar.items = [Player sharedInstance].playing ? [self toolbarItemsForPlaying] : [self toolbarItemsForPaused];
}

- (void)onPauseButtonTapped
{
    [[Player sharedInstance] pause];
    self.toolbar.items = [Player sharedInstance].playing ? [self toolbarItemsForPlaying] : [self toolbarItemsForPaused];
}

- (void)onPreviousButtonItemTapped
{
    [Player sharedInstance].currentTime -= 2.0f;
}

- (void)onNextButtonItemTapped
{
    [Player sharedInstance].currentTime += 2.0f;
}

- (void)onPlayControlButtonItemTapped
{
    self.playControlButtonItem.title = [self.delegate nextPlayQueueControlTitleForNowPlayingViewController:self];
}

#pragma mark - private methods
- (UIBarButtonItem *)spaceItem
{
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
}

- (NSArray *)toolbarItemsForPlaying
{
    return [NSArray arrayWithObjects:self.spaceItem, self.previousButtonItem, self.spaceItem,
            self.pauseButtonItem, self.spaceItem, self.nextButtonItem, self.spaceItem, nil];
}

- (NSArray *)toolbarItemsForPaused
{
    return [NSArray arrayWithObjects:self.spaceItem, self.previousButtonItem, self.spaceItem,
            self.playButtonItem, self.spaceItem, self.nextButtonItem, self.spaceItem, nil];
}

@end
