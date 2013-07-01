//
//  GlossaryLibraryViewController.m
//  imyvoa
//
//  Created by yzx on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GlossaryLibraryViewController.h"
#import "DictionaryViewController.h"
#import "GlossaryDetailViewController.h"

@interface GlossaryLibraryViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, retain)id<GlossaryManager> glossaryManager;
@property(nonatomic, retain)NSArray *glossaryList;

@property(nonatomic, retain)UITableView *tableView;

@end

@implementation GlossaryLibraryViewController

@synthesize glossaryManager = _glossaryManager;
@synthesize glossaryList = _glossaryList;

@synthesize tableView = _tableView;

- (void)dealloc
{
    [_glossaryManager release];
    [_glossaryList release];
    
    [_tableView release];
    [super dealloc];
}

- (id)initWithGlossaryManager:(id<GlossaryManager>)glossaryManager
{
    self = [super init];
    
    self.title = NSLocalizedString(@"Glossary", nil);
    
    self.glossaryManager = glossaryManager;
    self.glossaryList = [self.glossaryManager wordList];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame;
    
    frame = self.view.bounds;
    frame.size.height -= self.navigationController.navigationBar.frame.size.height;
    self.tableView = [[[UITableView alloc] initWithFrame:frame 
                                                   style:UITableViewStylePlain] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - events
- (void)onBackBtnTapped
{
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    DictionaryViewController *dictVC = [DictionaryViewController sharedInstance];
//    [self.navigationController presentModalViewController:dictVC animated:YES];
//    [dictVC query:[self.glossaryList objectAtIndex:indexPath.row]];
    GlossaryDetailViewController *vc = [[GlossaryDetailViewController alloc] 
                                        initWithWord:[self.glossaryList objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.glossaryManager removeWord:[self.glossaryList objectAtIndex:indexPath.row]];
        self.glossaryList = [self.glossaryManager wordList];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.glossaryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"__id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:identifier] autorelease];
    }
    
    cell.textLabel.text = [self.glossaryList objectAtIndex:indexPath.row];
    
    return cell;
}

@end
