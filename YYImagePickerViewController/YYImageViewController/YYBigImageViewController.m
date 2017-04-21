//
//  YYBigImageViewController.m
//  DDFood
//
//  Created by YZ Y on 16/9/19.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#define maxImageCount 5
//rgb颜色转换（16进制->10进制）
#import "YYBigImageViewController.h"
#import "YYBrowserCell.h"
#import "YYImagePickerFullButton.h"
#import "AppConstants.h"
#import "MBProgressHUD.h"

static NSString *const cellID = @"YYBigImageViewCellID";
@interface YYBigImageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, YYBrowserCellDelegate>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) YYImagePickerFullButton *fullImageButton;
@property (nonatomic, strong) UIButton *editorButton;
@property (nonatomic, strong) NSMutableArray *selectedAssetArray;

@end

@implementation YYBigImageViewController

{
    BOOL _statusBarShouldBeHidden;
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    BOOL _viewIsActive;
    BOOL _viewHasAppearedInitially;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;
    UIImage *_previousEditedImage;
    UINavigationBar *_previousNavigationBar;
}

- (NSMutableArray *)selectedAssetArray {
    if (!_selectedAssetArray) {
        _selectedAssetArray = [NSMutableArray array];
    }
    return _selectedAssetArray;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"ic_xuanzhongnormal"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"ic_xuanzhongactived"] forState:UIControlStateSelected];
        _selectButton.frame = CGRectMake(0, 0, RELATIVE_WIDTH(50), RELATIVE_WIDTH(50));
        [_selectButton addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, RELATIVE_WIDTH(220), RELATIVE_WIDTH(88));
        button.layer.cornerRadius = CommonCornerRadius;
        button.layer.masksToBounds = YES;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(sendAcction) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:RELATIVE_WIDTH(36)];
        _sendButton = button;
    }
    return _sendButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.itemSize = CGSizeMake(WIN_WIDTH + 20, WIN_HEIGHT);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        //必须这样设置frame
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, WIN_WIDTH + 20, WIN_HEIGHT + 1) collectionViewLayout:flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[YYBrowserCell class] forCellWithReuseIdentifier:cellID];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}


- (UIToolbar *)toolBar {
    if (_showType == YYBigImageViewTypeShow) {
        return nil;
    }
    if (!_toolBar) {
        CGFloat height = BottomProductHeight;
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, WIN_HEIGHT - height, WIN_WIDTH, height)];
        if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
            [_toolBar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
            [_toolBar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsCompact];
        }
        _toolBar.barStyle = UIBarStyleBlackTranslucent;
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:_showType == YYBigImageViewTypeNomal ? self.fullImageButton : self.editorButton];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithCustomView:self.sendButton];
        UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        item4.width = -10;
        
        [_toolBar setItems:@[item1,item2,item3,item4]];
        
        [self.view addSubview:_toolBar];
    }
    return _toolBar;
}


- (YYImagePickerFullButton *)fullImageButton {
    if (!_fullImageButton) {
        _fullImageButton = [[YYImagePickerFullButton alloc] init];
        _fullImageButton.selected = YES;
    }
    return _fullImageButton;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (_sourceType == YYBigImageViewSourceTypeImageAsset) {
        [self updateSelestedNumber];
        
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self updateNavigationBarAndToolBar];
    if (_showType == YYBigImageViewTypeEdite || _showType == YYBigImageViewTypeNomal) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectButton];
    }
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Super
    [super viewWillAppear:animated];
    _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    
    // Navigation bar appearance
    if (!_viewIsActive && [self.navigationController.viewControllers objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    
    // Initial appearance
    if (!_viewHasAppearedInitially) {
        _viewHasAppearedInitially = YES;
    }
    //scroll to the current offset
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:RELATIVE_WIDTH(36)], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self setControlsHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Super
    [super viewWillDisappear:animated];
    // Check that we're being popped for good
    if ([self.navigationController.viewControllers objectAtIndex:0] != self &&
        ![self.navigationController.viewControllers containsObject:self]) {
        
        _viewIsActive = NO;
        [self restorePreviousNavBarAppearance:animated];
    }
    
    [self.navigationController.navigationBar.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:RELATIVE_WIDTH(36)], NSForegroundColorAttributeName:YYTextColor}];
    [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _viewIsActive = NO;
    
}

