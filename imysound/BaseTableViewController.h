//
//  BaseTableViewController.h
//  imysound
//
//  Created by yzx on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource> {
@private
    UITableView *_tableView;
}

@property(nonatomic, readonly)UITableView *tableView;

@end
