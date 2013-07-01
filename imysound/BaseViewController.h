//
//  BaseViewController.h
//  imysound
//
//  Created by yzx on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseViewController : UIViewController {
@private
    NSString *_customTitle;
    UILabel *_titleLabel;
}

- (CGRect)fullBounds;

@end
