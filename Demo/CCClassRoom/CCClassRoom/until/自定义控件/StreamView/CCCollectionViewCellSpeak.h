//
//  CCCollectionViewCellSpeak.h
//  CCClassRoom
//
//  Created by cc on 17/5/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCClassRoom/CCClassRoom.h>
#import "CCLoadingView.h"

@interface CCCollectionViewCellSpeak : UICollectionViewCell
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) CCStreamShowView *info;
@property (strong, nonatomic) CCLoadingView *loadingView;

- (void)loadwith:(CCStreamShowView *)info showNameAtTop:(BOOL)top;
@end
