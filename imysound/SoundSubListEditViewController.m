//
//  SoundSubEditViewController.m
//  imysound
//
//  Created by yzx on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SoundSubListEditViewController.h"
#import "SoundSubManager.h"
#import "SoundSub.h"
#import "SoundSubEditViewController.h"
#import "CommonUtils.h"
#import "YXInputDialog.h"
#import <AVFoundation/AVFoundation.h>

@interface SoundSubListEditViewController () <UIAlertViewDelegate>

@property(nonatomic, copy)NSString *soundFilePath;
@property(nonatomic, retain)NSMutableArray *soundSubList;

@end

@implementation SoundSubListEditViewController

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
    
    self.title = NSLocalizedString(@"edit_sound_sub", nil);
    
    self.soundFilePath = soundFilePath;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)] autorelease];
    self.tableView.tableHeaderView = headerView;
    
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) 
                                                                style:UIBarButtonItemStyleBordered 
                                                               target:self 
                                                               action:@selector(onEditBtnTapped:)];
    self.navigationItem.rightBarButtonItem = editBtn;
    [editBtn release];
    
    UILabel *titleLabel = [[[UILabel alloc] init] autorelease];
    [headerView addSubview:titleLabel];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.text = [self.soundFilePath lastPathComponent];
    titleLabel.frame = CGRectMake(10, 0, headerView.frame.size.width - 20, headerView.frame.size.height);
    titleLabel.userInteractionEnabled = YES;
    [titleLabel addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_soundTitleTapped:)] autorelease]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _loadSubs];
}

- (void)_loadSubs
{
    NSArray *existSoundSubList = [[SoundSubManager sharedManager] subListForIdentifier:self.soundFilePath];
    if(existSoundSubList){
        self.soundSubList = [NSMutableArray arrayWithArray:existSoundSubList];
    }else{
        self.soundSubList = [NSMutableArray array];
    }
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - events
- (void)_soundTitleTapped:(id)gr
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Generate subs from lyrics?"
                                                         message:@""
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               otherButtonTitles:NSLocalizedString(@"OK", nil), nil] autorelease];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [self _generateSubsFromLyrics];
    }
}

- (void)_generateSubsFromLyrics
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.soundFilePath] options:nil];
    NSString *lyrics = asset.lyrics;
    
    NSArray *prefixs = @[@"Slow dialogue:", @"Explanations:", @"Fast dialogue:"];
    
    NSMutableArray *findedPrefixs = [NSMutableArray array];
    NSMutableArray *findedPrefixTimes = [NSMutableArray array];
    
    for (NSString *prefix in prefixs) {
        double time = [self _findTimeWithPrefix:prefix lyrics:lyrics];
        if (time != 0.0f) {
            [findedPrefixs addObject:[prefix substringToIndex:prefix.length - 1]];
            [findedPrefixTimes addObject:@(time)];
        }
    }
    
    NSMutableArray *soundSubs = [NSMutableArray array];
    for (NSInteger i = 0; i < findedPrefixs.count; ++i) {
        NSString *prefix = [findedPrefixs objectAtIndex:i];
        double fromTime = [[findedPrefixTimes objectAtIndex:i] doubleValue];
        double toTime = (i + 1) == findedPrefixTimes.count ? (asset.duration.value / asset.duration.timescale) : [[findedPrefixTimes objectAtIndex:i + 1] doubleValue];
        if (fromTime < toTime) {
            NSLog(@"%@, %f-%f", prefix, fromTime, toTime);
            SoundSub *sub = [[[SoundSub alloc] init] autorelease];
            sub.title = prefix;
            sub.beginTime = fromTime;
            sub.endTime = toTime;
            
            [soundSubs addObject:sub];
        }
    }
    
    [[SoundSubManager sharedManager] setSubListWithArray:soundSubs forIdentifier:self.soundFilePath];
    [self _loadSubs];
}

