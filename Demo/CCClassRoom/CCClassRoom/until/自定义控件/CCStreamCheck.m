//
//  CCStreamCheck.m
//  CCClassRoom
//
//  Created by cc on 17/12/18.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStreamCheck.h"

@interface CCStreamCheck()
/** 定时器(这里不用带*，因为dispatch_source_t就是个类，内部已经包含了*) */
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation CCStreamCheck
+ (instancetype)shared
{
    static CCStreamCheck *s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[self alloc] init];
    });
    return s_instance;
}

- (void)addStream:(NSString *)stream role:(CCRole)role
{
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
    NSLog(@"%s__%d__%@", __func__, __LINE__, stream);
    dispatch_after(time, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"%s__%d__%@", __func__, __LINE__, stream);
        [[CCStreamer sharedStreamer] getConnectionStats:stream completion:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                CCConnectionStatus *status = info;
                NSLog(@"Date:%@", status.timeStamp);
                BOOL nilStream = NO;
                for (CCAudioReceiveStatus *rev in status.mediaChannelStats)
                {
                    if ([rev isKindOfClass:[CCAudioReceiveStatus class]])
                    {
                        if (rev.bytesReceived == 0 || rev.codecName.length == 0)
                        {
                            nilStream = YES;
                            break;
                        }
                        NSLog(@"AAAAAAAAAAAAA_____%s________%lu__%@__", __func__, (unsigned long)rev.bytesReceived,rev.codecName);
                    }
                    else
                    {
                        CCVideoReceiveStatus *videoRev = (CCVideoReceiveStatus *)rev;
                        if (videoRev.bytesReceived == 0 || videoRev.codecName.length == 0 || videoRev.frameResolution.width == 0 || videoRev.frameResolution.height == 0 )
                        {
                            nilStream = YES;
                            break;
                        }
                        NSLog(@"BBBBBBBBB_______%s________%lu__%@__", __func__, (unsigned long)rev.bytesReceived,rev.codecName);
                    }
                }
                if (nilStream)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiStreamCheckNilStream object:nil userInfo:@{@"stream":stream, @"role":@(role)}];
                }
            }
        }];
        
    });
}



@end
