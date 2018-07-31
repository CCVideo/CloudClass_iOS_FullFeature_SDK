//
//  CCRoomDescEditViewController.m
//  CCClassRoom
//
//  Created by cc on 17/3/29.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCRoomDescEditViewController.h"
#import <Masonry.h>
#import <CCClassRoom/CCClassRoom.h>
#import <BlocksKit+UIKit.h>
#import "LoadingView.h"

#define MAX_LIMIT_NUMS     200

@interface CCRoomDescEditViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *roomDescTextView;
@property (strong, nonatomic) UILabel *numLabel;
@property(nonatomic,strong)LoadingView          *loadingView;

@end

@implementation CCRoomDescEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=NO;
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = right;
    
    self.roomDescTextView.delegate = self;
    self.numLabel = [UILabel new];
    [self.view addSubview:self.numLabel];
    __weak typeof(self) weakSelf = self;
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.roomDescTextView.mas_bottom).offset(0.f);
        make.right.mas_equalTo(weakSelf.view).offset(0.f);
    }];
    
    NSString *roomDesc = GetFromUserDefaults(LIVE_ROOMDESC);
    self.roomDescTextView.text = roomDesc;
    [self textViewDidChange:self.roomDescTextView];
}

//点击返回按钮
- (void)save
{
    if (self.roomDescTextView.text.length == 0)
    {
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"房间介绍不能为空" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:nil];
    }
    else
    {
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在保存"];
        [self.view addSubview:_loadingView];
        [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        __weak typeof(self) weakSelf = self;
        [[CCStreamer sharedStreamer] changeRoomDetail:self.roomDescTextView.text completion:^(BOOL result, NSError *error, id info) {
            [weakSelf.loadingView removeFromSuperview];
            weakSelf.loadingView = nil;
            if (result)
            {
                SaveToUserDefaults(LIVE_ROOMDESC, self.roomDescTextView.text);
                self.navigationItem.leftBarButtonItem.enabled = NO;
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:nil];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_LIMIT_NUMS) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx++;
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            //既然是超出部分截取了，哪一定是最大限制了。
            self.numLabel.text = [NSString stringWithFormat:@"%d/%ld",0,(long)MAX_LIMIT_NUMS];
        }
        return NO;
    }
    
}

+(int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

- (void)textViewDidChange:(UITextView *)textView
{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    existTextNum = [CCRoomDescEditViewController convertToInt:nsTextContent];
    
    if (existTextNum > MAX_LIMIT_NUMS)
    {
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        for (int i = 1; i < nsTextContent.length; i++)
        {
            NSString *str = [nsTextContent substringToIndex:nsTextContent.length - i];
            int length = [CCRoomDescEditViewController convertToInt:str];
            if (length <= MAX_LIMIT_NUMS)
            {
                textView.text = str;
                break;
            }
        }
    }
    
    //不让显示负数 口口日
    self.numLabel.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,MAX_LIMIT_NUMS - existTextNum),MAX_LIMIT_NUMS];
}
@end
