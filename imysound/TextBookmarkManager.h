//
//  TextBookmarkManager.h
//  imysound
//
//  Created by gewara on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyValueManager.h"

@class TextBookmark;

@protocol TextBookmarkManager <NSObject>

- (void)addBookmark:(TextBookmark *)bookmark forIdentifier:(NSString *)identifier;
- (void)setBookmarkList:(NSArray *)bookmarkList forIdentifier:(NSString *)identifier;
- (NSArray *)bookmarkListForIdentifier:(NSString *)identifier;

@end

@interface TextBookmarkManager : NSObject <TextBookmarkManager> {
    id<KeyValueManager> _keyValueMgr;
}

+ (id<TextBookmarkManager>)createManager;

@end