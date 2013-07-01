//
//  BaseViewController.m
//  imysound
//
//  Created by yzx on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "BaseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Player.h"

@interface BaseViewController ()

@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, copy)NSString *customTitle;

@end


@implementation BaseViewController

@synthesize titleLabel = _titleLabel;
@synthesize customTitle = _customTitle;

- (void)dealloc
{
    [_customTitle release];
    [_titleLabel release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.title = @"";
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)loadView
{
    [super loadView];
    
    self.titleLabel = [[[UILabel alloc] init] autorelease];
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.titleLabel.text = _customTitle;
    self.titleLabel.layer.shadowRadius = 0.5f;
    self.titleLabel.layer.shadowOpacity = 1.0f;
    self.titleLabel.layer.shadowOffset = CGSizeMake(0, -0.5f);
    self.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.frame = CGRectMake(0, 0, [_customTitle sizeWithFont:self.titleLabel.font].width, 
                                       self.titleLabel.font.lineHeight);
    self.navigationItem.titleView = self.titleLabel;
    
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if(event.subtype == UIEventSubtypeRemoteControlTogglePlayPause){
        if([Player sharedInstance].currentSoundFilePath.length != 0){
            [Player sharedInstance].playing ? [[Player sharedInstance] pause] : [[Player sharedInstance] play];
        }
    }else if(event.subtype == UIEventSubtypeRemoteControlNextTrack){
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerPlayNextNotification object:nil];
    }else if(event.subtype == UIEventSubtypeRemoteControlPreviousTrack){
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerPlayPreviousNotification object:nil];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)setCustomTitle:(NSString *)customTitle
{
    if(_customTitle != customTitle){
        [_customTitle release];
    }
    _customTitle = [customTitle copy];
    if(self.titleLabel){
        self.titleLabel.text = _customTitle;
        self.titleLabel.frame = CGRectMake(0, 0, 
                                           [_customTitle sizeWithFont:self.titleLabel.font].width, 
                                           self.titleLabel.font.lineHeight);
    }
}
- (void)setTitle:(NSString *)title
{
    [super setTitle:NSLocalizedString(@"Back", nil)];
    self.customTitle = title;
}

- (CGRect)fullBounds
{
    CGRect frame = self.view.bounds;
    frame.size.height -= self.navigationController.navigationBar.frame.size.height;
    frame.size.height -= self.tabBarController.tabBar.frame.size.height;
    
    return frame;
}

@end
