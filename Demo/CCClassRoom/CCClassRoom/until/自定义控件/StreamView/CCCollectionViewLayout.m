//
//  LXMExpandLayout.m
//  LXMExpandLayoutDemo
//
//  Created by luxiaoming on 15/5/27.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import "CCCollectionViewLayout.h"

@implementation CCCollectionViewLayout
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if ([self.collectionView numberOfItemsInSection:0] == 0)
    {
        return nil;
    }
    
    //修改每个item的UICollectionViewLayoutAttributes
    CGRect newRect = rect;
    newRect.origin.y = newRect.origin.y - CGRectGetHeight(self.collectionView.bounds);
    newRect.size.height += CGRectGetHeight(self.collectionView.bounds) * 2;
    NSArray *originalArray = [super layoutAttributesForElementsInRect:newRect];//因为要改变item的大小，会导致rect比默认的rect要大，所以这里要相应扩大计算范围，否则会出现显示不全的问题
    
    NSInteger countInLine = 1;
    CGFloat width;
    CGFloat height;
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    if (itemCount <= 1)
    {
        countInLine = 1;
    }
    else if (itemCount <= 4)
    {
        countInLine = 2;
    }
    else if (itemCount <= 9)
    {
        countInLine = 3;
    }
    else if (itemCount <= 16)
    {
        countInLine = 4;
    }
    else if (itemCount <= 25)
    {
        countInLine = 5;
    }
    else if (itemCount <= 36)
    {
        countInLine = 6;
    }
    else if (itemCount <= 49)
    {
        countInLine = 7;
    }
    
    NSLog(@"%@___%ld", NSStringFromCGRect(self.collectionView.frame), (long)itemCount);
    width = self.collectionView.frame.size.width/countInLine;
    height = self.collectionView.frame.size.height/countInLine;
    
    for (UICollectionViewLayoutAttributes *attributes in originalArray)
    {
        NSInteger lineCount = attributes.indexPath.item/countInLine;//第几行
        NSInteger numCount = attributes.indexPath.item%countInLine;//第几个
        attributes.frame = CGRectMake(numCount*width, lineCount*height, width, height);
    }
    return originalArray;
}
@end
