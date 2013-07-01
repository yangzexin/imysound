//
//  BaseTableViewController.m
//  imysound
//
//  Created by yzx on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

@synthesize tableView = _tableView;

- (void)dealloc
{
    [_tableView release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    CGRect frame;
    frame = self.view.bounds;
    frame.size.height -= self.navigationController.navigationBar.frame.size.height;
    
    _tableView = [[UITableView alloc] initWithFrame:frame];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_tableView release];
    _tableView = nil;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
