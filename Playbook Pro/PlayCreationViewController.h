//
//  PlayCreationViewController.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/19/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerTokenViewController.h"

@interface PlayCreationViewController : UIViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    CGPoint lastPoint;
    CGFloat red;
    CGFloat blue;
    CGFloat black;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
}

@property (nonatomic) NSString *playType;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat brush;
@property (nonatomic) CGFloat opacity;
@property (nonatomic) BOOL eraserOn;
@property (nonatomic) BOOL mouseSwiped;
@property (nonatomic) BOOL createNew;
@property (nonatomic) BOOL isSettingUp;
@property (nonatomic) NSArray *remotePlayData;
@property (nonatomic, strong) NSString *layoutSelected;
@property (nonatomic, weak) IBOutlet UIImageView *drawingCanvas;
@property (nonatomic, weak) IBOutlet UIImageView *tempCanvas;
@property (nonatomic, weak) IBOutlet UIImageView *bgImage;
@property (nonatomic, weak) IBOutlet UIButton *redButton;
@property (nonatomic, weak) IBOutlet UIButton *blueButton;
@property (nonatomic, weak) IBOutlet UIButton *blackButton;
@property (nonatomic, weak) IBOutlet UIButton *eraserButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, weak) IBOutlet UITextField *nameField;

@property (nonatomic, weak) IBOutlet UIView *container1;
@property (nonatomic, weak) IBOutlet UIView *container2;
@property (nonatomic, weak) IBOutlet UIView *container3;
@property (nonatomic, weak) IBOutlet UIView *container4;
@property (nonatomic, weak) IBOutlet UIView *container5;
@property (nonatomic, weak) IBOutlet UIView *container6;
@property (nonatomic, weak) IBOutlet UIView *container7;
@property (nonatomic, weak) IBOutlet UIView *container8;
@property (nonatomic, weak) IBOutlet UIView *container9;
@property (nonatomic, weak) IBOutlet UIView *container10;
@property (nonatomic, weak) IBOutlet UIView *container11;
@property (nonatomic, weak) IBOutlet UIView *darkOverlay;
@property (nonatomic, weak) IBOutlet UIView *rosterHelper;

@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer1;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer2;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer3;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer4;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer5;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer6;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer7;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer8;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer9;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer10;
@property (nonatomic, weak) IBOutlet UIImageView *opposingPlayer11;

@property (nonatomic, weak) PlayerTokenViewController *player1;
@property (nonatomic, weak) PlayerTokenViewController *player2;
@property (nonatomic, weak) PlayerTokenViewController *player3;
@property (nonatomic, weak) PlayerTokenViewController *player4;
@property (nonatomic, weak) PlayerTokenViewController *player5;
@property (nonatomic, weak) PlayerTokenViewController *player6;
@property (nonatomic, weak) PlayerTokenViewController *player7;
@property (nonatomic, weak) PlayerTokenViewController *player8;
@property (nonatomic, weak) PlayerTokenViewController *player9;
@property (nonatomic, weak) PlayerTokenViewController *player10;
@property (nonatomic, weak) PlayerTokenViewController *player11;
@property (nonatomic, strong) PlayerTokenViewController *playerToSwap;
@property (nonatomic, strong) NSMutableArray *allContainers;
@property (nonatomic, strong) NSMutableArray *allViewControllers;



@property (nonatomic, weak) NSString *playChosenTitle;

-(IBAction)onClick:(id)sender;
-(void)resetBackButton;
-(void)hideBackButton;
-(void)updatePlayTitle:(NSString *)title;
-(void)updateTheme:(NSString *)name;
-(void)drawerToggled;
-(void)swapPlayers:(NSString*)type;
-(void)disableDrawing;
-(NSString*)getPlayType;
-(void)cancelSelection;
-(UIImage*)getPlaySnapshot;
-(void)resetPlay;
-(void)applyFormation:(NSMutableArray*)coords;
-(void)applyOpposingFormation:(NSMutableArray*)coords;
-(void)enableAutoSave;
-(void)disableAutoSave;
-(void)startTutorial;

@end
