//
//  CCDocManager.m
//  CCStreamer
//
//  Created by cc on 17/7/11.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocManager.h"
#import <CCClassRoom/CCClassRoom.h>
#import "CCDrawMenuView.h"

@interface CCDocManager()
@property (strong, nonatomic) NSMutableDictionary *topDrawID;//自己最新的一条画笔ID
@property (assign, nonatomic) BOOL useSDK;

@property (copy, nonatomic) NSString                *oldPpturl;
@property (copy, nonatomic) NSString                *oldDocName;
@property (copy, nonatomic) NSString                *oldPageNum;
@property (copy, nonatomic) NSString                *oldDocId;
@property (assign, nonatomic) BOOL oldUseSDK;
@property (assign, nonatomic) BOOL historyDataReady;//历史记录是否解析完

@property (copy, nonatomic) NSString                *pptPageNum;

@end

@implementation CCDocManager
+ (instancetype)sharedManager
{
    static CCDocManager *s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[self alloc] init];
        s_instance.docId = @"WhiteBoard";
        s_instance.pageNum = @"-1";
        s_instance.docName = @"WhiteBoard";
    });
    return s_instance;
}

-(NSMutableDictionary *)allDataDic {
    if(_allDataDic == nil) {
        _allDataDic = [[NSMutableDictionary alloc] init];
    }
    return _allDataDic;
}

- (void)setDocParentView:(UIView *)view
{
    self.docParent = view;
    self.docFrame = view.frame;
    self.historyDataReady = NO;
    __weak typeof(self) weakSelf = self;
    CCRole role = [[CCStreamer sharedStreamer] getRoomInfo].user_role;
    if (role == CCRole_Teacher)
    {
        
    }
    [[CCStreamer sharedStreamer] getDocHistory:^(BOOL result, NSError *error, id info) {
        NSDictionary *metaDic = info[@"datas"][@"meta"];
        if (metaDic && weakSelf.docParent) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf onHistoryData:metaDic completion:^(BOOL result, NSError *error, id info) {
                    weakSelf.historyDataReady = YES;
                    NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
                    CCUser *user = [[CCStreamer sharedStreamer] getUSerInfoWithUserID:userID];
                    if (user.user_AssistantState || role == CCRole_Teacher)
                    {
                        //文档切换了，假如学生已经设为讲师，这个时候要更新文档
                        NSString *page = [[weakSelf.ppturl componentsSeparatedByString:@"/"] lastObject];
                        page = [[page componentsSeparatedByString:@"."] firstObject];
                        if (weakSelf.ppturl.length >0 && page.length > 0)
                        {
                            NSString *ppturl = self.ppturl;
                            NSArray *strs = [ppturl componentsSeparatedByString:@"/"];
                            NSString *roomID = @"";
                            if (strs.count > 2)
                            {
                                roomID = [strs objectAtIndex:strs.count-3];
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiReceiveDocChange object:nil userInfo:@{@"docID":weakSelf.docId, @"pageNum":page, @"step":@(self.animationStep), @"roomid":roomID}];
                        }
                    }
                }];
            });
        }
    }];
}

- (void)changeDocParentViewFrame:(CGRect)frame
{
    self.docFrame = frame;
    [self.draw setDrawFrame:frame];
}

- (void)clearDocParentView
{
    self.docParent = nil;
    self.docFrame = CGRectZero;
    self.draw = nil;
    CCLog(@"%s", __func__);
    [self showOrHideDrawView:YES];
}

- (void)onDraw:(id)drawData
{
    if (drawData == nil || self.docParent == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *drawDic = (NSDictionary *)drawData[@"value"][@"data"];
        NSString *docid = drawDic[@"docid"];
        NSMutableDictionary *dic = [self.allDataDic objectForKey:docid];
        if (dic == nil) {
            dic = [[NSMutableDictionary alloc] init];
            [weakSelf.allDataDic setObject:dic forKey:docid];
        }
        NSString *pageNum = [drawDic[@"page"] stringValue];
        NSMutableArray *subArr = [dic objectForKey:pageNum];
        if (subArr == nil) {
            subArr = [[NSMutableArray alloc] init];
            [dic setObject:subArr forKey:pageNum];
        }
        NSString *valueType = [drawDic objectForKey:@"valueType"];
        if ([valueType isEqualToString:@"video_draw"])
        {
            NSInteger type = [drawDic[@"drawType"] intValue];
            if (type == 3)
            {//清屏
                [subArr removeAllObjects];
            }
            else if (type == 1)
            {
                [subArr addObject:drawDic];
            }
            else if (type == 2)
            {
                //撤销
                NSString *delID = drawDic[@"drawid"];
                for (NSDictionary *info in subArr)
                {
                    if ([info[@"drawid"] isEqualToString:delID])
                    {
                        [subArr removeObject:info];
                        break;
                    }
                }
            }
        }
        else
        {
            NSInteger type = [drawDic[@"type"] intValue];
            if (type == 0) {//清屏
                [subArr removeAllObjects];
            }else if (type == 1) {//清除上一步
                if (subArr.count > 0) {
                    [subArr removeLastObject];
                }
            }else if (type == 6) {//清理整个文档数据
                [subArr removeAllObjects];
                [dic removeAllObjects];
                [weakSelf.allDataDic removeObjectForKey:docid];
            }else if (type == 7) {//清理整个文档数据
                [subArr removeAllObjects];
                [dic removeAllObjects];
                [weakSelf.allDataDic removeAllObjects];
            }else if (type == 9)
            {
                //撤销
                NSString *delID = drawDic[@"drawid"];
                for (NSDictionary *info in subArr)
                {
                    if ([info[@"drawid"] isEqualToString:delID])
                    {
                        [subArr removeObject:info];
                        break;
                    }
                }
            }
            else {
                [subArr addObject:drawDic];
            }
        }
        [weakSelf drawData:drawDic animationData:nil completion:nil];
    });
}

