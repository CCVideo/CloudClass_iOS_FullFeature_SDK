//
//  CCDocTableViewCell.m
//  CCClassRoom
//
//  Created by cc on 17/4/24.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation CCDocTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)reloadWithDoc:(CCDoc *)doc
{
    self.sizeLabel.hidden = YES;
    NSURL *url = [NSURL URLWithString:[doc getPicUrl:0]];
    self.iconImageView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.1];
    [self.iconImageView sd_setImageWithURL:url];
    self.nameLabel.text = doc.docName;
    float size = doc.size/1024.f/1024.f;
    size = floor(size*100);
    size = size/100.f;
    self.timeLabel.text = [NSString stringWithFormat:@"%@M", @(size)];
}

- (void)reloadWithInfo:(NSDictionary *)info
{
    NSString *imageName = [info objectForKey:@"image"];
    NSString *name = [info objectForKey:@"name"];
    self.iconImageView.image = [UIImage imageNamed:imageName];
    self.nameLabel.text = name;
    self.timeLabel.text = @" ";
}
@end
