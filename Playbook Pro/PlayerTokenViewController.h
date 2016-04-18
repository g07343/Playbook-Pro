//
//  PlayerTokenViewController.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/23/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerTokenViewController : UIViewController 

@property(nonatomic, weak) IBOutlet UIImageView *playerPicture;
@property(nonatomic, weak) IBOutlet UILabel *nameHolder;

@property(nonatomic, weak) UIImage *imageFile;
@property(nonatomic, weak) NSString *playerName;
@property(nonatomic) int xPosition;
@property(nonatomic) int yPosition;
@property(nonatomic) int viewWidth;
@property(nonatomic) int viewHeight;
@property(nonatomic, strong) NSString *position;
@property(nonatomic) BOOL isUtility;

-(void)setName:(NSString *)name;
-(void)setPosition:(NSString *)passedString;
-(void)setImage:(UIImage *)image;
-(void)viewSelected;
-(void)updateView;
@end
