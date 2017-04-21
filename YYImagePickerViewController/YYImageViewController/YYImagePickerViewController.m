//
//  YYImagePickerViewController.m
//  DDFood
//
//  Created by YZ Y on 16/10/8.
//  Copyright © 2016年 YZ Y. All rights reserved.
//

#define itemWidth (WIN_WIDTH - RELATIVE_WIDTH(12) * 2 - RELATIVE_WIDTH(10) * 2) / 3
#define maxImageCount 5

#import "YYImagePickerViewController.h"
#import "YYImagePickerCell.h"
#import "NSURL+YYImagePickerUrlEqual.h"
#import "YYBigImageViewController.h"
#import "AppConstants.h"
#import "MBProgressHUD.h"
#import "Masonry.h"

static NSString *const cellID = @"YYImagePickerCellID";
@interface YYImagePickerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, YYImagePickerCellDelegate, YYBigImageViewControllerDelegate>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIButton *sendButton;
@property (nonatomic, strong) NSMutableArray *imageArray;           //图片数组
@property (nonatomic, strong) NSMutableArray *imageAssetArray;      //传递用asset数组
@property (nonatomic, strong) NSArray *assetsArray;                 //图库asset对象数组
@property (nonatomic, strong) NSMutableArray *selectedAssetsArray;  //选择的包含url，image，asset字典的数组
@property (nonatomic, strong) PHImageManager *photoManager;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation YYImagePickerViewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = RELATIVE_WIDTH(10);
        flowLayout.minimumInteritemSpacing = RELATIVE_WIDTH(10);
        flowLayout.sectionInset = UIEdgeInsetsMake(RELATIVE_WIDTH(12), RELATIVE_WIDTH(12), RELATIVE_WIDTH(12), RELATIVE_WIDTH(12));
        
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        NSArray *viewcontrollers = self.navigationController.viewControllers;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, viewcontrollers.count > 1 ? 0 : 64, WIN_WIDTH, WIN_HEIGHT - BottomProductHeight - mNavBarWithStateHeight) collectionViewLayout:flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.backgroundColor= [UIColor clearColor];
        [collectionView registerClass:[YYImagePickerCell class] forCellWithReuseIdentifier:cellID];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (NSMutableArray *)selectedAssetsArray {
    if (!_selectedAssetsArray) {
        _selectedAssetsArray = [NSMutableArray array];
    }
    return _selectedAssetsArray;
}

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (NSMutableArray *)imageAssetArray {
    if (!_imageAssetArray) {
        _imageAssetArray = [NSMutableArray array];
    }
    return _imageAssetArray;
}


- (PHImageManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [PHImageManager defaultManager];
    }
    return _photoManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backBtn.bounds = (CGRect){CGPointZero,[backBtn imageForState:UIControlStateNormal].size};
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [self loadPhotosWithPhotoKit];
    });
    
    self.title = @"相机胶卷";
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange:) userInfo:nil repeats:YES];
    }
    [self createUI];
}

- (void)observeAuthrizationStatusChange:(NSTimer *)timer
{
    /** 当用户已授权 */
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [timer invalidate];
        self.timer = nil;
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [self loadPhotosWithPhotoKit];
        });
    }
}

- (void)createUI
{
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    WS(ws);
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.bottom.equalTo(ws.view);
        make.height.mas_equalTo(BottomProductHeight);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = CommonCornerRadius;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:RELATIVE_WIDTH(36)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (self.imagesCount) {
        [button setBackgroundColor:YYGlobalColor];
        [button setTitle:[NSString stringWithFormat:@"完成(%@/%@)", @(self.imagesCount), @(maxImageCount)] forState:UIControlStateNormal];
    } else {
        [button setBackgroundColor:[UIColor grayColor]];
        [button setTitle:@"请选择图片" forState:UIControlStateNormal];
    }
    
    [button addTarget:self action:@selector(sendImage) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button];
    
    _sendButton = button;
    _sendButton.enabled = self.imagesCount;
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bottomView.mas_right).offset(-RELATIVE_WIDTH(10));
        make.width.mas_equalTo(RELATIVE_WIDTH(220));
        make.top.equalTo(bottomView.mas_top).offset(RELATIVE_WIDTH(16));
        make.bottom.equalTo(bottomView.mas_bottom).offset(-RELATIVE_WIDTH(16));
    }];
    
}

