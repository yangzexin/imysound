//
//  SoundSubEditViewController.h
//  imysound
//
//  Created by yzx on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"

@interface SoundSubListEditViewController : BaseTableViewController {
    NSString *_soundFilePath;
    NSMutableArray *_soundSubList;
}

- (id)initWithSoundFilePath:(NSString *)soundFilePath;

@end
