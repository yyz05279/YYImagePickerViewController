//
//  YYBrowserCell.m
//  DDFood
//
//  Created by YZ Y on 16/9/19.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#import "YYBrowserCell.h"
#import "YYTapDetectingImageView.h"
#import "UIImageView+WebCache.h"

@interface YYBrowserCell () <UIScrollViewDelegate, YYTapDetectingImageViewDelegate>
@property (nonatomic, strong) UIScrollView *zoomingScrollView;
@property (nonatomic, strong) YYTapDetectingImageView *photoImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@end

@implementation YYBrowserCell

- (YYTapDetectingImageView *)photoImageView
{
    if (!_photoImageView) {
        _photoImageView = [[YYTapDetectingImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.tapDelegate = self;
        _photoImageView.contentMode = UIViewContentModeCenter;
        _photoImageView.backgroundColor = [UIColor blackColor];
        [self.zoomingScrollView addSubview:_photoImageView];
    }
    return _photoImageView;
}

- (UIScrollView *)zoomingScrollView
{
    if (!_zoomingScrollView) {
        _zoomingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width-20, self.frame.size.height)];
        _zoomingScrollView.delegate = self;
        _zoomingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
        _zoomingScrollView.showsHorizontalScrollIndicator = NO;
        _zoomingScrollView.showsVerticalScrollIndicator = NO;
        _zoomingScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _zoomingScrollView.userInteractionEnabled = YES;
        [self addSubview:_zoomingScrollView];
    }
    return _zoomingScrollView;
}

- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activity setCenter:self.center];
        [_activity setHidesWhenStopped:YES];
        [self addSubview:_activity];
    }
    return _activity;
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self zoomingScrollView];
        [self photoImageView];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    if (image == nil) {
        _image = [UIImage imageNamed:@"icon_placeholder"];
    }
    
    if (image != nil) {
        _image = image;
        [self displayImage];
    } else {
        [self.activity startAnimating];
    }
}

- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    UIImageView *imageView = [UIImageView new];
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.image = image;
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.photoImageView.image = nil;
    [self.photoImageView removeFromSuperview];
    [self.zoomingScrollView removeFromSuperview];
    self.zoomingScrollView = nil;
    self.photoImageView = nil;
    self.image = nil;
    self.activity = nil;
}

- (void)displayImage {
    self.zoomingScrollView.maximumZoomScale = 1;
    self.zoomingScrollView.minimumZoomScale = 1;
    self.zoomingScrollView.zoomScale = 1;
    self.zoomingScrollView.contentSize = CGSizeMake(0, 0);
    
    [self.activity stopAnimating];
    self.photoImageView.image = _image;
    self.photoImageView.hidden = NO;
    CGRect photoImageViewFrame;
    photoImageViewFrame.origin = CGPointZero;
    photoImageViewFrame.size = _image.size;
    self.photoImageView.frame = photoImageViewFrame;
    self.zoomingScrollView.contentSize = photoImageViewFrame.size;
    
    // Set zoom to minimum zoom
    [self setMaxMinZoomScalesForCurrentBounds];
    [self setNeedsLayout];
    
}


#pragma mark - Setup
- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.zoomingScrollView.minimumZoomScale;
    // Zoom image to fill if the aspect ratios are fairly similar
    CGSize boundsSize = self.zoomingScrollView.bounds.size;
    CGSize imageSize = self.photoImageView.image.size;
    CGFloat boundsAR = boundsSize.width / boundsSize.height;
    CGFloat imageAR = imageSize.width / imageSize.height;
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
    if (ABS(boundsAR - imageAR) < 0.17) {
        zoomScale = MAX(xScale, yScale);
        // Ensure we don't zoom in or out too far, just in case
        zoomScale = MIN(MAX(self.zoomingScrollView.minimumZoomScale, zoomScale), self.zoomingScrollView.maximumZoomScale);
    }
    return zoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    // Reset
    self.zoomingScrollView.maximumZoomScale = 1;
    self.zoomingScrollView.minimumZoomScale = 1;
    self.zoomingScrollView.zoomScale = 1;
    
    // Bail if no image
    if (_photoImageView.image == nil) return;
    
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.zoomingScrollView.bounds.size;
    CGSize imageSize = _photoImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
    CGFloat maxScale = 1.5;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // Set min/max zoom
    self.zoomingScrollView.maximumZoomScale = maxScale;
    self.zoomingScrollView.minimumZoomScale = minScale;
    
    // Initial zoom
    self.zoomingScrollView.zoomScale = [self initialZoomScaleWithMinScale];
    
    // If we're zooming to fill then centralise
    if (self.zoomingScrollView.zoomScale != minScale) {
        // Centralise
        self.zoomingScrollView.contentOffset = CGPointMake((imageSize.width * self.zoomingScrollView.zoomScale - boundsSize.width) / 2.0,
                                                           (imageSize.height * self.zoomingScrollView.zoomScale - boundsSize.height) / 2.0);
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        self.zoomingScrollView.scrollEnabled = NO;
    }
    
    // Layout
    [self setNeedsLayout];
    
}

#pragma mark - Layout

- (void)layoutSubviews {
    // Super
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.zoomingScrollView.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
        _photoImageView.frame = frameToCenter;
    
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.zoomingScrollView.scrollEnabled = YES; // reset
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection
/** 获取当前View的控制器对象 */
- (UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

- (void)handleSingleTap:(CGPoint)touchPoint {
    // Cancel any single tap handling
    [NSObject cancelPreviousPerformRequestsWithTarget:[self getCurrentViewController]];
    if (_delegate && [_delegate respondsToSelector:@selector(singleTap)]) {
        [_delegate singleTap];
    }
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    
    // Cancel any single tap handling
    [NSObject cancelPreviousPerformRequestsWithTarget:[self getCurrentViewController]];
    // Zoom
    if (self.zoomingScrollView.zoomScale != self.zoomingScrollView.minimumZoomScale && self.zoomingScrollView.zoomScale != [self initialZoomScaleWithMinScale]) {
        
        // Zoom out
        [self.zoomingScrollView setZoomScale:self.zoomingScrollView.minimumZoomScale animated:YES];
        
    } else {
        
        // Zoom in to twice the size
        CGFloat newZoomScale = ((self.zoomingScrollView.maximumZoomScale + self.zoomingScrollView.minimumZoomScale) / 2);
        CGFloat xsize = self.zoomingScrollView.bounds.size.width / newZoomScale;
        CGFloat ysize = self.zoomingScrollView.bounds.size.height / newZoomScale;
        [self.zoomingScrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(singleTap)]) {
        [_delegate singleTap];
    }
}

#pragma mark - YYTapDetectingImageViewDelegate
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

@end
