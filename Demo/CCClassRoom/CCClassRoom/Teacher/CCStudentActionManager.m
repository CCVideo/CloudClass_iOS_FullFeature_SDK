//
//  CCStudentActionManager.m
//  CCClassRoom
//
//  Created by cc on 17/4/28.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStudentActionManager.h"
#import <CCClassRoom/CCClassRoom.h>
#import <BlocksKit+UIKit.h>
#import "LCActionSheet.h"

#define ACTIONSHEETTAGONE 1001
#define ACTIONSHEETTAGTWO 1002
#define ACTIONSHEETTAGTHTREE 1003
#define ACTIONSHEETTAGFOUR 1004
#define ACTIONSHEETTAGFIVE 1005
#define ACTIONSHEETTAGSIX 1006
#define ACTIONSHEETTAGSEVEN 1007

@interface CCStudentActionManager()<UIActionSheetDelegate>
{
    CCStudentActionManagerBlock block;
}
@property (strong, nonatomic) CCMemberModel *showModel;
@end

@implementation CCStudentActionManager
- (void)showWithUserID:(NSString *)userID inView:(UIView *)view dismiss:(CCStudentActionManagerBlock)completion
{
    if ([[CCStreamer sharedStreamer] getRoomInfo].user_role != CCRole_Teacher)
    {
        return;
    }
    CCMemberModel *model = [self modelWithUserID:userID];
    [self showWithModel:model inView:view dismiss:completion];
}

