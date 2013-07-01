//
//  GlossaryDetailViewController.m
//  imyvoa
//
//  Created by gewara on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GlossaryDetailViewController.h"
#import "OnlineDictionary.h"

@interface GlossaryDetailViewController () <UIWebViewDelegate, DictionaryDelegate>

@property(nonatomic, retain)NSString *word;
@property(nonatomic, retain)id<Dictionary> dictionary;

@property(nonatomic, retain)UIWebView *webView;

@end

@implementation GlossaryDetailViewController

@synthesize word = _word;
@synthesize dictionary = _dictionary;

@synthesize webView = _webView;

- (void)dealloc
{
    [_word release];
    [_dictionary release];
    
    [_webView release];
    [super dealloc];
}

- (id)initWithWord:(NSString *)word
{
    self = [super init];
    
    self.title = word;
    self.word = word;
    self.dictionary = [[[OnlineDictionary alloc] init] autorelease];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame;
    
    frame = self.view.bounds;
    frame.size.height -= self.navigationController.navigationBar.frame.size.height;
    self.webView = [[[UIWebView alloc] initWithFrame:frame] autorelease];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    
    [self.dictionary query:self.word delegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - DictionaryDelegate
- (void)dictionary:(id)dictionary didFinishWithResult:(id<DictionaryQueryResult>)result
{
    NSString *html = [result contentHTML];
    if(html.length != 0){
        [self.webView loadHTMLString:html baseURL:nil];
    }
}

- (void)dictionary:(id)dictionary didFailWithError:(NSError *)error
{
    [self showToastWithString:NSLocalizedString(@"error_network", nil) hideAfterInterval:2.0f];
}

@end
