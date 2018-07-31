//
//  CCActionCollectionViewCell.h
//  CCClassRoom
//
//  Created by cc on 17/10/23.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCActionCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *label;
- (void)loadWith:(NSString *)imageName text:(NSString *)text;
@end
