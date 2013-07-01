//
//  SoundSub.h
//  iSang
//
//  Created by yangzexin on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundSub : NSObject <NSCoding> {
    NSTimeInterval beginTime;
    NSTimeInterval endTime;
    NSString *title;
}

@property(nonatomic, retain)NSString *title;
@property(nonatomic, assign)NSTimeInterval beginTime;
@property(nonatomic, assign)NSTimeInterval endTime;

@end