- (void)onPageChange:(id)pageChangeData
{
    CCLog(@"Chenfy--onPageChange--:%@",pageChangeData);
    if (pageChangeData == nil)
    {
        return;
    }
    NSDictionary *dicPar = (NSDictionary *)pageChangeData;
    NSString *action = dicPar[@"action"];
    if ([action isEqualToString:@"page_change"]) {
        NSNumber *page = (dicPar[@"value"][@"page"]);
        CCLog(@"Chenfy--onPageChange--page-:%@",page);
        if ([page intValue] != -1) {
            self.pageNum = [NSString stringWithFormat:@"%@",page];
            self.oldPageNum = self.pageNum;
        } else {
            self.pageNum = @"-1";
        }
    }
    if (self.drawView)
    {
        //这里是处理，在绘制的过程中，翻页了，这个时候数据全部丢掉
        CCLog(@"%s", __func__);
        [self showOrHideDrawView:NO];
    }
    NSLog(@"Chenfy----onPageChange_001");
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *pageChangeDic = (NSDictionary *)pageChangeData;
        NSString *docID = weakSelf.docId;
        [weakSelf drawData:pageChangeDic[@"value"] animationData:nil completion:^(BOOL result, NSError *error, id info) {
            NSLog(@"Chenfy----onPageChange_002");
            
            NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
            CCUser *user = [[CCStreamer sharedStreamer] getUSerInfoWithUserID:userID];
            //如果为隐身者，则用户为nil
            if (user && (user.user_AssistantState || user.user_role == CCRole_Teacher))
            {
                NSString *page = [[weakSelf.ppturl componentsSeparatedByString:@"/"] lastObject];
                page = [[page componentsSeparatedByString:@"."] firstObject];
                if (![docID isEqualToString:weakSelf.docId])
                {
                    //文档切换了，假如学生已经设为讲师，这个时候要更新文档
                    if (weakSelf.ppturl.length >0 && page.length > 0)
                    {
                        NSString *ppturl = [CCDocManager sharedManager].ppturl;
                        NSArray *strs = [ppturl componentsSeparatedByString:@"/"];
                        NSString *roomID = @"";
                        if (strs.count > 2)
                        {
                            roomID = [strs objectAtIndex:strs.count-3];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiReceiveDocChange object:nil userInfo:@{@"docID":weakSelf.docId, @"pageNum":page, @"roomid":roomID}];
                    }
                }
                else
                {
                    if (page.length > 0)
                    {
                        NSInteger pageNum = [page integerValue];
                        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiReceivePageChange object:nil userInfo:@{@"docID":docID, @"pageNum":@(pageNum)}];
                    }
                }
            }
        }];
    });
}

- (void)onDocAnimationChange:(id)animationChangeData
{
    NSString *docID = [[animationChangeData objectForKey:@"value"] objectForKey:@"docid"];
    NSString *page = [NSString stringWithFormat:@"%@", @([[[animationChangeData objectForKey:@"value"] objectForKey:@"page"] integerValue])];
    NSInteger step = [[[animationChangeData objectForKey:@"value"] objectForKey:@"step"] integerValue];
    self.animationStep = step;
    if ([docID isEqualToString:self.docId] && [page isEqualToString:self.pageNum])
    {
        [self.draw gotoStep:step];
    }
}

- (void)createBitmapView:(NSString *)url data:(NSArray *)subArr useSDK:(BOOL)useSDK docID:(NSString *)docID animationData:(NSDictionary *)animationData
{
    if (self.draw)
    {
        [self.draw removeFromSuperview];
        self.draw = nil;
    }
    self.useSDK = useSDK;
    url = [self dealWithSecurity:url];
    self.draw = [[CCDocAnimationView alloc] initWithFrame:self.docParent.bounds];
    [self.docParent addSubview:self.draw];
    WS(ws);
    [self.draw loadWithUrl:url docID:docID useSDK:useSDK drawData:subArr completion:^(id vlaue) {
        if (ws.drawView && ws.drawView.superview)
        {
            [ws.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(ws.draw);
            }];
            [ws.docParent setNeedsDisplay];
        }
    }];
    [self.docParent sendSubviewToBack:self.draw];
    
    if (animationData)
    {
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.docId,@"docid",
                                  self.pageNum, @"page",
                                  animationData[@"step"], @"step",
                                  nil];
        NSDictionary *info = @{@"value":jsonDict};
        [self onDocAnimationChange:info];
    }
}

- (void)reloadBitMapView:(NSString *)url data:(NSArray *)subArr useSDK:(BOOL)useSDK docID:(NSString *)docID animationData:(NSDictionary *)animationData
{
    if (!self.draw)
    {
        [self createBitmapView:url data:subArr useSDK:useSDK docID:docID animationData:animationData];
    }
    else
    {
        WS(ws);
        self.useSDK = useSDK;
        [self.draw loadWithUrl:url docID:docID useSDK:useSDK drawData:subArr completion:^(id vlaue) {
            [ws.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(ws.draw);
            }];
            [ws.docParent setNeedsDisplay];
        }];
        if (animationData)
        {
            NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      animationData[@"docId"],@"docid",
                                      animationData[@"pageNum"], @"page",
                                      animationData[@"step"], @"step",
                                      nil];
            NSDictionary *info = @{@"value":jsonDict};
            
            [self onDocAnimationChange:info];
        }
    }
}

