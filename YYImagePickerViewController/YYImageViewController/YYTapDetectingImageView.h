//
//  YYTapDetectingImageView.h
//  DDFood
//
//  Created by YZ Y on 16/9/19.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYTapDetectingImageViewDelegate <NSObject>

@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end

@interface YYTapDetectingImageView : UIImageView
@property (nonatomic, weak) id <YYTapDetectingImageViewDelegate> tapDelegate;

@end
