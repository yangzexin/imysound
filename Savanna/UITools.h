//
//  UITools.h
//  imyvoa
//
//  Created by yzx on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITools : NSObject

+ (UIBarButtonItem *)createFlexibleSpaceBarButtonItem;

+ (UIImage *)createPureColorImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)createPureColorImageWithColor:(UIColor *)color size:(CGSize)size text:(NSString *)text font:(UIFont *)font;

@end