- (void)drawData:(NSDictionary *)dic animationData:(NSDictionary *)animationData completion:(CCComletionBlock)completion
{
    NSLog(@"Chenfy----drawData_001_____:%@",dic);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Chenfy----drawData_002");
        
        if(dic[@"encryptDocId"]) {
            NSLog(@"Chenfy----drawData_003");
            
            NSMutableDictionary *dicByEncryptDocId = [weakSelf.allDataDic objectForKey:dic[@"docId"]];
            NSMutableArray *subArr = [dicByEncryptDocId objectForKey:[dic[@"pageNum"] stringValue]];
            
            //            weakSelf.docName = dic[@"docName"];
            //            weakSelf.pageNum = [dic[@"pageNum"] stringValue];
            //            weakSelf.docId = dic[@"docId"];
            //            weakSelf.ppturl = [self dealWithSecurity:dic[@"url"]];
            
            if (weakSelf.draw == nil) {
                NSLog(@"Chenfy----drawData_004");
                
                BOOL useSDk = [dic[@"useSDK"] boolValue];
                [weakSelf createBitmapView:[weakSelf dealWithSecurity:dic[@"url"]] data:subArr useSDK:useSDk docID:dic[@"docId"] animationData:animationData];
            } else {
                if ([dic[@"docName"] isEqualToString:weakSelf.docName] && [[dic[@"pageNum"] stringValue] isEqualToString:weakSelf.pageNum] && [dic[@"docId"] isEqualToString:weakSelf.docId] && [[weakSelf dealWithSecurity:dic[@"url"]] isEqualToString:weakSelf.ppturl]) {
                    [weakSelf.draw reloadData:subArr];
                    
                    NSLog(@"Chenfy----drawData_005");
                    
                } else {
                    
                    NSLog(@"Chenfy----drawData_006");
                    
                    BOOL useSDk = [dic[@"useSDK"] boolValue];
                    [weakSelf reloadBitMapView:[weakSelf dealWithSecurity:dic[@"url"]] data:subArr useSDK:useSDk docID:dic[@"docId"] animationData:animationData];
                }
            }
            NSLog(@"Chenfy----drawData_007");
            
            weakSelf.docName = dic[@"docName"];
            weakSelf.pageNum = [dic[@"pageNum"] stringValue];
            weakSelf.docId = dic[@"docId"];
            weakSelf.ppturl = [self dealWithSecurity:dic[@"url"]];
            if (completion)
            {
                completion(YES, nil, nil);
            }
        } else if(!dic[@"type"] && !dic[@"drawType"]){
            NSLog(@"Chenfy----drawData_008");
            
            NSMutableDictionary *dicByEncryptDocId = [weakSelf.allDataDic objectForKey:dic[@"docid"]];
            NSMutableArray *subArr = [dicByEncryptDocId objectForKey:[dic[@"page"] stringValue]];
            
            //            weakSelf.docName = dic[@"fileName"];
            //            weakSelf.pageNum = [dic[@"page"] stringValue];
            //            weakSelf.docId = dic[@"docid"];
            //            weakSelf.ppturl = [weakSelf dealWithSecurity:dic[@"url"]];
            
            if (weakSelf.draw == nil) {
                NSLog(@"Chenfy----drawData_009");
                
                BOOL useSDk = [dic[@"useSDK"] boolValue];
                [weakSelf createBitmapView:[weakSelf dealWithSecurity:dic[@"url"]] data:subArr useSDK:useSDk docID:dic[@"docid"] animationData:animationData];
            } else {
                NSLog(@"Chenfy----drawData_0010");
                
                if ([dic[@"fileName"] isEqualToString:weakSelf.docName] && [[dic[@"page"] stringValue] isEqualToString:weakSelf.pageNum] && [dic[@"docid"] isEqualToString:weakSelf.docId] && [[weakSelf dealWithSecurity:dic[@"url"]] isEqualToString:weakSelf.ppturl]) {
                    [weakSelf.draw reloadData:subArr];
                } else {
                    NSLog(@"Chenfy----drawData_0011");
                    
                    //TODO..Chenfy..NeedToModify
                    BOOL useSDk = [dic[@"useSDK"] boolValue];
                    [weakSelf reloadBitMapView:[weakSelf dealWithSecurity:dic[@"url"]] data:subArr useSDK:useSDk docID:dic[@"docid"] animationData:animationData];
                }
            }
            //TODO..
            NSLog(@"Chenfy----drawData_0012");
            
            weakSelf.docName = dic[@"fileName"];
            weakSelf.pageNum = [dic[@"page"] stringValue];
            weakSelf.docId = dic[@"docid"];
            weakSelf.ppturl = [weakSelf dealWithSecurity:dic[@"url"]];
            if (completion)
            {
                completion(YES, nil, nil);
            }
        }else if(dic[@"type"] || dic[@"drawType"]) {
            NSMutableDictionary *dicByEncryptDocId = [weakSelf.allDataDic objectForKey:dic[@"docid"]];
            NSMutableArray *subArr = [dicByEncryptDocId objectForKey:[dic[@"page"] stringValue]];
            if (weakSelf.draw == nil) {
                BOOL useSDk = [dic[@"useSDK"] boolValue];
                [weakSelf createBitmapView:@"#" data:subArr useSDK:useSDk docID:dic[@"docid"] animationData:animationData];
            } else {
                [weakSelf.draw drawOneImageWithData:dic];
            }
        }
        if (completion)
        {
            completion(YES, nil, nil);
        }
    });
}