- (void)loadPhotosWithPhotoKit
{
    // 获取所有资源的集合，并按资源的创建时间排序
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    // 这时 assetsFetchResults 中包含的，应该就是各个资源（PHAsset）
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < assetsFetchResults.count; i++) {
        // 获取一个资源（PHAsset）
        PHAsset *asset = assetsFetchResults[i];
        [array insertObject:asset atIndex:0];
    }
    self.assetsArray = array;
    [hud hide:YES afterDelay:0.2];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource/Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetsArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YYImagePickerCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.item == 0) {
        cell.isCamera = YES;
    } else {
        cell.backgroundColor = [UIColor clearColor];
        PHAsset *asset = self.assetsArray[indexPath.item - 1];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        [self.photoManager requestImageForAsset:asset targetSize:ccs(itemWidth, itemWidth) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [cell setImage:result indexPath:indexPath delegate:self];
        }];
        [self.photoManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            cell.url = info[@"PHImageFileURLKey"];
            cell.isSelected = [self photoIsSelected:cell.url];
        }];

    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        self.imagesCount + self.selectedAssetsArray.count >= maxImageCount ? [self showMessage] : [self openCamera];
    } else {
        YYBigImageViewController *bigImageVC = [[YYBigImageViewController alloc] init];
        bigImageVC.imageArray = self.assetsArray;
        bigImageVC.sourceType = YYBigImageViewSourceTypeImageAsset;
        bigImageVC.showType = YYBigImageViewTypeNomal;
        bigImageVC.currentIndex = indexPath.item - 1;
        bigImageVC.delegate = self;
        [self.navigationController pushViewController:bigImageVC animated:YES];
    }
}

- (void)showMessage
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"最多选择%@张图片", @(maxImageCount)];
    [hud hide:YES afterDelay:1.5];
}

#pragma mark - YYImagePickerCellDelegate
- (void)didSelectImage:(NSIndexPath *)indexPath
{
    YYImagePickerCell *cell = (YYImagePickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (self.imagesCount + self.selectedAssetsArray.count >= maxImageCount) {
        [self showMessage];
        cell.isSelected = NO;
        return;
    }
    PHAsset *asset = self.assetsArray[indexPath.item - 1];
    [self.photoManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        UIImage *image = result;
        image = [self scaleImage:image scaleFactor:0.40];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.001);
        UIImage *newImage = [[UIImage alloc] initWithData:imageData];
        NSDictionary *dic = @{@"img": newImage, @"url": info[@"PHImageFileURLKey"], @"asset": asset};
        [self.selectedAssetsArray addObject:dic];
        cell.isSelected = [self photoIsSelected:cell.url];
        [self updateSendButton];
    }];
}

- (void)didDeselectImage:(NSIndexPath *)indexPath
{
    YYImagePickerCell *cell = (YYImagePickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    [self.selectedAssetsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
        if ([dic[@"url"] isEqualToOther:cell.url]) {
            *stop = YES;
        }
        if (*stop == YES) {
            [self.selectedAssetsArray removeObjectAtIndex:idx];
            cell.isSelected = [self photoIsSelected:cell.url];
        }
    }];
    [self updateSendButton];
}

