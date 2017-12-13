//
//  PHAsset+LPB_IsSelect.m
//  SMoothBus
//
//  Created by lpb on 2017/2/10.
//  Copyright © 2017年 chengxi. All rights reserved.
//

#import "PHAsset+LPB_IsSelect.h"
#import <objc/runtime.h>
static NSInteger _isSelected;
@implementation PHAsset (LPB_IsSelect)

- (void)setIsSelected:(NSInteger )isSelected {
    objc_setAssociatedObject(self, &_isSelected, [NSNumber numberWithInteger:isSelected], OBJC_ASSOCIATION_ASSIGN);
}
- (NSInteger)isSelected {
    return [objc_getAssociatedObject(self, &_isSelected) integerValue];
}
@end
