//
//  CCStreamCheck.h
//  CCClassRoom
//
//  Created by cc on 17/12/18.
//  Copyright © 2017年 cc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CCClassRoom/CCClassRoom.h>

#define CCNotiStreamCheckNilStream @"kNotiCCStreamCheckNilStream"

@interface CCStreamCheck : NSObject
+ (instancetype)shared;
- (void)addStream:(NSString *)stream role:(CCRole)role;
@end
