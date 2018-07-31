//
//  CCWeakProxy.m
//  CCClassRoom
//
//  Created by cc on 17/8/14.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCWeakProxy.h"
@implementation CCWeakProxy
- (instancetype)initWithTarget:(id)target
{
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target
{
    return [[self alloc] initWithTarget:target];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL sel = [invocation selector];
    if([self.target respondsToSelector:sel])
    {
        [invocation invokeWithTarget:self.target];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return[self.target methodSignatureForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return[self.target respondsToSelector:aSelector];
}
@end