- (double)_findTimeWithPrefix:(NSString *)prefix lyrics:(NSString *)lyrics
{
    double time = 0;
    
    NSRange range = [lyrics rangeOfString:prefix];
    if (range.location != NSNotFound) {
        NSRange newLineRange = [lyrics rangeOfString:@"\n" options:0 range:NSMakeRange(range.location + range.length, lyrics.length - (range.location + range.length))];
        if (newLineRange.location == NSNotFound) {
            newLineRange = [lyrics rangeOfString:@"\r" options:0 range:NSMakeRange(range.location + range.length, lyrics.length - (range.location + range.length))];
        }
        if (newLineRange.location != NSNotFound) {
            NSString *timeString = [lyrics substringWithRange:NSMakeRange(range.location + range.length, newLineRange.location - (range.location + range.length))];
            timeString = [timeString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *timeAttrs = [timeString componentsSeparatedByString:@":"];
            for (NSInteger timeAttrIndex = 0; timeAttrIndex < timeAttrs.count; ++timeAttrIndex) {
                NSInteger base = 1;
                for (NSInteger i = timeAttrs.count - 1; i > timeAttrIndex; --i) {
                    base *= 60;
                }
                
                time += base * [[timeAttrs objectAtIndex:timeAttrIndex] integerValue];
            }
        }
    }
    
    return time;
}

- (void)onEditBtnTapped:(UIBarButtonItem *)editBtn
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    editBtn.style = self.tableView.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    editBtn.title = self.tableView.editing ? NSLocalizedString(@"Done", nil) : NSLocalizedString(@"Edit", nil);
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == self.soundSubList.count){
        SoundSubEditViewController *vc = [[[SoundSubEditViewController alloc] 
                                           initWithSoundFilePath:self.soundFilePath] autorelease];
        UINavigationController *nc = [[[UINavigationController alloc] 
                                       initWithRootViewController:vc] autorelease];
        [self presentModalViewController:nc animated:YES];
    }else{
        SoundSub *sub = [self.soundSubList objectAtIndex:indexPath.row];
        [YXInputDialog showWithTitle:@"输入新的分段名称" message:@"" initText:sub.title cancelButtonTitle:@"取消" approveButtonTitle:@"确定" completion:^(NSString *input) {
            if(input.length != 0){
                sub.title = input;
                [[SoundSubManager sharedManager] setSubListWithArray:self.soundSubList forIdentifier:self.soundFilePath];
                [self.tableView reloadData];
            }
        }];
    }
}

 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.soundSubList.count + 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.soundSubList removeObjectAtIndex:indexPath.row];
        [[SoundSubManager sharedManager] setSubListWithArray:self.soundSubList forIdentifier:self.soundFilePath];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row != self.soundSubList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row != self.soundSubList.count;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if(destinationIndexPath.row == self.soundSubList.count){
        [self.tableView reloadData];
    }else{
        [self.soundSubList exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        [[SoundSubManager sharedManager] setSubListWithArray:self.soundSubList forIdentifier:self.soundFilePath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifierSoundSub = @"sound_sub";
    static NSString *cellIdentifierAddSoundBtn = @"add_sound_btn";
    
    UITableViewCell *cell = nil;
    if(indexPath.row == self.soundSubList.count){
        // add btn
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierAddSoundBtn];
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                           reuseIdentifier:cellIdentifierAddSoundBtn] autorelease];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
        cell.textLabel.text = NSLocalizedString(@"add_sound_sub", nil);
    }else{
        // sound sub item
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSoundSub];
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                           reuseIdentifier:cellIdentifierSoundSub] autorelease];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
        }
        SoundSub *sub = [self.soundSubList objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [sub title]];
        
        NSInteger minute = sub.beginTime / 60;
        NSInteger second = (NSInteger)sub.beginTime % 60;
        NSString *beginTime = [NSString stringWithFormat:@"%@:%@", [CommonUtils formatTimeNumber:minute], [CommonUtils formatTimeNumber:second]];

        minute = sub.endTime / 60;
        second = (NSInteger)sub.endTime % 60;
        NSString *endTime = [NSString stringWithFormat:@"%@:%@", [CommonUtils formatTimeNumber:minute], [CommonUtils formatTimeNumber:second]];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@", beginTime, endTime];
    }
    
    return cell;
}

@end
