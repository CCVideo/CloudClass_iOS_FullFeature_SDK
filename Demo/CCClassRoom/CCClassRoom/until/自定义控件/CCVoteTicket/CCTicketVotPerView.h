//
//  CCTicketVotPerView.h
//  CCClassRoom
//
//  Created by cc on 18/6/15.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  CCTicketVotPerViewDelegate;

@interface CCTicketVotPerView : UIView
#pragma mark strong
@property(nonatomic,weak)id<CCTicketVotPerViewDelegate> delegate;

#pragma mark assign
@property(nonatomic,assign)BOOL selected;

- (instancetype)initWithTitle:(NSString *)title;

@end

@protocol  CCTicketVotPerViewDelegate <NSObject>

- (void)CCTicketVotPerViewClicked:(CCTicketVotPerView *)sender;

@end
