//
//  HexMaker.m
//  imysound
//
//  Created by gewara on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HexMaker.h"

@implementation HexMaker

- (void)dealloc
{
    free(_customHexList); _customHexList = NULL;
    [super dealloc];
}

- (id)init
{
    self = [self initWithHexList:@"0123456789ABCDEF"];
    
    return self;
}

- (id)initWithHexList:(NSString *)hexList
{
    self = [super init];
    
    _customHexList = malloc(hexList.length * sizeof(char));
    strcpy(_customHexList, [hexList UTF8String]);
    
    return self;
}

- (char)customHexCharForByte:(unsigned char )c
{
    return *(_customHexList + c);
}

- (unsigned char)byteForCustomHexChar:(char)c
{
    int len = strlen(_customHexList);
    for(int i = 0; i < len; ++i){
        if(c == *(_customHexList + i)){
            return i;
        }
    }
    return 0;
}

- (NSString *)hexStringForData:(NSData *)data
{
    return nil;
}

@end