#pragma mark - 点击事件
- (void)selectImage:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectedAsset:withIndex:)]) {
            sender.selected = [_delegate selectedAsset:self.imageArray[self.currentIndex] withIndex:self.currentIndex];
            if (!sender.selected) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = [NSString stringWithFormat:@"最多选择%@张图片", @(maxImageCount)];
                [hud hide:YES afterDelay:1.5];
            }
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(deselectedAsset:withIndex:)]) {
            [_delegate deselectedAsset:self.imageArray[self.currentIndex] withIndex:self.currentIndex];
        }
    }
    [self updateSelestedNumber];
}

- (void)sendAcction
{
    [self.navigationController popViewControllerAnimated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(sendImagesFromPhotoBrowser)]) {
        [_delegate sendImagesFromPhotoBrowser];
    }
}

#pragma mark - Nav Bar Appearance
- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = nil;
        navBar.shadowImage = nil;
    }
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
    }
}

- (void)storePreviousNavBarAppearance {
    _didSavePreviousStateOfNavBar = YES;
    if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
        _previousNavBarBarTintColor = self.navigationController.navigationBar.barTintColor;
    }
    _previousNavBarTranslucent = self.navigationController.navigationBar.translucent;
    _previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarHidden = self.navigationController.navigationBarHidden;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        _previousNavigationBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        _previousNavigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompact];
    }
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    if (_didSavePreviousStateOfNavBar) {
        [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.tintColor = _previousNavBarTintColor;
        navBar.translucent = _previousNavBarTranslucent;
        if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
            navBar.barTintColor = _previousNavBarBarTintColor;
        }
        navBar.barStyle = _previousNavBarStyle;
        if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
            [navBar setBackgroundImage:_previousNavigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
            [navBar setBackgroundImage:_previousNavigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsCompact];
        }
        // Restore back button if we need to
        if (_previousViewControllerBackButton) {
            UIViewController *previousViewController = [self.navigationController topViewController]; // We've disappeared so previous is now top
            previousViewController.navigationItem.backBarButtonItem = _previousViewControllerBackButton;
            _previousViewControllerBackButton = nil;
        }
    }
}

#pragma mark - 更新界面
- (void)updateNavigationBarAndToolBar {
    NSUInteger totalNumber = self.imageArray.count;
    self.title = [NSString stringWithFormat:@"%@/%@",@(self.currentIndex + 1),@(totalNumber)];
    if (_sourceType == YYBigImageViewSourceTypeImageAsset) {
        BOOL isSeleted = NO;
        if ([self.delegate respondsToSelector:@selector(currentPhotoAssetIsSelected:withIndex:)]) {
            isSeleted = [self.delegate currentPhotoAssetIsSelected:self.imageArray[self.currentIndex] withIndex:self.currentIndex];
        }
        self.selectButton.selected = isSeleted;
    
        PHAsset *asset = self.imageArray[self.currentIndex];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSData * imageData = UIImageJPEGRepresentation(result,1);
            NSInteger size = (NSUInteger)([imageData length]/1024);
            CGFloat imageSize = (CGFloat)size;
            NSString *imageSizeString;
            if (size > 1024) {
                imageSize = imageSize / 1024.0f;
                imageSizeString = [NSString stringWithFormat:@"(%.1fM)",imageSize];
            } else {
                imageSizeString = [NSString stringWithFormat:@"(%@K)",@(size)];
            }
            self.fullImageButton.text = imageSizeString;
            _previousEditedImage = result;
        }];
    }
}

