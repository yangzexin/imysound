//
//  SoundListViewController.h
//  imysound
//
//  Created by yzx on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@class PopOutTableView;

@interface SoundListViewController : BaseViewController {
@private
    PopOutTableView *_tableView;
    NSMutableArray *_soundFileList;
    
    UIView *_soundFilePopOutView;
    UIView *_otherFilePopOutView;
    
    UIBarButtonItem *_nowPlayingBtn;
}

@end