-(NSString *)dealWithSecurity:(NSString *)playUrl
{
    if ([playUrl isEqualToString:@"#"])
    {
        return playUrl;
    }
    playUrl = [playUrl stringByReplacingOccurrencesOfString:@"http:" withString:@""];
    playUrl = [playUrl stringByReplacingOccurrencesOfString:@"https:" withString:@""];
    playUrl =[NSString stringWithFormat:@"https:%@", playUrl];
    return playUrl;
}

- (void)onHistoryData:(NSDictionary *)historyDic completion:(CCComletionBlock)completion
{
    if(self.docParent == nil || historyDic == nil || [historyDic count] == 0)
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:historyDic];
    NSMutableArray *drawDataArr = [dataDic[@"draw"] mutableCopy];
    NSMutableArray *pageChangeDataArr = [dataDic[@"pageChange"] mutableCopy];
    NSMutableArray *animation = [dataDic[@"animation"] mutableCopy];
    for(NSInteger i = 0; i < [drawDataArr count] ;i++ ) {
        NSDictionary *dicDraw = [drawDataArr objectAtIndex:i];
        NSString *jsonDrawStr = dicDraw[@"data"];
        NSData *jsonData = [jsonDrawStr dataUsingEncoding:NSUTF8StringEncoding];
        id jsonDrawValue = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        NSDictionary *drawDic = (NSDictionary *)jsonDrawValue;
        NSString *docid = drawDic[@"docid"];
        NSMutableDictionary *dic = [weakSelf.allDataDic objectForKey:docid];
        if (dic == nil) {
            dic = [[NSMutableDictionary alloc] init];
            [weakSelf.allDataDic setObject:dic forKey:docid];
        }
        NSString *pageNum = [dicDraw[@"pageNum"] stringValue];
        NSMutableArray *subArr = [dic objectForKey:pageNum];
        if (subArr == nil) {
            subArr = [[NSMutableArray alloc] init];
            [dic setObject:subArr forKey:pageNum];
        }
        NSString *valueType = [drawDic objectForKey:@"valueType"];
        if ([valueType isEqualToString:@"video_draw"])
        {
            NSInteger videoStatus = [CCStreamer sharedStreamer].getRoomInfo.videoStatus;
            NSTimeInterval videoSuspendTime = [CCStreamer sharedStreamer].getRoomInfo.videoSuspendTime;
            NSTimeInterval drawTime = [[drawDic objectForKey:@"media_stamp"] doubleValue];
            if (videoStatus == 0 && drawTime == videoSuspendTime)
            {
                //视频是暂停状态，而且暂停时间戳一样
                //视屏暂停标注的画笔信息
                NSInteger type = [drawDic[@"drawType"] intValue];
                if (type == 1)
                {//画笔
                    [subArr addObject:drawDic];
                }
                else if (type == 2)
                {//清除自己的上一步
                    NSString *delDrawID = drawDic[@"drawid"];
                    for (NSDictionary *drawInfo in subArr)
                    {
                        NSString *drawID = [drawInfo objectForKey:@"drawid"];
                        if ([drawID isEqualToString:delDrawID])
                        {
                            [subArr removeObject:drawInfo];
                            break;
                        }
                    }
                }
                else if(3)
                {
                    //清屏
                    [subArr removeAllObjects];
                }
            }
        }
        else
        {
            NSInteger type = [drawDic[@"type"] intValue];
            if (type == 0) {//清屏
                [subArr removeAllObjects];
            }else if (type == 1) {//清除上一步
                if (subArr.count > 0) {
                    [subArr removeLastObject];
                }
            }else if (type == 6) {//清理整个文档数据
                [subArr removeAllObjects];
                [dic removeAllObjects];
                [weakSelf.allDataDic removeObjectForKey:docid];
            }else if (type == 7) {//清理整个文档数据
                [subArr removeAllObjects];
                [dic removeAllObjects];
                [weakSelf.allDataDic removeAllObjects];
            }
            else if (type == 9) {//清除自己的上一步
                NSString *delDrawID = drawDic[@"drawid"];
                for (NSDictionary *drawInfo in subArr)
                {
                    NSString *drawID = [drawInfo objectForKey:@"drawid"];
                    if ([drawID isEqualToString:delDrawID])
                    {
                        [subArr removeObject:drawInfo];
                        break;
                    }
                }
            }else{
                [subArr addObject:drawDic];
            }
        }
    }
    if (pageChangeDataArr.count == 0)
    {
        NSDictionary *info = @{@"docId":@"WhiteBorad",
                               @"docName":@"WhiteBorad",
                               @"docTotalPage": @0,
                               @"encryptDocId":@"WhiteBorad",
                               @"height":@0,
                               @"pageNum":@(-1),
                               @"time":@1886,
                               @"url":@"#",
                               @"useSDK":@0,
                               @"width":@0
                               };
        [weakSelf drawData:info animationData:nil completion:completion];
    }
    else
    {
        NSDictionary *pageChangeDic = [pageChangeDataArr lastObject];
        NSDictionary *animationDic = [animation lastObject];
        self.useSDK = [pageChangeDic[@"useSDK"] boolValue];
        if([animationDic[@"time"] integerValue] >= [pageChangeDic[@"time"] integerValue]) {
            [weakSelf drawData:[pageChangeDataArr lastObject] animationData:animationDic completion:completion];
        } else {
            [weakSelf drawData:[pageChangeDataArr lastObject] animationData:nil completion:completion];
        }
    }
}

