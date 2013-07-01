//
//  HexMaker.h
//  imysound
//
//  Created by gewara on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HexMaker : NSObject {
    char *_customHexList;
}

- (id)initWithHexList:(NSString *)hexList;
- (NSString *)hexStringForData:(NSData *)data;

@end
