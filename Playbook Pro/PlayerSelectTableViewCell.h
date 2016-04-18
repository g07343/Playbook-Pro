//
//  PlayerSelectTableViewCell.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/25/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerSelectTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *playerImage;
@property (nonatomic, weak) IBOutlet UILabel *playerName;
@property (nonatomic, weak) IBOutlet UILabel *positionLabel;

@end