- (void)clearWhiteBoardData
{
    [self.allDataDic removeAllObjects];
    [self.draw clearAllDrawViews];
}

- (void)clearDataByDocID:(NSString *)docID num:(NSString *)num
{
    if (docID.length > 0)
    {
        if ([self.allDataDic.allKeys containsObject:docID])
        {
            if (num.length == 0)
            {
                [self.allDataDic removeObjectForKey:docID];
                [self.draw clearAllDrawViews];
            }
            else
            {
                NSMutableDictionary *nowDocData = [self.allDataDic objectForKey:docID];
                if ([nowDocData.allKeys containsObject:num])
                {
                    [nowDocData removeObjectForKey:num];
                    [self.allDataDic setObject:nowDocData forKey:docID];
                    [self.draw clearAllDrawViews];
                }
            }
        }
    }
}

- (void)clearData
{
    [self.allDataDic removeAllObjects];
    [self.draw clearAllDrawViews];
    self.draw = nil;
    self.docParent = nil;
}

#pragma mark - draw
- (void)showOrHideDrawView:(BOOL)hide
{
    if (hide)
    {
        [self.drawView removeFromSuperview];
        self.drawView = nil;
    }
    else
    {
        if (_drawView)
        {
            [self.drawView removeFromSuperview];
            self.drawView = nil;
        }
        [self drawView1];
    }
    self.drawView.hidden = self.videoSuspend;
    
    //判断当前用户是否可编辑
    if ([self user_can_edit]){
        [self  showDrawView];
    } else {
        [self hideDrawView];
    }
}

//判断当前用户是否可编辑（被授权标注或者被授权为讲师后可编辑）
- (BOOL)user_can_edit
{
    NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
    CCUser *user = [[CCStreamer sharedStreamer] getUSerInfoWithUserID:userID];
    if (user && (user.user_AssistantState || user.user_role == CCRole_Teacher || user.user_drawState))
    {
        return YES;
    }
    return NO;
}

- (void)hideDrawView
{
    if (self.drawView)
    {
        self.drawView.userInteractionEnabled = NO;
    }
}

- (void)showDrawView
{
    if (self.drawView)
    {
        self.drawView.userInteractionEnabled = YES;
    }
}

- (LSDrawView *)drawView1
{
    if (!_drawView)
    {
        WS(ws);
        LSDrawView *drawView = [[LSDrawView alloc] initWithFrame:self.draw ? self.draw.bounds : self.docParent.bounds];
        NSString *lineWith = GetFromUserDefaults(DRAWWIDTH);
        int lineColor = [GetFromUserDefaults(DRAWCOLOR) intValue];
        if (lineWith == 0)
        {
            SaveToUserDefaults(DRAWWIDTH, DRAWWIDTHONE);
            lineWith = DRAWWIDTHONE;
        }
        if (lineColor == 0)
        {
            drawView.brushColor = CCRGBColor(74, 159, 218);
            SaveToUserDefaults(DRAWCOLOR, @(4));
        }
        else
        {
            if (lineColor == 1)
            {
                drawView.brushColor = CCRGBColor(0, 0, 0);
            }
            else if (lineColor == 2)
            {
                drawView.brushColor = MainColor;
            }
            else if (lineColor == 3)
            {
                drawView.brushColor = CCRGBColor(39, 193, 39);
            }
            else if (lineColor == 4)
            {
                drawView.brushColor = CCRGBColor(74, 159, 218);
            }
            else if (lineColor == 5)
            {
                drawView.brushColor = CCRGBColor(139, 139, 139);
            }
            else
            {
                drawView.brushColor = CCRGBColor(206, 38, 38);
            }
        }
        drawView.brushWidth = [lineWith floatValue];
        
        drawView.shapeType = LSShapeCurve;
        
        //        drawView.backgroundImage = [UIImage imageNamed:@"20130616030824963"];
        
        if (self.docParent)
        {
            [self.docParent addSubview:drawView];
            if (self.draw)
            {
                [drawView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(ws.draw);
                }];
            }
            _drawView = drawView;
        }
    }
    return _drawView;
}

