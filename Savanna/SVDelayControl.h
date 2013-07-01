//
//  DelayControl.h
//  GewaraSport
//
//  Created by yangzexin on 12-11-28.
//  Copyright (c) 2012年 gewara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProviderPool.h"

@interface SVDelayControl : NSObject <SVProviderPoolable>

- (id)initWithInterval:(NSTimeInterval)timeInterval completion:(void(^)())completion;
- (id)start;
- (void)cancel;

@end
