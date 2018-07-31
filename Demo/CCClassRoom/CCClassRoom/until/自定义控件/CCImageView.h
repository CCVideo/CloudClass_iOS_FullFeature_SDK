//
//  CCImageView.h
//  CCClassRoom
//
//  Created by cc on 17/6/3.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCImageView : UIView
- (id)initWithImageUrl:(NSString *)url;
- (void)show;
- (void)dismiss;
@end