#pragma mark - send data
- (void)revokeDrawData
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    now = now*1000;
    //    int del = (int)(now - [[CCStreamer sharedStreamer] getRoomInfo].liveStartTime);
    NSTimeInterval del = [CCDocManager getNowTime];
    NSString *key = [NSString stringWithFormat:@"%@%@", self.docId, self.pageNum];
    NSMutableArray *pagedrawid = self.topDrawID[key];
    if (pagedrawid.count > 0)
    {
        NSString *drawid = [pagedrawid lastObject];
        [pagedrawid removeLastObject];
        self.topDrawID[key] = pagedrawid;
        if (drawid)
        {
            NSDictionary *data = @{
                                   @"docid" : self.docId,
                                   @"drawid" : drawid,
                                   @"page" : @([self.pageNum integerValue]),
                                   @"type" : @9,
                                   };
            NSDictionary *value = @{
                                    @"page" : @([self.pageNum integerValue]),
                                    @"fileName":self.docName,
                                    @"data":data,
                                    };
            NSDictionary *info  = @{
                                    @"action" : @"draw",
                                    @"time" : @([CCDocManager getNowTime]),
                                    @"value" : value,
                                    };
            [[CCStreamer sharedStreamer] sendDrawData:info];
        }
        [self.drawView.canvasView setBrush:nil];
    }
}
- (void)sendDrawData:(NSArray *)points
{
    //Chenfy..TODO..TEST
    //判断视频状态
    if (self.videoSuspend) {
        self.pageNum = @"-1";
    } else {
        self.pageNum = self.oldPageNum;
    }
    //判断是否是白板，如果是白板则page为“-1”
    if ([self.docId isEqualToString:@"WhiteBorad"]) {
        self.pageNum = @"-1";
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    now = now*1000;
    NSString *stringNow = [NSString stringWithFormat:@"%@",@(now)];
    NSArray *subStrings = [stringNow componentsSeparatedByString:@"."];
    
    NSString *timeString = [subStrings firstObject];
    
    __unused NSTimeInterval del = [CCDocManager getNowTime];
    
    NSString *viewername = [CCStreamer sharedStreamer].getRoomInfo.user_name;
    NSString *viewerid = [CCStreamer sharedStreamer].getRoomInfo.user_id;
    //    NSString *drawid = [NSString stringWithFormat:@"%@%@", viewerid, @(now)];
    NSString *drawid = [NSString stringWithFormat:@"%@%@", viewerid, timeString];
    if (!self.topDrawID)
    {
        self.topDrawID = [NSMutableDictionary dictionary];
    }
    
    NSString *key = [NSString stringWithFormat:@"%@%@", self.docId, self.pageNum];
    NSMutableArray *pageDrawID = self.topDrawID[key];
    if (!pageDrawID)
    {
        pageDrawID = [NSMutableArray array];
    }
    [pageDrawID addObject:drawid];
    self.topDrawID[key] = pageDrawID;
    NSDictionary *data = @{
                           @"alpha" : @1,
                           @"viewername":viewername,
                           @"viewerid":viewerid,
                           @"drawid":drawid,
                           @"color" : [self getColorStrFromColor:self.drawView.brushColor],
                           @"docid" : self.docId,
                           @"draw" : points,
                           @"height" : @(self.drawView.canvasView.frame.size.height),
                           @"name" : self.docName,
                           @"page" : @([self.pageNum integerValue]),
                           @"thickness" : @(self.drawView.brushWidth),
                           @"type" : @2,
                           @"width" : @(self.drawView.canvasView.frame.size.width),
                           };
    NSDictionary *value = @{
                            @"page" : @([self.pageNum integerValue]),
                            @"fileName":self.docName,
                            @"data":data,
                            };
    NSDictionary *info  = @{
                            @"action" : @"draw",
                            @"time" : @([CCDocManager getNowTime]),
                            @"value" : value,
                            };
    if ([CCStreamer sharedStreamer].getRoomInfo.live_status == CCLiveStatus_Start)
    {
        [[CCStreamer sharedStreamer] sendDrawData:info];
    }
    else
    {
        [self onDraw:info];
    }
}

- (void)cleanDrawData
{
    [self clearDataByDocID:self.docId num:self.pageNum];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    now = now*1000;
    //    int del = (int)(now - [[CCStreamer sharedStreamer] getRoomInfo].liveStartTime);
    NSTimeInterval del = [CCDocManager getNowTime];
    NSString *key = [NSString stringWithFormat:@"%@%@", self.docId, self.pageNum];
    NSMutableArray *pagedrawid = self.topDrawID[key];
    if (pagedrawid.count > 0)
    {
        NSString *drawid = [pagedrawid lastObject];
        [pagedrawid removeLastObject];
        self.topDrawID[key] = pagedrawid;
        if (drawid)
        {
            NSDictionary *data = @{
                                   @"docid" : self.docId,
                                   @"drawid" : drawid,
                                   @"page" : @([self.pageNum integerValue]),
                                   @"type" : @0,
                                   };
            NSDictionary *value = @{
                                    @"page" : @([self.pageNum integerValue]),
                                    @"fileName":self.docName,
                                    @"data":data,
                                    };
            NSDictionary *info  = @{
                                    @"action" : @"draw",
                                    @"time" : @([CCDocManager getNowTime]),
                                    @"value" : value,
                                    };
            [[CCStreamer sharedStreamer] sendDrawData:info];
        }
        else
        {
            NSString *viewerid = [CCStreamer sharedStreamer].getRoomInfo.user_id;
            NSString *drawid = [NSString stringWithFormat:@"%@%@", viewerid, @(now)];
            NSDictionary *data = @{
                                   @"docid" : self.docId,
                                   @"drawid" : drawid,
                                   @"page" : @([self.pageNum integerValue]),
                                   @"type" : @0,
                                   };
            NSDictionary *value = @{
                                    @"page" : @([self.pageNum integerValue]),
                                    @"fileName":self.docName,
                                    @"data":data,
                                    };
            NSDictionary *info  = @{
                                    @"action" : @"draw",
                                    @"time" : @([CCDocManager getNowTime]),
                                    @"value" : value,
                                    };
            [[CCStreamer sharedStreamer] sendDrawData:info];
        }
        [self.drawView.canvasView setBrush:nil];
    }
    else
    {
        NSString *viewerid = [CCStreamer sharedStreamer].getRoomInfo.user_id;
        NSString *drawid = [NSString stringWithFormat:@"%@%@", viewerid, @(now)];
        NSDictionary *data = @{
                               @"docid" : self.docId,
                               @"drawid" : drawid,
                               @"page" : @([self.pageNum integerValue]),
                               @"type" : @0,
                               };
        NSDictionary *value = @{
                                @"page" : @([self.pageNum integerValue]),
                                @"fileName":self.docName,
                                @"data":data,
                                };
        NSDictionary *info  = @{
                                @"action" : @"draw",
                                @"time" : @([CCDocManager getNowTime]),
                                @"value" : value,
                                };
        [[CCStreamer sharedStreamer] sendDrawData:info];
    }
}

- (void)sendAnimationChange:(NSString *)docid page:(NSInteger)page step:(NSUInteger)step
{
    if (docid.length > 0)
    {
        if (page < 0)
        {
            page = [self.pageNum integerValue];
        }
        NSDictionary *jsonDict = @{@"docid":docid,
                                   @"page":@(page),
                                   @"step":@(step)};
        NSDictionary *info = @{@"time":@([CCDocManager getNowTime]), @"value":jsonDict, @"action":@"animation_change"};
        [[CCStreamer sharedStreamer] sendAnimationChange:info];
    }
}

- (void)sendDocChange:(CCDoc *)doc currentPage:(NSInteger)currentPage
{
    NSString *url = [doc getPicUrl:currentPage];
    [self sendDocChange:doc.docID fileName:doc.docName page:currentPage totalPage:doc.pageSize url:url useSDK:doc.useSDK];
}

- (void)sendDocChange:(NSString *)docID fileName:(NSString *)fileName page:(NSInteger)page totalPage:(NSInteger)totalPage url:(NSString *)url useSDK:(BOOL)useSDk
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *imageUrl = [NSURL URLWithString:url];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        CGFloat width = self.docParent.frame.size.width;
        CGFloat height = self.docParent.frame.size.height;
        if (!CGSizeEqualToSize(image.size, CGSizeZero))
        {
            width = image.size.width;
            height = image.size.height;
        }
        NSString *newUrl = url;
        if (url.length > 0)
        {
            if ([newUrl isEqualToString:@"#"])
            {
                newUrl = [[url componentsSeparatedByString:@":"] lastObject];
            }
            else
            {
                newUrl = [[url componentsSeparatedByString:@":"] lastObject];
                newUrl = [NSString stringWithFormat:@"http:%@", newUrl];
            }
        }
        NSDictionary *value = @{@"docid":docID.length == 0 ? @"" : docID,
                                @"fileName":fileName.length == 0 ? @"":fileName,
                                @"page":@(page),
                                @"totalPage":@(totalPage),
                                @"url":newUrl.length == 0 ? @"#":newUrl,
                                @"useSDK":useSDk ? @(YES) : @(NO),
                                @"height" : @(width),
                                @"width" : @(height)};
        if ([CCStreamer sharedStreamer].getRoomInfo.live_status == CCLiveStatus_Stop)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiReceiveSocketEvent object:nil userInfo:@{@"event":@(CCSocketEvent_DocPageChange), @"value":@{@"value":value}}];
        }
        else
        {
            NSDictionary *info = @{@"time":@([CCDocManager getNowTime]), @"value":value, @"action":@"page_change"};
            [[CCStreamer sharedStreamer] docPageChange:info];
        }
    });
}

