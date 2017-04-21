//
//  YYImagePickerFullButton.h
//  YYImagePickerViewController
//
//  Created by YZ Y on 17/4/21.
//  Copyright © 2017年 YYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYImagePickerFullButton : UIView
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) NSString *text;

- (void)addTarget:(id)target action:(SEL)action;
- (void)shouldAnimating:(BOOL)animate;

@end
