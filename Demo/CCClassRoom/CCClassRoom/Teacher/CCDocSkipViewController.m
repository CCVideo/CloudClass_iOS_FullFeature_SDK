//
//  CCDocSkipViewController.m
//  CCClassRoom
//
//  Created by cc on 17/4/25.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocSkipViewController.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface CCDocSkipCollectionCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imageView;
- (void)reloadWith:(NSString *)url;
@end

@implementation CCDocSkipCollectionCell
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.imageView = [UIImageView new];
        [self addSubview:self.imageView];
        self.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.1];
        __weak typeof(self) weakSelf = self;
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
    }
    return self;
}

- (void)reloadWith:(NSString *)url
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url]];
}
@end

@interface CCDocSkipViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *data;
@end

#define TAG 20000
#define DEL 4.f

@implementation CCDocSkipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"跳转页面";
    [self initUI];
}

- (void)initUI
{
    _collectionView = ({
        
        float width = (self.view.frame.size.width - 5*DEL)/4.f;
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(width, width);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = DEL;
        layout.minimumInteritemSpacing = DEL;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,160) collectionViewLayout:layout];
        collectionView.backgroundColor = CCRGBColor(220, 220, 220);;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[CCDocSkipCollectionCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.contentInset = UIEdgeInsetsMake(DEL, DEL, DEL, DEL);
        collectionView;
    });
    [self.view addSubview:self.collectionView];
    __weak typeof(self) weakSelf = self;
    [_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view);
    }];
}

- (void)setDoc:(CCDoc *)doc
{
    _doc = doc;
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:self.doc.pageSize];
    for (int i = 0; i < self.doc.pageSize; i++)
    {
        NSString *url = [self.doc getPicUrl:i];
        [urls addObject:url];
    }
    self.data = [NSArray arrayWithArray:urls];
    [self.collectionView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CCDocSkipCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell reloadWith:self.data[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiDocSelectedPage object:nil userInfo:@{@"value":@(indexPath.item)}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
