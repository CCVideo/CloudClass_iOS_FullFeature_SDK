//
//  CCUploadFile.h
//  CCClassRoom
//
//  Created by cc on 17/8/8.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CCNotiUploadFileProgress @"CCNotiUploadFileProgress"

typedef void(^CCUploadFileBlock)(BOOL result);

@interface CCUploadFile : NSObject
@property (assign, nonatomic) BOOL isLandSpace;
- (void)uploadImage:(UINavigationController *)nav roomID:(NSString *)roomID completion:(CCUploadFileBlock)completion;
@end
