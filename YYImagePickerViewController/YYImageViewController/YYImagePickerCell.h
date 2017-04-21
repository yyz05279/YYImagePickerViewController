//
//  YYImagePickerCell.h
//  DDFood
//
//  Created by YZ Y on 16/10/8.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYImagePickerCellDelegate <NSObject>

- (void)didSelectImage:(NSIndexPath *)indexPath;
- (void)didDeselectImage:(NSIndexPath *)indexPath;

@end

@interface YYImagePickerCell : UICollectionViewCell
@property (nonatomic, assign) BOOL isCamera;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic ,strong) NSURL *url;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id <YYImagePickerCellDelegate> delegate;
- (void)setImage:(UIImage *)image indexPath:(NSIndexPath *)indexPath delegate:(id)delegate;

@end
