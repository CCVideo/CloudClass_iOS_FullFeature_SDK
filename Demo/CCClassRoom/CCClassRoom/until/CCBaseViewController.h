//
//  CCBaseViewController.h
//  CCClassRoom
//
//  Created by cc on 17/3/13.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTool.h"

//角色定义
#define KKEY_CCRole_Teacher         @"presenter"
#define KKEY_CCRole_Student         @"talker"
#define KKEY_CCRole_Watcher         @"audience"
#define KKEY_CCRole_Inspector       @"inspector"


@interface CCBaseViewController : UIViewController
- (void)onSelectVC;
- (UIImage*)createImageWithColor: (UIColor*) color;
@end
