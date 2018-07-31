//
//  CCExceptionHandler.h
//  CCClassRoom
//
//  Created by cc on 17/5/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCExceptionHandler : NSObject
+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler *)getHandler;
+ (void)TakeException:(NSException *) exception;
@end
