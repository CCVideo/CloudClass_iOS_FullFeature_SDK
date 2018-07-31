//
//  CCDocTableViewCell.h
//  CCClassRoom
//
//  Created by cc on 17/4/24.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDoc.h"

@interface CCDocTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

- (void)reloadWithDoc:(CCDoc *)doc;
- (void)reloadWithInfo:(NSDictionary *)info;
@end
