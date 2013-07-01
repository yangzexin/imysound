//
//  TextBookmarkViewController.h
//  imysound
//
//  Created by gewara on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

@class TextBookmark;
@class TextBookmarkManager;
@class TextBookmarkViewController;

@protocol TextBookmarkViewControllerDelegate <NSObject>

@required
- (CGFloat)scrollPositionForTextBookmarkViewControllerToAddNewBookmark:(TextBookmarkViewController *)vc;

@optional
- (void)textBookmarkViewControllerDidSelectTextBookmark:(TextBookmark *)bookmark;

@end

@interface TextBookmarkViewController : BaseTableViewController {
    id<TextBookmarkViewControllerDelegate> _delegate;
    
    NSString *_identifier;
    NSMutableArray *_bookmarkList;
    
    TextBookmarkManager *_bookmarkMgr;
}

@property(nonatomic, assign)id<TextBookmarkViewControllerDelegate> delegate;

- (id)initWithIdentifier:(NSString *)identifier;

@end
