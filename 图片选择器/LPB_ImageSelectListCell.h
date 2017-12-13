//
//  LPB_ImageSelectListCell.h
//  DeliciousLive
//
//  Created by lpb on 2017/8/6.
//  Copyright © 2017年 lpb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPB_ImageSelectListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageHeader;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@end
