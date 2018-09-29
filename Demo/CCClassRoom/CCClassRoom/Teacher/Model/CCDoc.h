//
//  CCDoc.h
//  CCClassRoom
//
//  Created by cc on 17/4/24.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCDoc : NSObject
@property (strong, nonatomic) NSString *docID;
@property (strong, nonatomic) NSString *docName;
@property (strong, nonatomic) NSString *md5;
@property (assign, nonatomic) NSInteger pageSize;
@property (strong, nonatomic) NSString *roomID;
@property (assign, nonatomic) BOOL useSDK;
@property (assign, nonatomic) float size;
@property (strong, nonatomic) NSString *picDomain;
@property (assign, nonatomic) BOOL isReleatedDoc;
@property (assign, nonatomic) long mode;


- (id)initWithDic:(NSDictionary *)dic picDomain:(NSString *)domain;
- (NSString *)getPicUrl:(NSInteger)picNum;
@end
