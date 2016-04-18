//
//  PlaySelectionViewController.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/17/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaunchViewController.h"

@interface PlaySelectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIView *tutorialView;
    IBOutlet UIButton *tutorialDone;
}
@property (nonatomic, weak) NSString *buttonChosen;
@property (nonatomic, weak) IBOutlet UICollectionView *playCollection;
@property (nonatomic, strong) IBOutlet UIView *printView;
@property (nonatomic, strong) IBOutlet UIView *selectionView;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) LaunchViewController *launchView;
@property (nonatomic, weak) NSString *chosenBook;

-(void)resetDelete:(NSIndexPath *)indexPath;
-(void)deletePlay:(UIImageView *)imageView;
-(IBAction)printPlays:(id)sender;
-(void)doneSelecting;
-(void)loadRemote:(NSArray*)remotePlay;
-(IBAction)tutorialDone:(id)sender;
@end
