//
//  LPB_ImageSelectViewController.m
//  SMoothBus
//
//  Created by lpb on 2017/2/11.
//  Copyright © 2017年 chengxi. All rights reserved.
//

#import "LPB_ImageSelectViewController.h"
#import "LPB_ImagePickerCollectionViewCell.h"
#import "PHAsset+LPB_IsSelect.h"
#define LPBScreenWidth     ([UIScreen mainScreen].bounds.size.width)
#define LPBScreenHeight    ([UIScreen mainScreen].bounds.size.height)
#define LPBScreenScale ([[UIScreen mainScreen] scale])
@interface LPB_ImageSelectViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    //数据源
    NSArray *_assetsArray;
    //已选中的图片数据源
    NSMutableArray *_seletedArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionBottomCst;
@property (weak, nonatomic) IBOutlet UIView *sureView;

@end

@implementation LPB_ImageSelectViewController

- (IBAction)clickGoBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)clickSure:(UIButton *)sender {
    if (_seletedArray.count > 0) {
        
        NSDictionary *dic = @{@"array":_seletedArray};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LPBDissmissPickerSelect" object:nil userInfo:dic];
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _seletedArray = [[NSMutableArray alloc]init];
    [self initSelfView];
    [_collectionView registerNib:[UINib nibWithNibName:@"LPB_ImagePickerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"11"];
    _assetsArray = [self getAssetsInAssetCollection:_dataCollection ascending:NO];
    [self initNavItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_assetsArray.count == 0) {
        _assetsArray = [self getAssetsInAssetCollection:_dataCollection ascending:NO];
    }
}

- (void)initSelfView {
    if (_isMultipleChoice) {
        _collectionBottomCst.constant = 0;
        _sureView.hidden = YES;
        if (_MAXNumber <= 0) {
            _MAXNumber = 9;
        }
    } else {
        _collectionBottomCst.constant = 49;
        _sureView.hidden = NO;
    }
}

- (void)initNavItem {
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame =  CGRectMake(0, 0, 40, 20);
    [btn2 setTitle:@"取消" forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn2 addTarget:self action:@selector(clickrightButton) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    self.navigationItem.title = _titleName;
}
- (void)clickBackButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickrightButton {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section  {
    return _assetsArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LPB_ImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"11" forIndexPath:indexPath];
    // 在资源的集合中获取第一个集合，并获取其中的图片
    cell.headerImage.contentMode = UIViewContentModeScaleAspectFill;
    PHAsset *asset = _assetsArray[indexPath.row];
    [self getImageWithAsset:asset completion:^(UIImage *image) {
        cell.headerImage.image = image;
    }];
    
    if (asset.isSelected == 1) {
        cell.selectedImage.hidden = NO;
    } else {
        cell.selectedImage.hidden = YES;
    }
    return cell;
}

//从这个回调中获取所有的图片

- (void)getImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion {
    CGSize size = [self getSizeWithAsset:asset];
    [self requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
}
//pragma mark - 获取图片及图片尺寸的相关方法

- (CGSize)getSizeWithAsset:(PHAsset *)asset {
    CGFloat width  = (CGFloat)asset.pixelWidth;
    CGFloat height = (CGFloat)asset.pixelHeight;
    CGFloat scale = width/height;
    return CGSizeMake(_collectionView.frame.size.height*scale, _collectionView.frame.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((LPBScreenWidth - 25)/4, (LPBScreenWidth - 25)/4);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 5, 0, 5);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _assetsArray[indexPath.row];
    if (asset.isSelected == 1) {
        
        for (int i = 0; i < _seletedArray.count; i ++) {
            PHAsset *tempAsset = _seletedArray[i];
            //比较两个图片的创建时间，如果一致，则是同一张图片
            NSComparisonResult result = [tempAsset.creationDate compare:asset.creationDate];
            if (result == NSOrderedSame) {
                [_seletedArray removeObject:tempAsset];
                asset.isSelected = 2;
            }
        }
    } else {
        if (_seletedArray.count == _MAXNumber) {
            [self showSelectedIsFull];
            return;
        }
        asset.isSelected = 1;
        [_seletedArray addObject:asset];
    }
    NSArray *array = [[NSArray alloc]initWithObjects:indexPath, nil];
    [_collectionView reloadItemsAtIndexPaths:array];
}


- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

#pragma mark - 获取asset对应的图片
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     
     这个属性只有在 synchronous 为 true 时有效。
     
     */
    
    option.resizeMode = resizeMode;//控制照片尺寸
    
    //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    
    //option.synchronous = YES;
    
    option.networkAccessAllowed = YES;
    
    //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        
        completion(image);
        
    }];
    
}

- (void)showSelectedIsFull {
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"最多选取%ld张图片",self.MAXNumber]];
}

@end
