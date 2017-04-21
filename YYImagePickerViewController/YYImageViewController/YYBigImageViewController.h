//
//  YYBigImageViewController.h
//  DDFood
//
//  Created by YZ Y on 16/9/19.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, YYBigImageViewSourceType) {
    YYBigImageViewSourceTypeImage,
    YYBigImageViewSourceTypeImageURL,
    YYBigImageViewSourceTypeImageAsset
};

typedef NS_ENUM(NSInteger, YYBigImageViewType) {
    YYBigImageViewTypeShow,
    YYBigImageViewTypeEdite,
    YYBigImageViewTypeNomal,
};

@protocol YYBigImageViewControllerDelegate <NSObject>

@optional
- (void)sendImagesFromPhotoBrowser;
- (NSUInteger)selectedPhotosNumberInPhotoBrowser;
- (BOOL)currentPhotoAssetIsSelected:(PHAsset *)asset withIndex:(NSInteger)index;
- (BOOL)selectedAsset:(PHAsset *)asset withIndex:(NSInteger)index;
- (void)deselectedAsset:(PHAsset *)asset withIndex:(NSInteger)index;
- (void)selectedFullImage:(BOOL)fullImage;

@end

@interface YYBigImageViewController : UIViewController 
@property (nonatomic, copy) NSArray *imageArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) YYBigImageViewSourceType sourceType;
@property (nonatomic, assign) YYBigImageViewType showType;
@property (nonatomic, weak) id <YYBigImageViewControllerDelegate> delegate;

@end
