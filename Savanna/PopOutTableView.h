//
//  PopOutTableView.h
//  imyvoa
//
//  Created by yzx on 12-6-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PopOutTableView;

@protocol PopOutTableViewDelegate <NSObject>

@required
- (NSInteger)numberOfRowsInPopOutTableView:(PopOutTableView *)popOutTableView;
- (UITableViewCell *)popOutTableView:(PopOutTableView *)popOutTableView cellForRowAtIndex:(NSInteger)index;

@optional
- (BOOL)popOutTableView:(PopOutTableView *)tableView shouldShowPopOutCellAtIndex:(NSInteger)index;
- (void)popOutCellWillShowAtPopOutTableView:(PopOutTableView *)tableView;
- (CGFloat)popOutTableView:(PopOutTableView *)popOutTableView heightForRowAtIndex:(NSInteger)index;
- (void)popOutTableView:(PopOutTableView *)popOutTableView deleteRowAtIndex:(NSInteger)index;
- (void)popOutTableView:(PopOutTableView *)popOutTableView willBeginEditingAtIndex:(NSInteger)index;
- (void)popOutTableViewDidSelectPopOutCell:(PopOutTableView *)tableView;

@end

@interface PopOutTableView : UIView {
@private
    id<PopOutTableViewDelegate> _delegate;
    
    UITableView *_tableView;
    NSInteger _insertedIndex;
    NSInteger _tappingIndex;
    
    UITableViewCell *_popOutCell;
    BOOL _editable;
}

@property(nonatomic, assign)id<PopOutTableViewDelegate> delegate;

@property(nonatomic, readonly)UITableView *tableView;

@property(nonatomic, assign)BOOL editable;

- (void)addSubviewToPopOutCell:(UIView *)view;

- (NSInteger)selectedCellIndex;
- (NSInteger)tappingIndex;
- (void)collapsePopOutCell;

@end
