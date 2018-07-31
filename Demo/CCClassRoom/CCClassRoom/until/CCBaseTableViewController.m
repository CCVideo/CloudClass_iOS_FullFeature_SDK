//
//  CCBaseTableViewController.m
//  CCClassRoom
//
//  Created by cc on 17/3/13.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCBaseTableViewController.h"

@interface CCBaseTableViewController ()

@end

@implementation CCBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
    UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:MainColor] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSizeClass_18],NSFontAttributeName,nil]];
    
    self.view.backgroundColor = CCRGBColor(250, 250, 250);
    self.tableView.separatorColor = CCRGBColor(229, 229, 229);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = CCRGBColor(250, 250, 250);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)onSelectVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage*)createImageWithColor: (UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
