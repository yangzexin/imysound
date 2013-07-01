//
//  ViewTextViewController.m
//  imysound
//
//  Created by gewara on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewTextViewController.h"
#import "KeyValueManagerFactory.h"
#import "Player.h"
#import "PlayViewController.h"
#import "UITools.h"
#import "TextBookmarkViewController.h"
#import "TextBookmark.h"
#import "CommonUtils.h"
#import "DictionaryViewController.h"
#import "DBGlossaryManager.h"
#import "GlossaryLibraryViewController.h"
#import "FileGlossaryManager.h"

@interface ViewTextViewController () <UITextViewDelegate, TextBookmarkViewControllerDelegate, DictionaryViewControllerDelegate, UIAlertViewDelegate>

@property(nonatomic, copy)NSString *textFilePath;
@property(nonatomic, retain)id<KeyValueManager> keyTextFilePathValueScrollPosition;
@property(nonatomic, retain)id<TextBookmarkManager> bookmarkMgr;
@property(nonatomic, retain)id<GlossaryManager> glossaryMgr;

@property(nonatomic, retain)UITextView *textView;
@property(nonatomic, retain)UIBarButtonItem *nowPlayingBtn;

- (void)scrollTextViewToY:(CGFloat)y animated:(BOOL)animated;
- (void)configureDictionaryMenuItem;
- (void)searchWordByString:(NSString *)selectedText;

@end

@implementation ViewTextViewController

@synthesize textFilePath = _textFilePath;
@synthesize keyTextFilePathValueScrollPosition = _keyValueMgr;
@synthesize bookmarkMgr = _bookmarkMgr;
@synthesize glossaryMgr = _glossaryMgr;

@synthesize textView = _textView;
@synthesize nowPlayingBtn = _nowPlayingBtn;

- (void)dealloc
{
    [_textFilePath release];
    [_keyValueMgr release];
    [_bookmarkMgr release];
    [_glossaryMgr release];
    
    [_textView release];
    [_nowPlayingBtn release];
    [super dealloc];
}

- (id)initWithTextFilePath:(NSString *)filePath
{
    self = [super init];
    
    self.textFilePath = filePath;
    self.keyTextFilePathValueScrollPosition = [KeyValueManagerFactory createLocalDBKeyValueManagerWithName:@"text_position_"];
    self.bookmarkMgr = [TextBookmarkManager createManager];
//    self.glossaryMgr = [[[DBGlossaryManager alloc] initWithIdentifier:[filePath lastPathComponent]] autorelease];
    self.glossaryMgr = [[[FileGlossaryManager alloc] initWithSRTFilePath:filePath] autorelease];
    
    self.title = [self.textFilePath lastPathComponent];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.bounds;
    frame.size.height -= self.navigationController.navigationBar.frame.size.height;
    self.textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
    [self.view addSubview:self.textView];
    self.textView.editable = NO;
    self.textView.font = [UIFont systemFontOfSize:14.0f];
    
    self.textView.text = [NSString stringWithContentsOfFile:self.textFilePath encoding:NSASCIIStringEncoding error:nil];
    self.textView.delegate = self;
    
    [self scrollTextViewToY:[[self.keyTextFilePathValueScrollPosition valueForKey:self.textFilePath] floatValue] animated:NO];
    
    self.nowPlayingBtn = [[[UIBarButtonItem alloc] init] autorelease];
    self.nowPlayingBtn.title = NSLocalizedString(@"now_playing", nil);
    self.nowPlayingBtn.style = UIBarButtonItemStyleDone;
    self.nowPlayingBtn.target = self;
    self.nowPlayingBtn.action = @selector(onNowPlayingBtnTapped);
    if([Player sharedInstance].playing){
        self.navigationItem.rightBarButtonItem = self.nowPlayingBtn;
    }
    
    CGFloat tmpY = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 44.0f;
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:
                           CGRectMake(0, tmpY, self.view.bounds.size.width, 44.0f)] autorelease];
    [self.view addSubview:toolbar];
    toolbar.barStyle = UIBarStyleBlack;
    
    NSMutableArray *toolbarItems = [NSMutableArray array];
    
    [toolbarItems addObject:[UITools createFlexibleSpaceBarButtonItem]];
    UIBarButtonItem *bookmarkBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks 
                                                                                 target:self 
                                                                                 action:@selector(onBookmarkBtnTapped)] autorelease];
    [toolbarItems addObject:bookmarkBtn];
    [toolbarItems addObject:[UITools createFlexibleSpaceBarButtonItem]];
    
    [toolbarItems addObject:[UITools createFlexibleSpaceBarButtonItem]];
    UIBarButtonItem *glossaryBtn = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_glossary_list.png"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onGlossaryBtnTapped)] autorelease];
    [toolbarItems addObject:glossaryBtn];
    [toolbarItems addObject:[UITools createFlexibleSpaceBarButtonItem]];
    
    toolbar.items = toolbarItems;
    
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
    
    [self configureDictionaryMenuItem];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.keyTextFilePathValueScrollPosition setValue:[NSString stringWithFormat:@"%f", self.textView.contentOffset.y] forKey:self.textFilePath];
}

#pragma mark - TextBookmarkViewControllerDelegate
- (CGFloat)scrollPositionForTextBookmarkViewControllerToAddNewBookmark:(TextBookmarkViewController *)vc
{
    return self.textView.contentOffset.y;
}

- (void)textBookmarkViewControllerDidSelectTextBookmark:(TextBookmark *)bookmark
{
    [self scrollTextViewToY:bookmark.scrollPosition animated:YES];
}

#pragma mark - private methods
- (void)scrollTextViewToY:(CGFloat)y animated:(BOOL)animated
{
    [self.textView scrollRectToVisible:CGRectMake(0, y, self.textView.bounds.size.width, self.textView.bounds.size.height) 
                              animated:animated];
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

- (void)searchWordByString:(NSString *)selectedText
{
    [self presentModalViewController:[DictionaryViewController sharedInstance] animated:YES];
    [[DictionaryViewController sharedInstance] query:selectedText];
    [DictionaryViewController sharedInstance].dictionaryViewControllerDelegate = self;
}

#pragma mark - events
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

- (void)onGlossaryBtnTapped
{
    GlossaryLibraryViewController *vc = [[GlossaryLibraryViewController alloc] initWithGlossaryManager:self.glossaryMgr];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
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

- (void)onNowPlayingBtnTapped
{
    [self.navigationController pushViewController:[PlayViewController sharedInstance] animated:YES];
}

- (void)onBookmarkBtnTapped
{
    [self scrollTextViewToY:self.textView.contentOffset.y animated:NO];
    TextBookmarkViewController *vc = [[TextBookmarkViewController alloc] initWithIdentifier:self.textFilePath];
    vc.delegate = self;
    UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    nc.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
    [self presentModalViewController:nc animated:YES];
    [vc release];
}

- (void)onPlayerDidStartPlayNotification:(NSNotification *)n
{
    self.navigationItem.rightBarButtonItem = self.nowPlayingBtn;
}

- (void)onPlayerDidStopNotification:(NSNotification *)n
{
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - DictionaryViewControllerDelegate
- (BOOL)dictionaryViewController:(DictionaryViewController *)dictVC bookmarkWord:(NSString *)word
{
    [self.glossaryMgr addWord:word];
    return YES;
}

#pragma mark - UITextViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.keyTextFilePathValueScrollPosition setValue:[NSString stringWithFormat:@"%f", scrollView.contentOffset.y] forKey:self.textFilePath];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        id textView = (id)[alertView viewWithTag:100];
        [self searchWordByString:[textView text]];
    }
}

@end
