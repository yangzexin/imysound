//
//  NowPlayingViewController.h
//  imysound
//
//  Created by yangzexin on 12-10-15.
//
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@class NowPlayingViewController;

@protocol NowPlayingViewControllerDelegate <NSObject>

- (NSString *)currentPlayQueueControlTitleForNowPlayingViewController:(NowPlayingViewController *)nowPlayingVC;
- (NSString *)nextPlayQueueControlTitleForNowPlayingViewController:(NowPlayingViewController *)nowPlayingVC;

@end

@interface NowPlayingViewController : BaseViewController {
    
}

@property(nonatomic, assign)id<NowPlayingViewControllerDelegate> delegate;

@end
