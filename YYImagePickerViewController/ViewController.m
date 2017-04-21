//
//  ViewController.m
//  YYImagePickerViewController
//
//  Created by YZ Y on 17/4/21.
//  Copyright © 2017年 YYZ. All rights reserved.
//

#define itemWidth (WIN_WIDTH - RELATIVE_WIDTH(12) * 2 - RELATIVE_WIDTH(10) * 2) / 3

#import "ViewController.h"
#import "YYImagePickerViewController.h"
#import "AppConstants.h"

static NSString *const cellID = @"imageCell";
@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIButton *button;
@property (nonatomic, strong) NSMutableArray *imagesArray;

@end

@implementation ViewController

- (NSMutableArray *)imagesArray {
    if (!_imagesArray) {
        _imagesArray = [NSMutableArray array];
    }
    return _imagesArray;
}

- (UIButton *)button {
    if (!_button) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"选择图片" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor orangeColor];
        button.frame = CGRectMake(50, WIN_HEIGHT / 2 - 25, WIN_WIDTH - 100, 50);
        [button addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        _button = button;
    }
    return _button;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = RELATIVE_WIDTH(10);
        flowLayout.minimumInteritemSpacing = RELATIVE_WIDTH(10);
        flowLayout.sectionInset = UIEdgeInsetsMake(RELATIVE_WIDTH(12), RELATIVE_WIDTH(12), RELATIVE_WIDTH(12), RELATIVE_WIDTH(12));
        
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, WIN_WIDTH, WIN_HEIGHT - BottomProductHeight - 50) collectionViewLayout:flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.backgroundColor= [UIColor clearColor];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self collectionView];
    [self button];
}

- (void)showImagePicker
{
    YYImagePickerViewController *imagePickerVC = [[YYImagePickerViewController alloc] init];
    imagePickerVC.finishSelectImageBlock = ^(NSArray *imageArray, NSArray *assetArray) {
        if (imageArray.count > 0) {
            [self.imagesArray addObjectsFromArray:imageArray];
            [self.collectionView reloadData];
        }
        
        if (self.imagesArray.count > 0) {
            self.button.frame = CGRectMake(50, WIN_HEIGHT - 60, WIN_WIDTH - 100, 50);
        }
    };
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:imagePickerVC];
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource/Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    UIImageView *view = [[UIImageView alloc] initWithImage:self.imagesArray[indexPath.item]];
    view.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
    [cell addSubview:view];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