- (void)showWithModel:(CCMemberModel *)model inView:(UIView *)view dismiss:(CCStudentActionManagerBlock)completion
{
    self.showModel = model;
    block = completion;
    __weak typeof(self) weakSelf = self;
    NSArray *titleArray;
    NSInteger tag = 0;
    if (model.type == CCMemberType_Audience)
    {
        //旁听
        BOOL mute = [[CCStreamer sharedStreamer] getAudienceChatStatus:model.userID];
        NSString *title = mute ? @"解除禁言" : @"禁言";
//        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:title, @"踢出房间", nil];
//        sheet.tag = ACTIONSHEETTAGSIX;
//        [sheet showInView:view];
        titleArray = @[title, @"踢出房间"];
        tag = ACTIONSHEETTAGSIX;
    }
    else if (model.type == CCMemberType_Teacher)
    {
        return;
    }
    else
    {
        NSString *drawtitle = [self getDrawTitleWithModel:model];
        if (model.micType == CCUserMicStatus_Connected || model.micType == CCUserMicStatus_Connecting)
        {
            //踢下麦，禁言，取消
            NSString *title = @"";
            BOOL audioOpened = YES;
            if (model.streamID)
            {
                for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([user.user_id isEqualToString:model.userID])
                    {
                        audioOpened = user.user_audioState;
                        title = user.user_chatState ? @"禁言" : @"解除禁言";
                        break;
                    }
                }
            }
//            NSString *audioTitle = audioOpened ? @"关闭麦克风" : @"开启麦克风";
//            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:drawtitle, @"踢下麦", title, @"踢出房间", nil];
//            sheet.tag = ACTIONSHEETTAGONE;
//            [sheet showInView:view];
            
            titleArray = @[drawtitle, @"踢下麦", title, @"踢出房间"];
            tag = ACTIONSHEETTAGONE;
        }
        else
        {
            CCClassType mode = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
            if (mode == CCClassType_Auto)
            {
                NSString *title = model.isMute ? @"解除禁言" : @"禁言";
//                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:drawtitle, title, @"踢出房间", nil];
//                sheet.tag = ACTIONSHEETTAGFIVE;
//                [sheet showInView:view];
                titleArray = @[drawtitle, title, @"踢出房间"];
                tag = ACTIONSHEETTAGFIVE;
            }
            else if(mode == CCClassType_Named)
            {
                if(model.micType == CCUserMicStatus_None)
                {
                    //邀请上麦
                    //禁言,取消
                    NSString *title = model.isMute ? @"解除禁言" : @"禁言";
//                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:drawtitle, @"邀请上麦", title, @"踢出房间", nil];
//                    sheet.tag = ACTIONSHEETTAGTWO;
//                    [sheet showInView:view];
                    titleArray = @[drawtitle, @"邀请上麦", title, @"踢出房间"];
                    tag = ACTIONSHEETTAGTWO;
                }
                else if (model.micType == CCUserMicStatus_Wait)
                {
                    //同意上麦
                    //禁言,取消
                    NSString *title = model.isMute ? @"解除禁言" : @"禁言";
//                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:drawtitle, @"同意上麦", title, @"踢出房间", nil];
//                    sheet.tag = ACTIONSHEETTAGTHTREE;
//                    [sheet showInView:view];
                    titleArray = @[drawtitle, @"同意上麦", title, @"踢出房间"];
                    tag = ACTIONSHEETTAGTHTREE;
                }
                else if (model.micType == CCUserMicStatus_Inviteing)
                {
                    //取消邀请 禁言 取消
                    NSString *title = model.isMute ? @"解除禁言" : @"禁言";
//                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:drawtitle, @"取消邀请", title, @"踢出房间", nil];
//                    sheet.tag = ACTIONSHEETTAGFOUR;
//                    [sheet showInView:view];
                    titleArray = @[drawtitle, @"取消邀请", title, @"踢出房间"];
                    tag = ACTIONSHEETTAGFOUR;
                }
            }
            else if (mode == CCClassType_Rotate)
            {
                //邀请上麦
                //禁言,取消
                NSString *title = model.isMute ? @"解除禁言" : @"禁言";
//                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:drawtitle, @"拉上麦", title, @"踢出房间", nil];
//                sheet.tag = ACTIONSHEETTAGSEVEN;
//                [sheet showInView:view];
                titleArray = @[drawtitle, @"拉上麦", title, @"踢出房间"];
                tag = ACTIONSHEETTAGSEVEN;
            }
        }
    }
    
    if (model.streamID)
    {
        for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
        {
            if ([user.user_id isEqualToString:model.userID])
            {
                NSString *assistant = user.user_AssistantState ? @"取消设为讲师" : @"设为讲师";
                NSMutableArray *titles = [NSMutableArray arrayWithArray:titleArray];
                [titles addObject:assistant];
                titleArray = [NSArray arrayWithArray:titles];
            }
        }
    }
    if (titleArray.count > 0)
    {
        [LCActionSheetConfig shared].buttonColor = CCRGBColor(242, 124, 25);
        [LCActionSheetConfig shared].cancleBtnColor = [UIColor blackColor];
        [LCActionSheetConfig shared].buttonFont = [UIFont systemFontOfSize:FontSizeClass_16];
        LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            buttonIndex--;
            [weakSelf actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        } otherButtonTitleArray:titleArray];
        actionSheet.tag = tag;
        actionSheet.scrolling          = YES;
        actionSheet.visibleButtonCount = 3.6f;
        [actionSheet show];
    }
}

- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //防止学生下线取数据失败或者错误
    CCMemberModel *nowModel = [self selectedModelIsOnLine];
    CCUser *user = [[CCStreamer sharedStreamer] getUSerInfoWithUserID:nowModel.userID];
    if (nowModel)
    {
        CCMemberModel *model = self.showModel;
        if (actionSheet.tag == ACTIONSHEETTAGONE)
        {
            if (buttonIndex == 0)
            {
                for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            [[CCStreamer sharedStreamer] cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            [[CCStreamer sharedStreamer] authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == 1)
            {
                if (nowModel.micType == CCUserMicStatus_Connected || nowModel.micType == CCUserMicStatus_Connecting)
                {
                    [[CCStreamer sharedStreamer] kickUserFromLianmai:model.userID completion:^(BOOL result, NSError *error, id info) {
                        if (result)
                        {
                            NSLog(@"kickUser:%@ success", model.userID);
                        }
                        else
                        {
                            NSLog(@"kickUser Fail:%@", error);
                        }
                    }];
                }
                else
                {
                    //学生已不在麦上
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经下麦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [view show];
                }
            }
            else if(buttonIndex == 2)
            {
                if (model.isMute)
                {
                    [[CCStreamer sharedStreamer] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] gagUser:model.userID];
                }
            }
            else if (buttonIndex == 3)
            {
                [[CCStreamer sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == 4)
            {
                if (user.user_AssistantState)
                {
                    [[CCStreamer sharedStreamer] cancleAuthUserAssistant:nowModel.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] authUserAssistant:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGTWO)
        {
            if (buttonIndex == 0)
            {
                for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            [[CCStreamer sharedStreamer] cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            [[CCStreamer sharedStreamer] authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == 1)
            {
                if (nowModel.micType == CCUserMicStatus_None)
                {
                    [[CCStreamer sharedStreamer] inviteUserLianMai:model.userID completion:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                        if (!result)
                        {
                            [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                
                            }];
                        }
                    }];
                }
                else
                {
                    [[CCStreamer sharedStreamer] certainHandup:model.userID completion:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                        if (!result)
                        {
                            [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                
                            }];
                        }
                    }];
                }
            }
            else if (buttonIndex == 2)
            {
                if (model.isMute)
                {
                    [[CCStreamer sharedStreamer] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] gagUser:model.userID];
                }
            }
            else if (buttonIndex == 3)
            {
                [[CCStreamer sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == 4)
            {
                if (user.user_AssistantState)
                {
                    [[CCStreamer sharedStreamer] cancleAuthUserAssistant:nowModel.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] authUserAssistant:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGTHTREE)
        {
            if (buttonIndex == 0)
            {
                for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            [[CCStreamer sharedStreamer] cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            [[CCStreamer sharedStreamer] authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == 1)
            {
                if (nowModel.micType == CCUserMicStatus_Wait)
                {
                    [[CCStreamer sharedStreamer] certainHandup:model.userID completion:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                        if (!result)
                        {
                            [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                
                            }];
                        }
                    }];
                }
                else
                {
                    //学生已取消举手
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经取消排麦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [view show];
                }
            }
            else if (buttonIndex == 2)
            {
                if (model.isMute)
                {
                    [[CCStreamer sharedStreamer] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] gagUser:model.userID];
                }
            }
            else if (buttonIndex == 3)
            {
                [[CCStreamer sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == 4)
            {
                if (user.user_AssistantState)
                {
                    [[CCStreamer sharedStreamer] cancleAuthUserAssistant:nowModel.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] authUserAssistant:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGFOUR)
        {
            if (buttonIndex == 0)
            {
                for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            [[CCStreamer sharedStreamer] cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            [[CCStreamer sharedStreamer] authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == 1)
            {
                if (nowModel.micType == CCUserMicStatus_Inviteing)
                {
                    [[CCStreamer sharedStreamer] cancleInviteUserLianMai:model.userID completion:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                    }];
                }
                else
                {
                    //学生已经不是邀请中
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经不是邀请中" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [view show];
                }
            }
            else if (buttonIndex == 2)
            {
                if (model.isMute)
                {
                    [[CCStreamer sharedStreamer] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] gagUser:model.userID];
                }
            }
            else if (buttonIndex == 3)
            {
                [[CCStreamer sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == 4)
            {
                if (user.user_AssistantState)
                {
                    [[CCStreamer sharedStreamer] cancleAuthUserAssistant:nowModel.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] authUserAssistant:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGFIVE)
        {
            if (buttonIndex == 0)
            {
                for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            [[CCStreamer sharedStreamer] cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            [[CCStreamer sharedStreamer] authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == 1)
            {
                BOOL mute = [[CCStreamer sharedStreamer] getAudienceChatStatus:model.userID];
                if (mute)
                {
                    [[CCStreamer sharedStreamer] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] gagUser:model.userID];
                }
            }
            else if (buttonIndex == 2)
            {
                [[CCStreamer sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == 3)
            {
                if (user.user_AssistantState)
                {
                    [[CCStreamer sharedStreamer] cancleAuthUserAssistant:nowModel.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] authUserAssistant:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGSIX)
        {
            if (buttonIndex == 0)
            {
                BOOL mute = [[CCStreamer sharedStreamer] getAudienceChatStatus:model.userID];
                if (mute)
                {
                    [[CCStreamer sharedStreamer] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] gagUser:model.userID];
                }
            }
            else if (buttonIndex == 1)
            {
                [[CCStreamer sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == 2)
            {
                if (user.user_AssistantState)
                {
                    [[CCStreamer sharedStreamer] cancleAuthUserAssistant:nowModel.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] authUserAssistant:nowModel.userID];
                }
            }
        }
        else if (actionSheet.tag == ACTIONSHEETTAGSEVEN)
        {
            if (buttonIndex == 0)
            {
                for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
                {
                    if ([model.userID isEqualToString:user.user_id])
                    {
                        if (user.user_drawState)
                        {
                            [[CCStreamer sharedStreamer] cancleAuthUserDraw:user.user_id];
                        }
                        else
                        {
                            [[CCStreamer sharedStreamer] authUserDraw:user.user_id];
                        }
                    }
                }
            }
            else if (buttonIndex == 1)
            {
                [[CCStreamer sharedStreamer] certainHandup:model.userID completion:^(BOOL result, NSError *error, id info) {
                    NSLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
                    if (!result)
                    {
                        [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            
                        }];
                    }
                }];
            }
            else if (buttonIndex == 2)
            {
                if (model.isMute)
                {
                    [[CCStreamer sharedStreamer] recoveGagUser:model.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] gagUser:model.userID];
                }
            }
            else if (buttonIndex == 3)
            {
                [[CCStreamer sharedStreamer] kickUserFromRoom:model.userID];
            }
            else if (buttonIndex == 4)
            {
                if (user.user_AssistantState)
                {
                    [[CCStreamer sharedStreamer] cancleAuthUserAssistant:nowModel.userID];
                }
                else
                {
                    [[CCStreamer sharedStreamer] authUserAssistant:nowModel.userID];
                }
            }
        }
        
        if (block)
        {
            block(YES, nil);
        }
    }
    else
    {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经下线" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [view show];
    }
}

- (NSString *)getDrawTitleWithModel:(CCMemberModel *)model
{
    NSString *title = @"授权标注";
    for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
    {
        if ([user.user_id isEqualToString:model.userID])
        {
            title = user.user_drawState ? @"取消授权标注" : @"授权标注";
            break;
        }
    }
    return title;
}

- (CCMemberModel *)selectedModelIsOnLine
{
    NSArray *list = [[CCStreamer sharedStreamer] getRoomInfo].room_userList;
    for (CCUser *model in list)
    {
        if ([model.user_id isEqualToString:self.showModel.userID])
        {
            CCMemberModel *newModel = [[CCMemberModel alloc] initWithUser:model];
            return newModel;
        }
    }
    if (self.showModel.type == CCMemberType_Audience)
    {
        return self.showModel;
    }
    return nil;
}

- (CCMemberModel *)modelWithUserID:(NSString *)userID
{
    NSArray *list = [[CCStreamer sharedStreamer] getRoomInfo].room_userList;
    for (CCUser *model in list)
    {
        if ([model.user_id isEqualToString:userID])
        {
            CCMemberModel *newModel = [[CCMemberModel alloc] initWithUser:model];
            return newModel;
        }
    }
    CCMemberModel *model = [[CCMemberModel alloc] init];
    model.type = CCMemberType_Audience;
    model.userID = userID;
    return model;
}
@end
