//
//  TextBookmarkViewController.m
//  imysound
//
//  Created by gewara on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TextBookmarkViewController.h"
#import "TextBookmarkManager.h"
#import "TextBookmark.h"

@interface TextBookmarkViewController () <UIAlertViewDelegate>

@property(nonatomic, retain)NSString *identifier;
@property(nonatomic, retain)NSMutableArray *bookmarkList;

@property(nonatomic, retain)TextBookmarkManager *bookmarkMgr;

- (void)reloadBookmarkList;

@end

@implementation TextBookmarkViewController

@synthesize delegate = _delegate;

@synthesize identifier = _identifier;
@synthesize bookmarkList = _bookmarkList;

@synthesize bookmarkMgr = _bookmarkMgr;

- (void)dealloc
{
    [_identifier release];
    [_bookmarkList release];
    
    [_bookmarkMgr release];
    [super dealloc];
}

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    
    self.title = NSLocalizedString(@"Bookmarks", nil);
    self.identifier = identifier;
    self.bookmarkMgr = [TextBookmarkManager createManager];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                             target:self 
                                                                             action:@selector(onAddBookmarkBtnTapped)] autorelease];
    self.navigationItem.leftBarButtonItem = addBtn;
    
    UIBarButtonItem *doneBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                             target:self 
                                                                             action:@selector(onDondBtnTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = doneBtn;
    
    [self reloadBookmarkList];
}

#pragma mark - private methods
- (void)reloadBookmarkList
{
    self.bookmarkList = [NSMutableArray array];
    NSArray *existBookmarkList = [self.bookmarkMgr bookmarkListForIdentifier:self.identifier];
    if(existBookmarkList){
        [self.bookmarkList addObjectsFromArray:existBookmarkList];
    }
    
    [self.tableView reloadData];
}

#pragma mark - events
- (void)onAddBookmarkBtnTapped
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"enter_bookmark_title", nil) 
                                                        message:@"\n" 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 43, 252, 30)];
    [alertView addSubview:textField];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.tag = 27;
    textField.text = @"";
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [alertView show];
    [textField becomeFirstResponder];
    [alertView release];
}

- (void)onDondBtnTapped
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        UITextField *textField = (id)[alertView viewWithTag:27];
        NSString *bookmarkTitle = textField.text;
        CGFloat scrollPosition = [self.delegate scrollPositionForTextBookmarkViewControllerToAddNewBookmark:self];
        TextBookmark *bookmark = [[[TextBookmark alloc] init] autorelease];
        bookmark.title = bookmarkTitle;
        bookmark.scrollPosition = scrollPosition;
        [self.bookmarkMgr addBookmark:bookmark forIdentifier:self.identifier];
        [self reloadBookmarkList];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.delegate respondsToSelector:@selector(textBookmarkViewControllerDidSelectTextBookmark:)]){
        [self.delegate textBookmarkViewControllerDidSelectTextBookmark:[self.bookmarkList objectAtIndex:indexPath.row]];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.bookmarkList removeObjectAtIndex:indexPath.row];
        [self.bookmarkMgr setBookmarkList:self.bookmarkList forIdentifier:self.identifier];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bookmarkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:identifier] autorelease];
    }
    
    TextBookmark *bookmark = [self.bookmarkList objectAtIndex:indexPath.row];
    cell.textLabel.text = bookmark.title;
    
    return cell;
}

@end
