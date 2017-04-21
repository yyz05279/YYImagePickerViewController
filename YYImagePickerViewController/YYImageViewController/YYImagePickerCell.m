//
//  YYImagePickerCell.m
//  DDFood
//
//  Created by YZ Y on 16/10/8.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#import "YYImagePickerCell.h"
#import "AppConstants.h"
#import "Masonry.h"

@interface YYImagePickerCell ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIButton *button;
@property (nonatomic, weak) UIView *selectedView;
@end

@implementation YYImagePickerCell

{
    NSIndexPath *_indexPath;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (UIButton *)button {
    if (!_button) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"ic_xuanzhongnormal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"ic_xuanzhongactived"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(clickSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        _button = button;
    }
    return _button;
}

- (UIView *)selectedView {
    if (!_selectedView) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
        [self.contentView addSubview:view];
        _selectedView = view;
        _selectedView.hidden = YES;
    }
    return _selectedView;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self imageView];
        [self selectedView];
        [self button];
    }
    return self;
}

- (void)clickSelectButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        self.selectedView.hidden = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectImage:)]) {
            [_delegate didSelectImage:_indexPath];
        }
    } else {
        self.selectedView.hidden = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(didDeselectImage:)]) {
            [_delegate didDeselectImage:_indexPath];
        }
    }
}

- (void)setIsCamera:(BOOL)isCamera
{
    _isCamera = isCamera;
    self.button.hidden = isCamera;
    if (isCamera) {
        self.imageView.image = [UIImage imageNamed:@"ic_camera_normal"];
    }
    
}

- (void)setImage:(UIImage *)image indexPath:(NSIndexPath *)indexPath delegate:(id)delegate
{
    _image = image;
    self.imageView.image = image;
    _delegate = delegate;
    _indexPath = indexPath;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    self.button.selected = isSelected;
    self.selectedView.hidden = !isSelected;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    WS(ws);
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.contentView);
    }];
    
    [self.selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.contentView);
    }];
    
    if (!self.button.hidden) {
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(ws.contentView.mas_top).offset(RELATIVE_WIDTH(10));
            make.right.equalTo(ws.contentView.mas_right).offset(-RELATIVE_WIDTH(10));
            make.size.mas_equalTo(CGSizeMake(RELATIVE_WIDTH(50), RELATIVE_WIDTH(50)));
        }];
    }
}

@end
