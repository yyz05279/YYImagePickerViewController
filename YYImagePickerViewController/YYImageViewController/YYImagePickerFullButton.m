//
//  YYImagePickerFullButton.m
//  YYImagePickerViewController
//
//  Created by YZ Y on 17/4/21.
//  Copyright © 2017年 YYZ. All rights reserved.
//

#define kYYFullImageButtonFont  [UIFont systemFontOfSize:14]
#define BASE_WIDTH  750.0
#define WIN_WIDTH [UIScreen mainScreen].bounds.size.width
#define RELATIVE_WIDTH(w) WIN_WIDTH/BASE_WIDTH * w

#import "YYImagePickerFullButton.h"
#import "UIView+MJExtension.h"

static NSInteger const buttonPadding = 10;
static NSInteger const buttonImageWidth = 16;

@interface YYImagePickerFullButton()
@property (nonatomic, strong) UIButton *fullImageButton;
@property (nonatomic, strong) UILabel *imageSizeLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation YYImagePickerFullButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.mj_h = 28;
        self.mj_w = CGRectGetWidth([[UIScreen mainScreen] bounds]) / 2 - 20;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, RELATIVE_WIDTH(80), 28)];
        label.textColor = [UIColor whiteColor];
        label.text = @"原图";
        [self addSubview:label];
        [self fullImageButton];
        [self imageSizeLabel];
        [self indicatorView];
        self.selected = NO;
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.fullImageButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (UILabel *)imageSizeLabel
{
    if (nil == _imageSizeLabel) {
        _imageSizeLabel = [UILabel new];
        CGFloat labelWidth = self.mj_w - self.fullImageButton.mj_w;
        self.imageSizeLabel.mj_x = self.fullImageButton.mj_w + self.fullImageButton.mj_x;
        self.imageSizeLabel.mj_w = labelWidth;
        self.imageSizeLabel.mj_h = 28;
        _imageSizeLabel.backgroundColor = [UIColor clearColor];
        _imageSizeLabel.font = [UIFont systemFontOfSize:14.0f];
        _imageSizeLabel.textAlignment = NSTextAlignmentLeft;
        _imageSizeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_imageSizeLabel];
    }
    return _imageSizeLabel;
}

- (UIButton *)fullImageButton
{
    if (nil == _fullImageButton) {
        _fullImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullImageButton.mj_w = [self fullImageButtonWidth];
        _fullImageButton.mj_h = 28;
        _fullImageButton.backgroundColor = [UIColor clearColor];
        [_fullImageButton setTitle:@"原图" forState:UIControlStateNormal];
        _fullImageButton.titleLabel.font = kYYFullImageButtonFont;
        //        [_fullImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_fullImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_fullImageButton setImage:[UIImage imageNamed:@"photo_full_image_unselected"] forState:UIControlStateNormal];
        [_fullImageButton setImage:[UIImage imageNamed:@"photo_full_image_selected"] forState:UIControlStateSelected];
        _fullImageButton.contentVerticalAlignment = NSTextAlignmentRight;
        [_fullImageButton setTitleEdgeInsets:UIEdgeInsetsMake(6 , buttonPadding-buttonImageWidth, RELATIVE_WIDTH(12), 0)];
        [_fullImageButton setImageEdgeInsets:UIEdgeInsetsMake(RELATIVE_WIDTH(12), 0, RELATIVE_WIDTH(12), _fullImageButton.mj_w - buttonImageWidth)];
        _fullImageButton.enabled = NO;
        //        [self addSubview:_fullImageButton];
    }
    return _fullImageButton;
}


- (UIActivityIndicatorView *)indicatorView
{
    if (nil == _indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.fullImageButton.mj_w + self.fullImageButton.mj_x, 2, 26, 26)];
        _indicatorView.hidesWhenStopped = YES;
        [_indicatorView stopAnimating];
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (CGFloat)fullImageButtonWidth
{
    NSString *string = @"原图";
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:kYYFullImageButtonFont} context:nil];
    CGFloat width =  buttonPadding + CGRectGetWidth(rect);
    return width;
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        self.fullImageButton.selected = _selected;
        self.fullImageButton.mj_w = [self fullImageButtonWidth];
        [self.fullImageButton setTitleEdgeInsets:UIEdgeInsetsMake(0, buttonPadding-buttonImageWidth, 6, 0)];
        [self.fullImageButton setImageEdgeInsets:UIEdgeInsetsMake(6, 0, 6, self.fullImageButton.mj_w - buttonImageWidth)];
        CGFloat labelWidth = self.mj_w - self.fullImageButton.mj_w;
        self.imageSizeLabel.mj_x = self.fullImageButton.mj_w + self.fullImageButton.mj_x;
        self.imageSizeLabel.mj_w = labelWidth;
        self.imageSizeLabel.hidden = !_selected;
    }
}

- (void)setText:(NSString *)text
{
    self.imageSizeLabel.text = text;
}

- (void)shouldAnimating:(BOOL)animate
{
    if (self.selected) {
        self.imageSizeLabel.hidden = animate;
        if (animate) {
            [self.indicatorView startAnimating];
        } else {
            [self.indicatorView stopAnimating];
        }
    }
}

@end