- (void)docPageChange:(NSInteger)num docID:(NSString *)docID fileName:(NSString *)fileName totalPage:(NSInteger)totalPage url:(NSString *)url
{
    [self sendDocChange:docID fileName:fileName page:num totalPage:totalPage url:url useSDK:NO];
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //        NSURL *imageUrl = [NSURL URLWithString:url];
    //        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    //        CGFloat width = self.docParent.frame.size.width;
    //        CGFloat height = self.docParent.frame.size.height;
    //        if (!CGSizeEqualToSize(image.size, CGSizeZero))
    //        {
    //            width = image.size.width;
    //            height = image.size.height;
    //        }
    //
    //        NSDictionary *value = @{@"docid":docID.length == 0 ? @"" : docID,
    //                                @"fileName":fileName.length == 0 ? @"":fileName,
    //                                @"page":@(num),
    //                                @"totalPage":@(totalPage),
    //                                @"url":url.length == 0 ? @"#":url,
    //                                @"height" : @(width),
    //                                @"width" : @(height)};
    //        if ([CCStreamer sharedStreamer].getRoomInfo.live_status != CCLiveStatus_Start)
    //        {
    //            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiReceiveSocketEvent object:nil userInfo:@{@"event":@(CCSocketEvent_DocPageChange), @"value":@{@"value":value}}];
    //        }
    //        else
    //        {
    //            [[CCStreamer sharedStreamer] docPageChange:@{@"time":@([CCDocManager getNowTime]), @"value":value, @"action":@"page_change"}];
    //        }
    //    });
}

