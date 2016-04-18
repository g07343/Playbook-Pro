//
//  PlaySettingsViewController.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/20/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaySettingsViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField *playName;
@property (nonatomic, strong) IBOutlet UISwitch *autoSaveSwitch;
@property (nonatomic, strong) IBOutlet UIButton *grassButton;
@property (nonatomic, strong) IBOutlet UIButton *chalkButton;
@property (nonatomic, strong) IBOutlet UIButton *whiteButton;
@property (nonatomic, strong) IBOutlet UIButton *play1Button;
@property (nonatomic, strong) IBOutlet UIButton *play2Button;
@property (nonatomic, strong) IBOutlet UIButton *play3Button;
@property (nonatomic, strong) IBOutlet UIButton *opposingPlay1Button;
@property (nonatomic, strong) IBOutlet UIButton *opposingPlay2Button;
@property (nonatomic, strong) IBOutlet UIButton *opposingPlay3Button;
@property (nonatomic, strong) IBOutlet UIButton *printButton;
@property (nonatomic, strong) IBOutlet UIButton *resetButton;

-(IBAction)onClick:(id)sender;
-(IBAction)helpTapped:(id)sender;
-(void)renameActive;
-(void)setDefaultPositions:(NSString*)playType;
@end
