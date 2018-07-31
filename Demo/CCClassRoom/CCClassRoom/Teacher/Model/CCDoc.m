//
//  CCDoc.m
//  CCClassRoom
//
//  Created by cc on 17/4/24.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDoc.h"

@implementation CCDoc
- (id)initWithDic:(NSDictionary *)dic picDomain:(NSString *)domain
{
    if (self = [super init])
    {
        self.docID = dic[@"id"];
        self.docName = [dic objectForKey:@"name"];
        self.md5 = [dic objectForKey:@"md5"];
        self.pageSize = [[dic objectForKey:@"pageSize"] integerValue];
        self.roomID = [dic objectForKey:@"roomId"];
        self.useSDK = [[dic objectForKey:@"useSDK"] boolValue];
        self.size = [[dic objectForKey:@"size"] floatValue];
        
        NSString *url = [[domain componentsSeparatedByString:@"://"] lastObject];
        self.picDomain = [NSString stringWithFormat:@"https://%@", url];
    }
    return self;
}

- (NSString *)getPicUrl:(NSInteger)picNum
{
    if (self.picDomain.length == 0 || self.roomID.length == 0 || self.docID.length == 0)
    {
        return nil;
    }
    if (picNum <0 || picNum >= self.pageSize)
    {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/image/%@/%@/%@.jpg", self.picDomain, self.roomID, self.docID, @(picNum)];
}
@end