- (BOOL)changeToBack:(CCDoc *)doc currentPage:(NSInteger)currentPage
{
    if (currentPage < 0)
    {
        return NO;
    }
    NSInteger step = [self.draw changeToBack];
    if (step < 0)
    {
        if (step <= -100)
        {
            return NO;
        }
        //翻页
        currentPage--;
        if (currentPage < 0)
        {
            return NO;
        }
        NSString *url = [doc getPicUrl:currentPage];
        [self sendDocChange:doc.docID fileName:doc.docName page:currentPage totalPage:doc.pageSize url:url useSDK:doc.useSDK];
        return YES;
    }
    else
    {
        //动画
        [self sendAnimationChange:doc.docID page:currentPage step:step];
        return NO;
    }
}

- (BOOL)changeToFront:(CCDoc *)doc currentPage:(NSInteger)currentPage
{
    NSInteger step = [self.draw changeToFront];
    if (step <= 0)
    {
        if (step <= -100)
        {
            return NO;
        }
        //翻页
        currentPage++;
        if (currentPage >= doc.pageSize)
        {
            return NO;
        }
        NSString *url = [doc getPicUrl:currentPage];
        [self sendDocChange:doc.docID fileName:doc.docName page:currentPage totalPage:doc.pageSize url:url useSDK:doc.useSDK];
        return YES;
    }
    else
    {
        //动画
        [self sendAnimationChange:doc.docID page:currentPage step:step];
        return NO;
    }
}

- (NSString *)getColorStrFromColor:(UIColor *)col
{
    CGFloat R, G, B, A;
    CGColorRef color = [col CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(color);
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(color);
        R = components[0]*255;
        G = components[1]*255;
        B = components[2]*255;
        A = components[3];
        NSString *rgbOne = [NSString stringWithFormat:@"%@%@%@",[[self class] ToHex:R], [[self class] ToHex:G], [[self class] ToHex:B]];
        NSNumber *rgbNum = [[self class] numberHexString:rgbOne];
        return [NSString stringWithFormat:@"%@", rgbNum];
    }
    else
    {
        return @"0";
    }
}

#pragma mark - 视频暂停标注 - 暂停调用
- (BOOL)changeToDoc:(NSString *)docid page:(NSString *)page
{
    if (!self.historyDataReady)
    {
        return NO;
    }
    
    CGFloat width = self.docParent.frame.size.width;
    CGFloat height = self.docParent.frame.size.height;
    NSDictionary *value = @{@"docid":docid,
                            @"fileName":@"",
                            @"page":@([page intValue]),
                            @"totalPage":@(0),
                            @"url":@"#",
                            @"useSDK":@(NO),
                            @"height" : @(width),
                            @"width" : @(height)};
    value = @{@"value":value};
    self.oldDocId = self.docId;
    if (![docid isEqualToString:@"video_draw"]) {
        self.docId = docid;
    }
    self.oldPpturl = self.ppturl;
    self.oldDocName = self.docName;
    if (![self.pageNum isEqualToString:@"-1"]) {
        self.oldPageNum = self.pageNum;
    }
    self.oldUseSDK = self.useSDK;
    [self onPageChange:value];
    
    self.videoSuspend = YES;
    return YES;
}

//PPT恢复
- (BOOL)clearDoc:(NSString *)docid
{
    if (self.oldDocId.length == 0)
    {
        return NO;
    }
    //如果当前视频不是静止平铺，则不需要恢复数据
    if (self.videoSuspend == NO)
    {
        return YES;
    }
    self.videoSuspend = NO;
    //Chenfy..added
    if ([self.pageNum isEqualToString:@"-1"] && ![self.docId isEqualToString:@"WhiteBoard"]) {
        self.pageNum = self.oldPageNum;
    }
    if ([self.oldDocId isEqualToString:@"WhiteBoard"] || [self.oldDocId isEqualToString:@"WhiteBorad"]) {
        self.pageNum = @"-1";
    }
    
    CGFloat width = self.docParent.frame.size.width;
    CGFloat height = self.docParent.frame.size.height;
    NSDictionary *value = @{@"docid":self.oldDocId,
                            @"fileName":self.oldDocName,
                            @"page":@([self.pageNum integerValue]),
                            @"totalPage":@(0),
                            @"url":@"#",
                            @"useSDK":@(self.oldUseSDK),
                            @"height" : @(width),
                            @"width" : @(height)};
    value = @{@"value":value};
    
    CCLog(@"Chenfy..clearDoc....%@",value);
    
    [self onPageChange:value];
    [self.allDataDic removeObjectForKey:docid];
    return YES;
}

+(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int oldValue = tmpid;
    long long int ttmpig;
    for (int i =0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc] initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    if (oldValue < 16)
    {
        //补上0
        str = [NSString stringWithFormat:@"0%@", str];
    }
    return str;
}

+ (NSNumber *) numberHexString:(NSString *)aHexString
{
    // 为空,直接返回.
    if (nil == aHexString)
    {
        return nil;
    }
    
    NSScanner * scanner = [NSScanner scannerWithString:aHexString];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    
    //将整数转换为NSNumber,存储到数组中,并返回.
    NSNumber * hexNumber = [NSNumber numberWithLongLong:longlongValue];
    
    return hexNumber;
    
}

+ (NSTimeInterval)getNowTime
{
    NSTimeInterval publishTime = [CCStreamer sharedStreamer].getRoomInfo.liveStartTime;
    NSTimeInterval timeInt = [[NSDate date] timeIntervalSince1970];
    publishTime = publishTime/1000;
    NSTimeInterval time = timeInt - publishTime;
    int intValue = time;
    return intValue;
}
@end
