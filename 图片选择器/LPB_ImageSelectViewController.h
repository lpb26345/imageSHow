//
//  LPB_ImageSelectViewController.h
//  SMoothBus
//
//  Created by lpb on 2017/2/11.
//  Copyright © 2017年 chengxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface LPB_ImageSelectViewController : UIViewController
@property (strong, nonatomic) PHAssetCollection *dataCollection;
@property (assign, nonatomic) NSInteger MAXNumber;
@property (strong, nonatomic) NSString *titleName;
//是否支持多选，默认为YES
@property (nonatomic, assign) BOOL isMultipleChoice;
@end
