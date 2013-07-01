//
//  FileSoundSubManager.h
//  imysound
//
//  Created by yangzexin on 13-4-7.
//
//

#import <Foundation/Foundation.h>
#import "KeyValueManager.h"

@interface FileSoundSubManager : NSObject <KeyValueManager>

- (id)initWithSoundFilePath:(NSString *)soundFilePath;

@end
