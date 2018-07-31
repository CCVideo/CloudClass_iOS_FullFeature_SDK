//
//  CCStreamView.h
//  CCStreamer
//
//  Created by cc on 17/2/18.
//  Copyright © 2017年 cc. All rights reserved.
//

/*!
 
 @header CCStreamView.h
 
 @abstract 流视图
 
 @author Created by cc on 17/1/5.
 
 @version 1.00 17/1/5 Creation
 */

#import <UIKit/UIKit.h>
#import "CCStreamer.h"
/*!
 @class
 @abstract 流视图
 */
@interface CCStreamShowView : CCStreamView
/*!
 @property
 @abstract 该视图对应流的角色身份
 */
@property (assign, nonatomic, readonly) CCRole role;
/*!
 @property
 @abstract 该视图对应角色的名字
 */
@property (strong, nonatomic, readonly) NSString *name;
/*!
 @property
 @abstract 该视图对应用户ID
 */
@property (strong, nonatomic, readonly) NSString *userID;
@end
