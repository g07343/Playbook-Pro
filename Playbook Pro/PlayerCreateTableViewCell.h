//
//  PlayerCreateTableViewCell.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/29/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCreateTableViewCell : UITableViewCell
{
    NSString *nameString;
    NSString *positionString;
    UIImage *playerImage;
}

@property (nonatomic, strong) IBOutlet UILabel *playerName;
@property (nonatomic, strong) IBOutlet UILabel *playerPosition;
@property (nonatomic, strong) IBOutlet UIImageView *playerImageHolder;
@property (nonatomic, strong) IBOutlet UIView *overlayView;
@end
