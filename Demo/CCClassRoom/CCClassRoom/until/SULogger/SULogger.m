//
//  SULogboard.m
//  SUMusic
//
//  Created by 万众科技 on 16/3/4.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "SULogger.h"
#import "SULogboard.h"

#define LogFileName @"SULogger.log"

@interface SULogger ()

@property (nonatomic, strong) SULogboard * logboard;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSString *logPath;
@end

@implementation SULogger

+ (instancetype)logger {
    static SULogger * logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[SULogger alloc]init];
    });
    return logger;
}

- (void)startSaveLog {

    //file path
    NSString * documentDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * logPath = [documentDirPath stringByAppendingPathComponent:LogFileName];
    //delete exisist file
    [[NSFileManager defaultManager]removeItemAtPath:logPath error:nil];
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"SIMULATOR DEVICE");
#else
    //export log to file
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout); //c printf
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr); //oc  NSLog
#endif
    
}

- (void)loadLog {
    //file path
    NSString * documentDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * logPath = [documentDirPath stringByAppendingPathComponent:LogFileName];
    //load data
    NSData * logData = [NSData dataWithContentsOfFile:logPath];
    NSString * logText = [[NSString alloc]initWithData:logData encoding:NSUTF8StringEncoding];
    //update text
    [self.logboard updateLog:logText];
}


- (void)show {
    //create logboard
    self.logboard = [[SULogboard alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.logboard.alpha = 0.f;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes)];
    tap.numberOfTouchesRequired = 3;
    [self.logboard addGestureRecognizer:tap];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.logboard];
    //animation show
    [UIView animateWithDuration:0.2 animations:^{
        self.logboard.alpha = 1.0;
    }];
    //add timer to update log
    [self loadLog];
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:weakProxy selector:@selector(loadLog) userInfo:nil repeats:YES];
}

- (void)tapGes
{
    [SULogger visibleChange];
}

- (void)hide {
    //animation hide
    [UIView animateWithDuration:0.2 animations:^{
        self.logboard.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.logboard removeFromSuperview];
        self.logboard = nil;
    }];
    //release timer
    [self.timer invalidate];
    self.timer = nil;
}

+ (void)start {
    [[SULogger logger] startSaveLog];
}

+ (void)visibleChange {
    SULogger * logger = [SULogger logger];
    logger.timer ? [logger hide] : [logger show];
}

+ (NSString *)getMessage
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[SULogger logger].logPath];
    NSData *data = [handle readDataToEndOfFile];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
