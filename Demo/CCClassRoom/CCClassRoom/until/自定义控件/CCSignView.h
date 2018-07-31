//
//  CCSignView.h
//  CCClassRoom
//
//  Created by cc on 17/4/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CCSignViewClickBlock)(BOOL result);

@interface CCSignView : UIView
- (id)initWithTime:(NSTimeInterval)time completion:(CCSignViewClickBlock)completion;
- (void)show;
@end
