//
//  SimpleFileKeyValueManager.h
//  imysound
//
//  Created by yangzexin on 13-4-8.
//
//

#import <Foundation/Foundation.h>
#import "KeyValueManager.h"

@interface SimpleFileKeyValueManager : NSObject <KeyValueManager>

- (id)initWithFilePath:(NSString *)filePath;

@end
