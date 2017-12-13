//
//  LPB_ImageSelectModel.h
//  SMoothBus
//
//  Created by lpb on 2017/2/11.
//  Copyright © 2017年 chengxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface LPB_ImageSelectModel : NSObject
@property (nonatomic, copy) NSString *title; //相册名字

@property (nonatomic, assign) NSInteger count; //该相册内相片数量

@property (nonatomic, strong) PHAsset *headImageAsset; //相册第一张图片缩略图

@property (nonatomic, strong) PHAssetCollection *assetCollection; //相册集，通过该属性获取该相册集下所有照片
@end
