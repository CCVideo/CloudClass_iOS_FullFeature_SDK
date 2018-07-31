//
//  ScanOverViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OkBtnClickBlock)();

@interface CCScanOverViewController : UIViewController

-(instancetype)initWithBlock:(OkBtnClickBlock)block;

@end
