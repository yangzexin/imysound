//
//  SoundSubPlayListViewController.m
//  imysound
//
//  Created by gewara on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoundSubPlayListViewController.h"
#import "SoundSub.h"
#import "SoundSubManager.h"
#import "CommonUtils.h"
#import "PlayViewController.h"
#import "PlayItem.h"
#import "PlayQueue.h"
#import "Player.h"

@interface SoundSubPlayListViewController ()

@property(nonatomic, retain)NSString *soundFilePath;
@property(nonatomic, retain)NSArray *soundSubList;

@end

@implementation SoundSubPlayListViewController

@synthesize soundFilePath = _soundFilePath;
@synthesize soundSubList = _soundSubList;

- (void)dealloc
{
    [_soundFilePath release];
    [_soundSubList release];
    [super dealloc];
}

- (id)initWithSoundFilePath:(NSString *)soundFilePath
{
    self = [super init];
    
    self.soundFilePath = soundFilePath;
    self.title = [self.soundFilePath lastPathComponent];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.soundSubList = [[SoundSubManager sharedManager] subListForIdentifier:self.soundFilePath];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayStateChanged:) 
                                                 name:kPlayerDidStartPlayNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayStateChanged:) 
                                                 name:kPlayerDidStopNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onPlayStateChanged:) 
                                                 name:kPlayQueueDidPlayCompletely 
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - events
- (void)onPlayStateChanged:(NSNotification *)n
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *playItemList = [NSMutableArray array];
    for(SoundSub *sub in self.soundSubList){
        PlayItem *item = [[[PlayItem alloc] init] autorelease];
        item.soundFilePath = self.soundFilePath;
        item.beginTime = sub.beginTime;
        item.endTime = sub.endTime;
        item.title = sub.title;
        [playItemList addObject:item];
    }
    PlayQueue *queue = [[[PlayQueue alloc] initWithPlayItemList:playItemList playAtIndex:indexPath.row] autorelease];
    PlayViewController *vc = [PlayViewController sharedInstance];
    [vc playWithPlayQueue:queue];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.soundSubList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                       reuseIdentifier:identifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    SoundSub *sub = [self.soundSubList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%02d %@", indexPath.row + 1, sub.title];
    
    NSInteger minute = sub.beginTime / 60;
    NSInteger second = (NSInteger)sub.beginTime % 60;
    NSString *beginTime = [NSString stringWithFormat:@"%@:%@", [CommonUtils formatTimeNumber:minute], [CommonUtils formatTimeNumber:second]];
    
    minute = sub.endTime / 60;
    second = (NSInteger)sub.endTime % 60;
    NSString *endTime = [NSString stringWithFormat:@"%@:%@", [CommonUtils formatTimeNumber:minute], [CommonUtils formatTimeNumber:second]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@", beginTime, endTime];
    
    PlayItem *currentPlayItem = [[PlayViewController sharedInstance] currentPlayItem];
    if([currentPlayItem.soundFilePath isEqualToString:self.soundFilePath] 
       && currentPlayItem.beginTime == sub.beginTime 
       && currentPlayItem.endTime == sub.endTime){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

@end
