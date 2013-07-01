//
//  UITools.m
//  imyvoa
//
//  Created by yzx on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UITools.h"

@implementation UITools

+ (UIBarButtonItem *)createFlexibleSpaceBarButtonItem
{
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                          target:nil 
                                                          action:nil] autorelease];
}

+ (UIImage *)createPureColorImageWithColor:(UIColor *)color size:(CGSize)size
{
    float width = size.width;
    float height = size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, 
                                                 width, 
                                                 height, 
                                                 8, 
                                                 4 * width, 
                                                 colorSpace, 
                                                 kCGImageAlphaPremultipliedFirst);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return img;
}

+ (UIImage *)createPureColorImageWithColor:(UIColor *)color size:(CGSize)size text:(NSString *)text font:(UIFont *)font
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, 
                                                 size.width, 
                                                 size.height, 
                                                 8, 
                                                 4 * size.width, 
                                                 colorSpace, 
                                                 kCGImageAlphaPremultipliedLast);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    float textWidth = [text sizeWithFont:font].width;
    float textHeight = font.pointSize;
    float textX = (size.width - textWidth) / 2;
    float textY = (size.height - textHeight) / 2;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSelectFont(context, "Helvetica", font.pointSize, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    CGContextShowTextAtPoint(context, textX, textY + 2, [text UTF8String], text.length);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return img;
}

@end
