//
//  SoundSubPlayListViewController.h
//  imysound
//
//  Created by gewara on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"

@interface SoundSubPlayListViewController : BaseTableViewController {
    NSString *_soundFilePath;
    NSArray *_soundSubList;
}

- (id)initWithSoundFilePath:(NSString *)soundFilePath;

@end
