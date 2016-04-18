//
//  CollectionViewCell.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/17/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *playTitle;
@property (nonatomic, weak) IBOutlet UIImageView *playThumb;
@property (nonatomic, weak) IBOutlet UIButton *deleteIcon;
@property (nonatomic, weak) IBOutlet UIButton *duplicateIcon;
@end