- (void)updateSelestedNumber
{
    NSUInteger selectedNumber = 0;
    if ([self.delegate respondsToSelector:@selector(selectedPhotosNumberInPhotoBrowser)]) {
        selectedNumber = [self.delegate selectedPhotosNumberInPhotoBrowser];
    }
    
    if (selectedNumber) {
        self.sendButton.enabled = YES;
        [self.sendButton setTitle:[NSString stringWithFormat:@"完成(%@/%@)",@(selectedNumber), @(maxImageCount)] forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.sendButton.backgroundColor = YYGlobalColor;
    }
    else {
        [self.sendButton setTitle:@"请选择图片" forState:UIControlStateNormal];
        self.sendButton.backgroundColor = [UIColor grayColor];
        self.sendButton.enabled = NO;
    }
}


#pragma mark - UICollectionViewDelegate/DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YYBrowserCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.delegate = self;
    
    switch (_sourceType) {
        case YYBigImageViewSourceTypeImage:
        {
            cell.image = self.imageArray[indexPath.item];
        }
            break;
        case YYBigImageViewSourceTypeImageURL:
        {
            cell.imageURL = self.imageArray[indexPath.item];
        }
            break;
        case YYBigImageViewSourceTypeImageAsset:
        {
            PHAsset *asset = self.imageArray[indexPath.item];
            PHImageManager *manager = [PHImageManager defaultManager];
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                cell.image = result;
            }];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - YYBrowserCellDelegate
- (void)singleTap
{
    [self setControlsHidden:!_previousNavBarHidden animated:YES];
}

#pragma mark - scrollerViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_sourceType == YYBigImageViewSourceTypeImageAsset) {
        CGFloat offsetX = scrollView.contentOffset.x;
        CGFloat itemWidth = CGRectGetWidth(self.collectionView.frame);
        CGFloat currentPageOffset = itemWidth * self.currentIndex;
        CGFloat deltaOffset = offsetX - currentPageOffset;
        if (fabs(deltaOffset) >= itemWidth/2 ) {
            [self.fullImageButton shouldAnimating:YES];
        } else {
            [self.fullImageButton shouldAnimating:NO];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat itemWidth = CGRectGetWidth(self.collectionView.frame);
    if (offsetX >= 0){
        NSInteger page = offsetX / itemWidth;
        [self didScrollToPage:page];
    }
    if (_sourceType == YYBigImageViewSourceTypeImageAsset) {
        [self.fullImageButton shouldAnimating:NO];
    }
}

- (void)didScrollToPage:(NSInteger)page
{
    self.currentIndex = page;
    [self updateNavigationBarAndToolBar];
}


#pragma mark - Control Hiding / Showing
// Fades all controls slide and fade
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated{
    
    _previousNavBarHidden = hidden;
    // Force visible
    if (nil == self.imageArray || self.imageArray.count == 0)
        hidden = NO;
    // Animations & positions
    CGFloat animatonOffset = 20;
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    // Status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // Hide status bar
        _statusBarShouldBeHidden = hidden;
        [UIView animateWithDuration:animationDuration animations:^(void) {
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {}];
    }
    
    CGRect frame = CGRectIntegral(CGRectMake(0, WIN_HEIGHT - BottomProductHeight, WIN_WIDTH, BottomProductHeight));
    
    // Pre-appear animation positions for iOS 7 sliding
    if ([self areControlsHidden] && !hidden && animated) {
        // Toolbar
        self.toolBar.frame = CGRectOffset(frame, 0, animatonOffset);
    }
    
    
    [UIView animateWithDuration:animationDuration animations:^(void) {
        CGFloat alpha = hidden ? 0 : 1;
        // Nav bar slides up on it's own on iOS 7
        [self.navigationController.navigationBar setAlpha:alpha];
        // Toolbar
        self.toolBar.frame = frame;
        if (hidden) {
            self.toolBar.frame = CGRectOffset(self.toolBar.frame, 0, animatonOffset);
        }
        self.toolBar.alpha = alpha;
    } completion:^(BOOL finished) {}];
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarShouldBeHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)areControlsHidden {
    return (self.toolBar.alpha == 0);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
