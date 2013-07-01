//
//  DelayControl.m
//  GewaraSport
//
//  Created by yangzexin on 12-11-28.
//  Copyright (c) 2012年 gewara. All rights reserved.
//

#import "SVDelayControl.h"

@interface SVDelayControl ()

@property(nonatomic, copy)void(^completion)();
@property(nonatomic, assign)NSTimeInterval timeInterval;
@property(nonatomic, assign)BOOL performed;

@end

@implementation SVDelayControl

@synthesize completion;
@synthesize timeInterval;
@synthesize performed;

- (void)dealloc
{
    self.completion = nil;
    [super dealloc];
}

- (id)initWithInterval:(NSTimeInterval)pTimeInterval completion:(void(^)())pCompletion
{
    self = [super init];
    
    self.timeInterval = pTimeInterval;
    self.completion = pCompletion;
    
    return self;
}

- (void)cancel
{
    self.completion = nil;
}

- (void)delayDidFinish
{
    self.performed = YES;
    if(self.completion){
        self.completion();
    }
}

- (void)run
{
    @autoreleasepool {
        [NSThread sleepForTimeInterval:self.timeInterval];
        [self performSelectorOnMainThread:@selector(delayDidFinish) withObject:nil waitUntilDone:YES];
    }
}

- (id)start
{
    self.performed = NO;
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
    return self;
}

- (BOOL)providerShouldBeRemoveFromPool
{
    return self.performed;
}

- (void)providerWillRemoveFromPool
{
    [self cancel];
}

@end
