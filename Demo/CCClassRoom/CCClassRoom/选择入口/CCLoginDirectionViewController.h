//
//  CCLoginDirectionViewController.h
//  CCClassRoom
//
//  Created by cc on 17/7/12.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCBaseViewController.h"
#import <CCClassRoom/CCClassRoom.h>

@interface CCLoginDirectionViewController : CCBaseViewController
@property (assign, nonatomic) CCRole role;//角色
@property (strong, nonatomic) NSString *roomID;
@property (strong, nonatomic) NSString *userID;
@property (assign, nonatomic) BOOL needPassword;
@end
