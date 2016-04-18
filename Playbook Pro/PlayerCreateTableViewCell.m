//
//  PlayerCreateTableViewCell.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/29/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "PlayerCreateTableViewCell.h"

@implementation PlayerCreateTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [_playerImageHolder.layer setCornerRadius:8];
    _playerImageHolder.layer.masksToBounds = NO;
    _playerImageHolder.clipsToBounds = YES;
    [self setBackgroundColor:[UIColor clearColor]];
    [_playerImageHolder setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.4]];
    [_overlayView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
