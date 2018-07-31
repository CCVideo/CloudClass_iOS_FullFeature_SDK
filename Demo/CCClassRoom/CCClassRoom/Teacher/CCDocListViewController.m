//
//  CCDocListViewController.m
//  CCClassRoom
//
//  Created by cc on 17/4/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocListViewController.h"
#import "CCDoc.h"
#import "CCDocTableViewCell.h"
#import <Masonry.h>
#import <UIAlertView+BlocksKit.h>
#import <CCClassRoom/CCClassRoom.h>

@interface CCDocListViewController ()
@property (strong, nonatomic) NSMutableArray *data;
@end

@implementation CCDocListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"提取文档";
    [self makeData];
}

- (UIView *)footerview
{
//    if (self.data.count > 0)
//    {
        UILabel *label = [UILabel new];
        label.text = @"请通过Web端将文档上传至文档区";
        label.textColor = [UIColor colorWithRed:157/255.f green:157.f/255.f blue:157.f/255.f alpha:1.f];
        label.font = [UIFont systemFontOfSize:FontSizeClass_14];
        label.textAlignment = NSTextAlignmentCenter;
        
        UIView *backView = [UIView new];
        [backView addSubview:label];
        [label mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(backView).offset(5.f);
//            make.right.mas_equalTo(backView).offset(-5.f);
            make.center.mas_equalTo(backView).offset(0.f);
        }];
        self.tableView.scrollEnabled = YES;
        backView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 40.f);
        return backView;
//    }
//    else
//    {
//        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.tableView.frame.size.width, self.tableView.frame.size.height - 64 - 64)];
//        
//        
//        UILabel *label = [UILabel new];
//        label.text = @"请通过Web端将文档上传至文档区";
//        label.textColor = [UIColor colorWithRed:157/255.f green:157.f/255.f blue:157.f/255.f alpha:1.f];
//        label.font = [UIFont systemFontOfSize:FontSizeClass_14];
//        label.textAlignment = NSTextAlignmentCenter;
//        [backView addSubview:label];
//        [label mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(backView).offset(10.f);
//            make.right.mas_equalTo(backView).offset(-10.f);
//            make.top.mas_equalTo(backView).offset(10.f);
//        }];
//        
//        UIImageView *noDocImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty"]];
//        UILabel *noDocLabel = [UILabel new];
//        noDocLabel.textColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5];
//        noDocLabel.text = @"文档区暂无文件";
//        [backView addSubview:noDocImageView];
//        [backView addSubview:noDocLabel];
//        [noDocImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.mas_equalTo(backView);
//            make.centerY.mas_equalTo(backView);
//        }];
//        
//        [noDocLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.mas_equalTo(noDocImageView);
//            make.top.mas_equalTo(noDocImageView.mas_bottom).offset(10.f);
//        }];
//        self.tableView.scrollEnabled = NO;
//        return backView;
//    }
}

- (void)makeData
{
    if (self.data)
    {
        [self.data removeAllObjects];
        self.data = nil;
    }
    self.data = [NSMutableArray array];
    [[CCStreamer sharedStreamer] getRoomDocs:@"" completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSDictionary *dic = info;
            NSLog(@"%s_%@", __func__, info);
            NSString *result = dic[@"result"];
            if ([result isEqualToString:@"OK"])
            {
                NSString *picDomain = [dic objectForKey:@"picDomain"];
                NSArray *docs = [dic objectForKey:@"docs"];
                for (NSDictionary *doc in docs)
                {
                    CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];
                    [self.data addObject:newDoc];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                });
            }
            else
            {
                
            }
        }
        else
        {
            self.data = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    
    [[CCStreamer sharedStreamer] getReleatedRoomDocs:@"" completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSDictionary *dic = info;
            NSLog(@"%s_%@", __func__, info);
            NSString *result = dic[@"result"];
            if ([result isEqualToString:@"OK"])
            {
                NSString *picDomain = [dic objectForKey:@"picDomain"];
                NSArray *docs = [dic objectForKey:@"docs"];
                for (NSDictionary *doc in docs)
                {
                    CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];
                    newDoc.isReleatedDoc = YES;
                    [self.data addObject:newDoc];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                });
            }
            else
            {
                
            }
        }
        else
        {
            self.data = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self footerview].bounds.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self footerview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndetifer = @"Cell";
    CCDocTableViewCell * cell;
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BoardCell" forIndexPath:indexPath];
//        [cell reloadWithInfo:@{@"image":@"board", @"name":@"白板"}];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifer forIndexPath:indexPath];
        [cell reloadWithDoc:self.data[indexPath.row - 1]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return nil;
    }
    else
    {
        UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
            CCDoc *doc = self.data[indexPath.row - 1];
            NSString *msg = [NSString stringWithFormat:@"是否删除文档：%@", doc.docName];
            [UIAlertView bk_showAlertViewWithTitle:@"" message:msg cancelButtonTitle:@"确定" otherButtonTitles:@[@"取消"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0)
                {
                    if (doc.isReleatedDoc)
                    {
                        [[CCStreamer sharedStreamer] unReleatedDoc:doc.docID roomID:@"" completion:^(BOOL result, NSError *error, id info) {
                            if (result)
                            {
                                NSString *result = info[@"result"];
                                if ([result isEqualToString:@"OK"])
                                {
                                    [self.data removeObject:doc];
                                    [self.tableView reloadData];
                                    //这个时候假如删除的是当前显示文档，要特殊处理
                                    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiDelDoc object:nil userInfo:@{@"value":doc}];
                                }
                            }
                        }];
                    }
                    else
                    {
                        //删除文档
                        [[CCStreamer sharedStreamer] delDoc:doc.docID roomID:@"" completion:^(BOOL result, NSError *error, id info) {
                            if (result)
                            {
                                NSString *result = info[@"result"];
                                if ([result isEqualToString:@"OK"])
                                {
                                    [self.data removeObject:doc];
                                    [self.tableView reloadData];
                                    //这个时候假如删除的是当前显示文档，要特殊处理
                                    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiDelDoc object:nil userInfo:@{@"value":doc}];
                                }
                            }
                        }];
                    }
                }
            }];
            // 收回左滑出现的按钮(退出编辑模式)
            tableView.editing = NO;
        }];
        return @[action0];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这里要更新文档
    CCDoc *doc;
    if (indexPath.row == 0)
    {
        doc = [[CCDoc alloc] init];
        doc.docID = @"WhiteBoard";
        doc.docName = @"WhiteBoard";
        doc.pageSize = 0;
        doc.roomID = GetFromUserDefaults(LIVE_ROOMID);
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":doc, @"page":@(0)}];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        doc = self.data[indexPath.row - 1];
        __weak typeof(self) weakSelf = self;
        [[CCStreamer sharedStreamer] getRoomDoc:doc.docID roomID:doc.roomID completion:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                NSLog(@"%s__%@", __func__, info);
                if ([[info objectForKey:@"result"] isEqualToString:@"OK"])
                {
                    NSDictionary *dic = info;
                    NSString *picDomain = [dic objectForKey:@"picDomain"];
                    NSDictionary *doc = [dic objectForKey:@"doc"];
                    CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(0)}];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":doc, @"page":@(0)}];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":doc, @"page":@(0)}];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
