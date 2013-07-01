//
//  Cache.h
//  imysound
//
//  Created by gewara on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject {
    NSString *key;
    NSString *content;
    NSString *date;
}

@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSString *content;
@property(nonatomic, copy)NSString *date;

@end
