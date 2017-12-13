//
//  PHAsset+LPB_IsSelect.h
//  SMoothBus
//
//  Created by lpb on 2017/2/10.
//  Copyright © 2017年 chengxi. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (LPB_IsSelect)
// 1表示被选中，2未被选中
@property (assign,nonatomic) NSInteger isSelected;
@end
