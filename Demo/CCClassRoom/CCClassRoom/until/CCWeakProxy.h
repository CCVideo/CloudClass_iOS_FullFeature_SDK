//
//  CCWeakProxy.h
//  CCClassRoom
//
//  Created by cc on 17/8/14.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCWeakProxy : NSProxy
@property(weak,nonatomic,readonly)id target;
+ (instancetype)proxyWithTarget:(id)target;
- (instancetype)initWithTarget:(id)target;
@end
