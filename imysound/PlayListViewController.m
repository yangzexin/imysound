//
//  PlayListViewController.m
//  imysound
//
//  Created by gewara on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayListViewController.h"

@implementation PlayListViewController

- (id)init
{
    self = [super init];
    
    self.title = NSLocalizedString(@"play_list", nil);
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
