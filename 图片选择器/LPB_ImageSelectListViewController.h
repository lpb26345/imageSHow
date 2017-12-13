//
//  LPB_ImageSelectListViewController.h
//  SMoothBus
//
//  Created by lpb on 2017/2/11.
//  Copyright © 2017年 chengxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "LPB_ImageSelectModel.h"
typedef void(^LPBclickSureBlock) (NSDictionary *dic);


@interface LPB_ImageSelectListViewController : UIViewController
//是否支持多选，默认为YES
@property (nonatomic, assign) BOOL isMultipleChoice;
//多选时，支持的最大选择个数。
@property (nonatomic, assign) NSInteger MAXNumber;

- (void)clickSureCompetion:(LPBclickSureBlock)completion;
@end
