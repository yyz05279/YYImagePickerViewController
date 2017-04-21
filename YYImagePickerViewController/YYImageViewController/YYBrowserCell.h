//
//  YYBrowserCell.h
//  DDFood
//
//  Created by YZ Y on 16/9/19.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYBrowserCellDelegate <NSObject>
@optional
- (void)singleTap;

@end

@interface YYBrowserCell : UICollectionViewCell
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, weak) id <YYBrowserCellDelegate> delegate;

@end
