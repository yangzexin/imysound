//
//  NowPlayingViewController.m
//  imysound
//
//  Created by yangzexin on 12-10-15.
//
//

#import "NowPlayingViewController.h"
#import "Player.h"
#import <AVFoundation/AVFoundation.h>
#import "CommonUtils.h"
#import "DictionaryViewController.h"

@interface NowPlayingViewController () <DictionaryViewControllerDelegate>

@property(nonatomic, retain)UIBarButtonItem *playButtonItem;
@property(nonatomic, retain)UIBarButtonItem *pauseButtonItem;
@property(nonatomic, retain)UIBarButtonItem *previousButtonItem;
@property(nonatomic, retain)UIBarButtonItem *nextButtonItem;
@property(nonatomic, retain)UIToolbar *toolbar;
@property(nonatomic, retain)UIBarButtonItem *playControlButtonItem;

@property (nonatomic, retain) UITextView *textView;

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
    self.textView = nil;
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
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.toolbar.frame.size.height)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.editable = NO;
    self.textView.font = [UIFont systemFontOfSize:15.0f];
    [self.view addSubview:self.textView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureDictionaryMenuItem];
    
    self.toolbar.items = [Player sharedInstance].playing ? [self toolbarItemsForPlaying] : [self toolbarItemsForPaused];
    self.textView.text = [self _lyrics];
}

- (NSString *)_lyrics
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.soundFilePath] options:nil];
    NSString *lyrics = asset.lyrics;
    
    return lyrics;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)configureDictionaryMenuItem
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    NSMutableArray *menuItems = [NSMutableArray arrayWithArray:menuController.menuItems];
    BOOL dictMenuItemExists = NO;
    for(UIMenuItem *menuItem in menuItems){
        if([menuItem.title isEqualToString:NSLocalizedString(@"Dictionary", nil)]){
            dictMenuItemExists = YES;
            break;
        }
    }
    if(!dictMenuItemExists){
        UIMenuItem *dictMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Dictionary", nil)
                                                              action:@selector(onDictMenuItemTapped)];
        [menuItems addObject:dictMenuItem];
        [dictMenuItem release];
        menuController.menuItems = menuItems;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(onDictMenuItemTapped)){
        NSString *selectedText = [self.textView.text substringWithRange:self.textView.selectedRange];
        if([selectedText length] != 0){
            return ![CommonUtils stringContainsChinese:selectedText];
        }
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)onDictMenuItemTapped
{
    NSString *selectedText = [self.textView.text substringWithRange:self.textView.selectedRange];
    selectedText = [selectedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL multiLine = NO;
    if(selectedText.length > 32){
        multiLine = YES;
    }
    if(!multiLine){
        multiLine = [selectedText rangeOfString:@"\n"].length != 0;
    }
    if(![CommonUtils stringIsPureAlphabet:selectedText]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:multiLine ? @"\n\n\n\n" : @"\n"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        if(multiLine){
            UIView *bgView = [[[UIView alloc] init] autorelease];
            [alertView addSubview:bgView];
            bgView.frame = CGRectMake(15, 20, 252, 90);
            bgView.backgroundColor = [UIColor whiteColor];
            
            UITextView *textView = [[[UITextView alloc] init] autorelease];
            [alertView addSubview:textView];
            textView.backgroundColor = [UIColor clearColor];
            textView.tag = 100;
            textView.font = [UIFont systemFontOfSize:16.0f];
            CGFloat marginLeft = 4;
            CGFloat marginTop = 0;
            textView.frame = CGRectMake(bgView.frame.origin.x - marginLeft,
                                        bgView.frame.origin.y - marginTop,
                                        bgView.frame.size.width + marginLeft * 2,
                                        bgView.frame.size.height + marginTop * 2);
            textView.text = selectedText;
            [textView becomeFirstResponder];
        }else{
            UITextField *textField = [[[UITextField alloc] init] autorelease];
            [alertView addSubview:textField];
            textField.tag = 100;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.frame = CGRectMake(15, 20, 252, 30);
            textField.text = selectedText;
            textField.clearButtonMode = UITextFieldViewModeAlways;
            [textField becomeFirstResponder];
        }
        [alertView show];
        [alertView release];
    }else{
        [self searchWordByString:selectedText];
    }
}

- (void)searchWordByString:(NSString *)selectedText
{
    [self presentModalViewController:[DictionaryViewController sharedInstance] animated:YES];
    [[DictionaryViewController sharedInstance] query:selectedText];
    [DictionaryViewController sharedInstance].dictionaryViewControllerDelegate = self;
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
    [Player sharedInstance].currentTime -= 5.0f;
}

- (void)onNextButtonItemTapped
{
    [Player sharedInstance].currentTime += 5.0f;
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
