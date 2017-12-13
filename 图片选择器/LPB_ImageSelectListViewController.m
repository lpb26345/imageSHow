//
//  LPB_ImageSelectListViewController.m
//  SMoothBus
//
//  Created by lpb on 2017/2/11.
//  Copyright © 2017年 chengxi. All rights reserved.
//

#import "LPB_ImageSelectListViewController.h"
#import "LPB_ImageSelectViewController.h"
#import "LPB_ImageSelectListCell.h"
//#import<AVFoundation/AVCaptureDevice.h>
#import <Photos/Photos.h>
//#import<AVFoundation/AVMediaFormat.h>
static NSString *ImageSelectListCell = @"LPB_ImageSelectListCell";
@interface LPB_ImageSelectListViewController ()<UITableViewDelegate,UITableViewDataSource> {
    PHFetchResult *_smartAlbums ;
    NSArray *_tableArray;
    
}
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (nonatomic, copy) LPBclickSureBlock sureBlock;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation LPB_ImageSelectListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeAuthorizationStatus];
    

    _tableView.rowHeight = 80;
    [self initNavItem];
       [_tableView registerNib:[UINib nibWithNibName:@"LPB_ImageSelectListCell" bundle:nil] forCellReuseIdentifier:ImageSelectListCell];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushSelectObject:) name:@"LPBDissmissPickerSelect" object:nil];
}

- (void)changeAuthorizationStatus {
    WEAKSELF
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
            _maskView.hidden = YES;
                if ( ! _tableArray.count) {
                    _tableArray = [weakSelf getPhotoAblumList];
                    [_tableView reloadData];
                }
            });
        }
        if (status == PHAuthorizationStatusDenied) {
            _maskView.hidden = NO;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"尚未开启相册权限" message:@"是否前往开启" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication]canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
            }];
            [alert addAction:alertAction1];
            [alert addAction:alertAction2];
            [weakSelf presentViewController:alert animated:YES completion:nil];
   
        }
    }];
    
    
}

- (void)initNavItem {
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame =  CGRectMake(0, 0, 40, 20);
    [btn2 setTitle:@"取消" forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn2 addTarget:self action:@selector(clickrightButton) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    self.navigationItem.title = @"相册列表";
}

- (void)clickrightButton {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// * @brief 获取用户所有相册列表
- (NSArray<LPB_ImageSelectModel *> *)getPhotoAblumList {
    NSMutableArray<LPB_ImageSelectModel *> *photoAblumList = [NSMutableArray array];
    _smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    [_smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary || collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumBursts ||
            collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ||
            collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumSelfPortraits ||
            collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
            collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumScreenshots) {
            
            NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
            if (assets.count > 0) {
                LPB_ImageSelectModel *ablum = [[LPB_ImageSelectModel alloc] init];
                
                ablum.title = collection.localizedTitle;
                
                ablum.count = assets.count;
                
                ablum.headImageAsset = assets.firstObject;
                
                ablum.assetCollection = collection;
                
                [photoAblumList addObject:ablum];
                
            }
            
        }
        
    }];
    
    //获取用户创建的相册
    
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
        
        if (assets.count > 0) {
            
            LPB_ImageSelectModel *ablum = [[LPB_ImageSelectModel alloc] init];
            
            ablum.title = collection.localizedTitle;
            
            ablum.count = assets.count;
            
            ablum.headImageAsset = assets.firstObject;
            
            ablum.assetCollection = collection;
            
            [photoAblumList addObject:ablum];
            
        }
        
    }];
    
    return photoAblumList;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LPB_ImageSelectListCell *cell = [tableView dequeueReusableCellWithIdentifier:ImageSelectListCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LPB_ImageSelectModel *model = _tableArray[indexPath.row];
    cell.titleLabel.text = model.title;
    cell.numLabel.text = [NSString stringWithFormat:@"%.ld",model.count];
    cell.imageHeader.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageHeader.layer.masksToBounds = YES;
    [self requestImageForAsset:model.headImageAsset size:CGSizeMake(cell.frame.size.width, cell.frame.size.width) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image) {
        cell.imageHeader.image = image;
    }];
    return cell;
}


- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}


#pragma mark - 获取相册内所有照片资源
//* @param ascending 是否按创建时间正序排列 YES,创建时间正（升）序排列; NO,创建时间倒（降）序排列
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending {
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    return assets;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LPB_ImageSelectModel *model = _tableArray[indexPath.row];
    LPB_ImageSelectViewController *VC = [[LPB_ImageSelectViewController alloc]init];
    VC.dataCollection = model.assetCollection;
    VC.titleName = model.title;
    VC.MAXNumber = 9;
    [self.navigationController pushViewController:VC
                                         animated:YES];
}

- (void)clickSureCompetion:(LPBclickSureBlock)completion {
    self.sureBlock = completion;
    
}

- (void)pushSelectObject:(NSNotification *)not {
    self.sureBlock(not.userInfo);
}


#pragma mark - 获取指定相册内的所有图片

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
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        
        completion(image);
        
    }];
    
}
@end
