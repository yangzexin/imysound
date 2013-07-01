//
//  TextBookmark.h
//  imysound
//
//  Created by gewara on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextBookmark : NSObject <NSCoding> {
    NSString *title;
    
    CGFloat scrollPosition;
}

@property(nonatomic, retain)NSString *title;
@property(nonatomic, assign)CGFloat scrollPosition;

@end
