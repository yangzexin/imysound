//
//  FileGlossaryManager.h
//  imysound
//
//  Created by yangzexin on 13-4-8.
//
//

#import <Foundation/Foundation.h>
#import "GlossaryManager.h"

@interface FileGlossaryManager : NSObject <GlossaryManager>

- (id)initWithSRTFilePath:(NSString *)srtFilePath;

@end
