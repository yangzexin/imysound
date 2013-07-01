//
//  PlayItem.h
//  imysound
//
//  Created by yzx on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayItem : NSObject {
    NSString *soundFilePath;
    NSString *title;
    NSTimeInterval beginTime;
    NSTimeInterval endTime;
}

@property(nonatomic, copy)NSString *soundFilePath;
@property(nonatomic, copy)NSString *title;
@property(nonatomic, assign)NSTimeInterval beginTime;
@property(nonatomic, assign)NSTimeInterval endTime;

@end
