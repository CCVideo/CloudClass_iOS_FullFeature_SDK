//
//  CCCollectionViewCellTile.h
//  CCClassRoom
//
//  Created by cc on 17/4/20.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCollectionViewCellSingle.h"
#import <CCClassRoom/CCClassRoom.h>

@interface CCCollectionViewCellTile : UICollectionViewCell
@property (weak, nonatomic) id<CCCollectionViewCellSingleDelegate> delegate;
- (void)loadwith:(CCStreamShowView *)info showAtTop:(BOOL)top;
@end