#pragma mark - 判断是否选中
- (BOOL)photoIsSelected:(NSURL *)url
{
    for (NSDictionary *dic in self.selectedAssetsArray) {
        if ([url isEqualToOther:dic[@"url"]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 更新按钮
- (void)updateSendButton
{
    if (self.selectedAssetsArray.count == 0) {
        self.sendButton.enabled = NO;
        [self.sendButton setBackgroundColor:[UIColor grayColor]];
        [self.sendButton setTitle:@"请选择图片" forState:UIControlStateNormal];
    } else {
        NSInteger imageCounts = self.selectedAssetsArray.count + self.imagesCount;
        self.sendButton.enabled = YES;
        [self.sendButton setTitle:[NSString stringWithFormat:@"完成(%@/%@)", @(imageCounts), @(maxImageCount)] forState:UIControlStateNormal];
        self.sendButton.backgroundColor = YYGlobalColor;
    }
}

//开相机
- (void)openCamera
{
    //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    picker.sourceType = sourceType;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
    }
    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //相机原图
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImageOrientation imageOrientation = image.imageOrientation;
    if(imageOrientation != UIImageOrientationUp)
    {
        // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 调整图片角度完毕
    }
    
    //保存图片到系统相册
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 成功保存图片到相册中, 必须调用此方法, 否则会报参数越界错误
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    PHAsset *asset = [self latestAsset];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.assetsArray];
    //更新数据源
    [array insertObject:asset atIndex:0];
    self.assetsArray = array;
    [self.photoManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        UIImage *image = result;
        image = [self scaleImage:image scaleFactor:0.40];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.001);
        UIImage *newImage = [[UIImage alloc] initWithData:imageData];
        NSDictionary *dic = @{@"img": newImage, @"url": info[@"PHImageFileURLKey"], @"asset": asset};
        [self.selectedAssetsArray addObject:dic];
        //插入最新行
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]]];
        NSInteger imageCounts = self.selectedAssetsArray.count + self.imagesCount;
        self.sendButton.enabled = YES;
        [self.sendButton setTitle:[NSString stringWithFormat:@"完成(%@/%@)",@(imageCounts), @(maxImageCount)] forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.sendButton.backgroundColor = YYGlobalColor;
    }];
}

/**获取最新图片*/
- (PHAsset *)latestAsset {
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    return [assetsFetchResults firstObject];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


/**
 *  图片压缩
 *
 *  @param image      要压缩的图片
 *  @param scaleFloat 压缩尺寸
 *
 *  @return 返回压缩好的图片
 */
- (UIImage *)scaleImage:(UIImage *)image scaleFactor:(float)scaleFloat
{
    float scaleBy = scaleFloat;
    CGSize size = CGSizeMake(image.size.width * scaleBy, image.size.height * scaleBy);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, scaleBy, scaleBy);
    CGContextConcatCTM(context, transform);
    
    [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}
#pragma mark - 返回按钮
- (void)back
{
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self) {
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 发送图片
- (void)sendImage
{
    for (NSDictionary *dic in self.selectedAssetsArray) {
        if (dic[@"img"]) {
            [self.imageArray addObject:dic[@"img"]];
        }
        if(dic[@"asset"]) {
            [self.imageAssetArray addObject:dic[@"asset"]];
        }
    }
    if (_finishSelectImageBlock != nil) {
        _finishSelectImageBlock(self.imageArray, self.imageAssetArray);
    }
    [self back];
}

#pragma mark - YYBigImageViewControllerDelegate
- (BOOL)currentPhotoAssetIsSelected:(PHAsset *)asset withIndex:(NSInteger)index
{
    YYImagePickerCell *cell = (YYImagePickerCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index + 1 inSection:0]];
    return [self photoIsSelected:cell.url];
}

- (BOOL)selectedAsset:(PHAsset *)asset withIndex:(NSInteger)index
{
    if (self.selectedAssetsArray.count + self.imagesCount >= maxImageCount) {
        return NO;
    }
    YYImagePickerCell *cell = (YYImagePickerCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index + 1 inSection:0]];
    NSDictionary *dic = @{@"url": cell.url, @"asset": asset, @"img": cell.image};
    [self.selectedAssetsArray addObject:dic];
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:index + 1 inSection:0]]];
    [self updateSendButton];
    return [self photoIsSelected:cell.url];
}

- (void)deselectedAsset:(PHAsset *)asset withIndex:(NSInteger)index
{
    YYImagePickerCell *cell = (YYImagePickerCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index + 1 inSection:0]];
    [self.selectedAssetsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        if ([dic[@"url"] isEqualToOther:cell.url]) {
            *stop = YES;
        }
        if (*stop == YES) {
            [self.selectedAssetsArray removeObjectAtIndex:idx];
        }
    }];
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:index + 1 inSection:0]]];
    [self updateSendButton];
}

- (NSUInteger)selectedPhotosNumberInPhotoBrowser
{
    return self.selectedAssetsArray.count + self.imagesCount;
}

#pragma mark - buttonAction

- (void)sendImagesFromPhotoBrowser
{
    [self sendImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
