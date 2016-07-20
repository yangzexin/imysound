//
//  SoundListViewController.m
//  imysound
//
//  Created by yzx on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoundListViewController.h"
#import "PopOutTableView.h"
#import "CommonUtils.h"
#import "SoundSubListEditViewController.h"
#import "ViewTextViewController.h"
#import "Player.h"
#import "PlayViewController.h"
#import "UITools.h"
#import "PlayItem.h"
#import "SoundSub.h"
#import "PlayQueue.h"
#import "SoundSubManager.h"
#import "SFiOSKit.h"

@interface SoundListViewController () <PopOutTableViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *soundFileList;

@property(nonatomic, retain)UIView *soundFilePopOutView;
@property(nonatomic, retain)UIView *otherFilePopOutView;

@property(nonatomic, retain)UIBarButtonItem *nowPlayingBtn;

- (NSString *)soundFileAtIndex:(NSInteger)index;

- (void)reloadSoundList;

@end

@implementation SoundListViewController

@synthesize tableView = _tableView;
@synthesize soundFileList = _soundFileList;

@synthesize soundFilePopOutView = _soundFilePopOutView;
@synthesize otherFilePopOutView = _otherFilePopOutView;

@synthesize nowPlayingBtn = _nowPlayingBtn;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView release];
    [_soundFileList release];
    
    [_soundFilePopOutView release];
    [_otherFilePopOutView release];
    
    [_nowPlayingBtn release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.title = NSLocalizedString(@"sound_list", nil);
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.tableView = [[[UITableView alloc] initWithFrame:self.fullBounds] autorelease];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    
//    UIView *soundFilePopOutView = [[[UIView alloc] initWithFrame:
//                           CGRectMake(0, 0, self.tableView.frame.size.width, 60)] autorelease];
//    self.soundFilePopOutView = soundFilePopOutView;
//    [self.tableView addSubviewToPopOutCell:soundFilePopOutView];
    
//    UIButton *viewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [soundFilePopOutView addSubview:viewBtn];
//    [viewBtn setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
//    [viewBtn addTarget:self action:@selector(onViewBtnTapped) forControlEvents:UIControlEventTouchUpInside];
//    viewBtn.frame = CGRectMake(10, 5, (self.tableView.frame.size.width - 30) / 2, 40);
//    [viewBtn setBackgroundImage:[UITools createPureColorImageWithColor:[UIColor grayColor] size:viewBtn.frame.size] 
//                       forState:UIControlStateNormal];
//    viewBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    
//    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [soundFilePopOutView addSubview:editBtn];
//    [editBtn setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
//    [editBtn addTarget:self action:@selector(onEditBtnTapped) forControlEvents:UIControlEventTouchUpInside];
//    editBtn.frame = CGRectMake(10 + (self.tableView.frame.size.width - 30) / 2 + 10, 
//                               5, 
//                               (self.tableView.frame.size.width - 30) / 2, 
//                               40);
//    [editBtn setBackgroundImage:[UITools createPureColorImageWithColor:[UIColor grayColor] size:editBtn.frame.size] 
//                       forState:UIControlStateNormal];
//    editBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    
    UIView *otherFilePopOutView = [[[UIView alloc] initWithFrame:
                                    CGRectMake(0, 0, self.tableView.frame.size.width, 60)] autorelease];
    self.otherFilePopOutView = otherFilePopOutView;
    
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [otherFilePopOutView addSubview:openBtn];
    [openBtn setTitle:NSLocalizedString(@"Open", nil) forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(onOpenBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *editBtnItem = [[[UIBarButtonItem alloc] init] autorelease];
    editBtnItem.title = NSLocalizedString(@"Edit", nil);
    editBtnItem.target = self;
    editBtnItem.action = @selector(onEditBtnItemTapped:);
    editBtnItem.style = UIBarButtonItemStyleBordered;
//    self.navigationItem.leftBarButtonItem = editBtnItem;
    
    self.nowPlayingBtn = [[[UIBarButtonItem alloc] init] autorelease];
    self.nowPlayingBtn.title = NSLocalizedString(@"now_playing", nil);
    self.nowPlayingBtn.style = UIBarButtonItemStyleDone;
    self.nowPlayingBtn.target = self;
    self.nowPlayingBtn.action = @selector(onNowPlayingBtnTapped);
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onApplicationBecomeActiveNotification:) 
                                                 name:UIApplicationDidBecomeActiveNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerDidStartPlayNotification:) 
                                                 name:kPlayerDidStartPlayNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerDidStopNotification:) 
                                                 name:kPlayerDidStopNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayerDidStopNotification:) 
                                                 name:kPlayQueueDidPlayCompletely 
                                               object:nil];
    
    UIRefreshControl *refreshControl = [[[UIRefreshControl alloc] init] autorelease];
    [refreshControl addTarget:self action:@selector(_dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self reloadSoundList];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - private methods
- (NSString *)soundFileAtIndex:(NSInteger)index
{
    return [[CommonUtils documentPath] stringByAppendingPathComponent:[self.soundFileList objectAtIndex:index]];
}

- (void)reloadSoundList
{
    NSArray *filterExtentions = @[@".playlist", @".glossary", @".bookmark"];
    NSArray *tmpFileList = [CommonUtils fileNameListInDocumentPath];
    self.soundFileList = [NSMutableArray array];
    for(NSString *tmpFileName in tmpFileList){
        BOOL isInFilterExtention = NO;
        NSString *lowerFileName = [tmpFileName lowercaseString];
        for(NSString *tmpExtention in filterExtentions){
            if([lowerFileName hasSuffix:tmpExtention]){
                isInFilterExtention = YES;
                break;
            }
        }
        if(!isInFilterExtention){
            [self.soundFileList addObject:tmpFileName];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - events
- (void)onEditBtnTapped
{
//    NSString *soundFilePath = [self soundFileAtIndex:self.tableView.selectedCellIndex];
//    SoundSubListEditViewController *vc = [[SoundSubListEditViewController alloc] initWithSoundFilePath:soundFilePath];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//    [vc release];
}

- (void)onNowPlayingBtnTapped
{
    [[PlayViewController sharedInstance] setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:[PlayViewController sharedInstance] animated:YES];
}

- (void)onViewBtnTapped
{
//    NSString *soundFilePath = [self soundFileAtIndex:self.tableView.selectedCellIndex];
//    
//    NSMutableArray *playItemList = [NSMutableArray array];
//    NSArray *soundSubList = [[SoundSubManager sharedManager] subListForIdentifier:soundFilePath];
//    for(SoundSub *sub in soundSubList){
//        PlayItem *item = [[[PlayItem alloc] init] autorelease];
//        item.soundFilePath = soundFilePath;
//        item.beginTime = sub.beginTime;
//        item.endTime = sub.endTime;
//        item.title = sub.title;
//        [playItemList addObject:item];
//    }
//    if (playItemList.count != 0) {
//        PlayQueue *queue = [[[PlayQueue alloc] initWithPlayItemList:playItemList playAtIndex:0] autorelease];
//        PlayViewController *vc = [PlayViewController sharedInstance];
//        vc.hidesBottomBarWhenPushed = YES;
//        [vc playWithPlayQueue:queue];
//        [self.navigationController pushViewController:vc animated:YES];
//    } else {
//        
//    }
}

- (void)_dropViewDidBeginRefreshing:(UIRefreshControl *)refreshControl
{
    [self reloadSoundList];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.50f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

- (void)onEditBtnItemTapped:(UIBarButtonItem *)editBtnItem
{
    editBtnItem.style = self.tableView.editing ? UIBarButtonItemStyleBordered : UIBarButtonItemStyleDone;
    editBtnItem.title = self.tableView.editing ? NSLocalizedString(@"Edit", nil) : NSLocalizedString(@"Done", nil);
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (void)onApplicationBecomeActiveNotification:(NSNotification *)n
{
    [self reloadSoundList];
}

- (void)onPlayerDidStartPlayNotification:(NSNotification *)n
{
    self.navigationItem.rightBarButtonItem = self.nowPlayingBtn;
}

- (void)onPlayerDidStopNotification:(NSNotification *)n
{
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - PopOutTableViewDelegate
- (BOOL)popOutTableView:(PopOutTableView *)tableView shouldShowPopOutCellAtIndex:(NSInteger)index
{
    NSString *filePath = [self soundFileAtIndex:index];
    
    if(![[filePath lowercaseString] hasSuffix:@".mp3"]){
        ViewTextViewController *vc = [[ViewTextViewController alloc] initWithTextFilePath:filePath];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        return NO;
    }
    return YES;
}

- (void)popOutTableView:(PopOutTableView *)popOutTableView deleteRowAtIndex:(NSInteger)index
{
    NSString *fileName = [self.soundFileList objectAtIndex:index];
    NSString *filePath = [[CommonUtils documentPath] stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    [self.soundFileList removeObjectAtIndex:index];
    [popOutTableView.tableView beginUpdates];
    [popOutTableView.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] 
                                     withRowAnimation:UITableViewRowAnimationFade];
    [popOutTableView.tableView endUpdates];
}

- (void)popOutTableView:(PopOutTableView *)popOutTableView willBeginEditingAtIndex:(NSInteger)index
{
//    if(index == self.tableView.selectedCellIndex){
//        [self.tableView collapsePopOutCell];
//    }
}

- (NSInteger)numberOfRowsInPopOutTableView:(PopOutTableView *)popOutTableView
{
    return self.soundFileList.count;
}

- (UITableViewCell *)popOutTableView:(PopOutTableView *)popOutTableView cellForRowAtIndex:(NSInteger)index
{
    static NSString *identifier = @"id";
    UITableViewCell *cell = [popOutTableView.tableView dequeueReusableCellWithIdentifier:identifier];
    SFLineView *bottomLine = nil;
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:identifier] autorelease];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.numberOfLines = 0;
        
        bottomLine = [[[SFLineView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 1, cell.contentView.frame.size.width, 1)] autorelease];
        bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        bottomLine.tag = 1001;
        bottomLine.color = [UIColor sf_colorWithRed:230 green:230 blue:230];
        bottomLine.alignment = SFLineViewAlignmentBottom;
        [cell.contentView addSubview:bottomLine];
    } else {
        bottomLine = (id)[cell.contentView viewWithTag:1001];
    }
    
    NSString *soundFilePath = [self.soundFileList objectAtIndex:index];
    bottomLine.hidden = (index == popOutTableView.selectedCellIndex) || (index == [self numberOfRowsInPopOutTableView:popOutTableView] - 1);
    cell.textLabel.text = [NSString stringWithFormat:@"%02d %@", index + 1, soundFilePath];
    cell.textLabel.textColor = [[soundFilePath lowercaseString] hasSuffix:@".mp3"] ? 
        [UIColor blackColor] : [UIColor grayColor];
    
    return cell;
}

- (CGFloat)popOutTableView:(PopOutTableView *)popOutTableView heightForRowAtIndex:(NSInteger)index
{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *soundFilePath = [self soundFileAtIndex:indexPath.row];
    
    if(![[soundFilePath lowercaseString] hasSuffix:@".mp3"]){
        ViewTextViewController *vc = [[[ViewTextViewController alloc] initWithTextFilePath:soundFilePath] autorelease];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSMutableArray *playItemList = [NSMutableArray array];
        NSArray *soundSubList = [[SoundSubManager sharedManager] subListForIdentifier:soundFilePath];
        for(SoundSub *sub in soundSubList){
            PlayItem *item = [[[PlayItem alloc] init] autorelease];
            item.soundFilePath = soundFilePath;
            item.beginTime = sub.beginTime;
            item.endTime = sub.endTime;
            item.title = sub.title;
            [playItemList addObject:item];
        }
        if (playItemList.count != 0) {
            PlayQueue *queue = [[[PlayQueue alloc] initWithPlayItemList:playItemList playAtIndex:0] autorelease];
            PlayViewController *vc = [PlayViewController sharedInstance];
            vc.hidesBottomBarWhenPushed = YES;
            [vc playWithPlayQueue:queue];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self alert:NSLocalizedString(@"This sound don't have any subs", nil)];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *soundFilePath = [self soundFileAtIndex:indexPath.row];
    SoundSubListEditViewController *vc = [[SoundSubListEditViewController alloc] initWithSoundFilePath:soundFilePath];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fileName = [self.soundFileList objectAtIndex:indexPath.row];
        NSString *filePath = [[CommonUtils documentPath] stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
        [self.soundFileList removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.soundFileList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *soundFilePath = [self.soundFileList objectAtIndex:indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@", soundFilePath];
    
    return [text sf_sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - 37, MAXFLOAT)].height + 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    SFLineView *bottomLine = nil;
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:identifier] autorelease];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        cell.textLabel.numberOfLines = 0;
        
        bottomLine = [[[SFLineView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 1, cell.contentView.frame.size.width, 1)] autorelease];
        bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        bottomLine.tag = 1001;
        bottomLine.color = [UIColor colorWithIntegerRed:230 green:230 blue:230];
        bottomLine.alignment = SFLineViewAlignmentBottom;
        [cell.contentView addSubview:bottomLine];
    } else {
        bottomLine = (id)[cell.contentView viewWithTag:1001];
    }
    
    NSString *soundFilePath = [self.soundFileList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", soundFilePath];
    BOOL isSound = [[soundFilePath lowercaseString] hasSuffix:@".mp3"];
    cell.textLabel.textColor = isSound ? [UIColor blackColor] : [UIColor grayColor];
    cell.accessoryType = isSound ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
    
    return cell;
}

@end
