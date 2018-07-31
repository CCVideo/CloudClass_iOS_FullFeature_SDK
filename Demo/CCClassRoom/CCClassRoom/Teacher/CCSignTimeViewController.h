//
//  CCSignTimeViewController.h
//  CCClassRoom
//
//  Created by cc on 17/4/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCBaseTableViewController.h"

#define CCNotiSignTimeSelected @"CCNotiSignTimeSelected"

typedef NS_ENUM(NSInteger, CCSignTime) {
    CCSignTimeOne = 10,
    CCSignTimeTwo = 20,
    CCSignTimeThree = 30,
    CCSignTimeFour = 1*60,
    CCSignTimeFive = 2*60,
    CCSignTimeSix = 3*60,
    CCSignTimeSeven = 5*60,
};

@interface CCSignTimeViewController : CCBaseTableViewController

@end
