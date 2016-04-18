//
//  PlaySettingsViewController.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/20/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "PlaySettingsViewController.h"
#import "SWRevealViewController.h"
#import "PlayCreationViewController.h"
#import "PlayLoader.h"

@interface PlaySettingsViewController ()

@end

@implementation PlaySettingsViewController

UINavigationController *frontNavigationController;
PlayCreationViewController *playView;
UIPrintInteractionController *printController;
NSString *play1Name;
NSString *play2Name;
NSString *play3Name;
NSString *opposingPlay1Name;
NSString *opposingPlay2Name;
NSString *opposingPlay3Name;
NSMutableArray *playCoords;
PlayLoader *loader;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.playName setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    frontNavigationController = (UINavigationController *) self.revealViewController.frontViewController;
    if (frontNavigationController != nil) {
        if ([frontNavigationController.topViewController isKindOfClass:[PlayCreationViewController class]]) {
             playView = (PlayCreationViewController *) frontNavigationController.topViewController;
            [playView resetBackButton];
            [playView drawerToggled];
        }
    }
    
    [self.playName resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    frontNavigationController = (UINavigationController *) self.revealViewController.frontViewController;
    if (frontNavigationController != nil) {
        if ([frontNavigationController.topViewController isKindOfClass:[PlayCreationViewController class]]) {
            playView = (PlayCreationViewController *) frontNavigationController.topViewController;
            [playView hideBackButton];
            [playView drawerToggled];
            [playView cancelSelection];
        }
    }
    
    if (playView) {
        _playName.text = playView.navigationItem.title;
        NSString *playType = [playView getPlayType];
        [self setUpTiles:playType];
    }
    loader = [[PlayLoader alloc] init];
    
    //set up our autosave switch to toggle the autosave functionality
    [_autoSaveSwitch addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
}

//method to make our 'rename' field focused/active
-(void)renameActive {
    [self.playName becomeFirstResponder];
}

//method called when the user toggles the auto save switch
-(void)switched:(id)sender {
    BOOL state = [sender isOn];
    NSString *isOn = state == YES ? @"YES" : @"NO";
    if ([isOn isEqual:@"YES"]) {
        //enable autosave timer in the play creation controller
        UIAlertView *autoSaveAlert = [[UIAlertView alloc] initWithTitle:@"Enable AutoSave?" message:@"Autosave will save your current play for you every 30 seconds.  Any prior data will be overwritten automatically, and resetting the play will restore to the last save point.  Enable? " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enable", nil];
        autoSaveAlert.tag = 3;
        [autoSaveAlert show];
    } else {
        //disable autosave timer in the play creation controller
        [playView disableAutoSave];
    }
}

//called whenever the user finishes editing the play name, so update the 'front' view controller
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Finished editing text field");
    if (frontNavigationController != nil) {
        if (playView != nil) {
            [playView updatePlayTitle:self.playName.text];
        }
    }
}

//this method lets us end editing on the Play name text field when the user taps the 'done' button
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.playName resignFirstResponder];
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

void (^printCompletion)(UIPrintInteractionController *, BOOL, NSError *) =
^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
    if (!completed && error) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error."
                                                     message:[NSString stringWithFormat:@"An error occured while printing: %@", error]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
        
        [av show];
        
    }
};

//this method handles all of the possible button taps within the settings menu
-(IBAction)onClick:(id)sender {
    UIButton *button = (UIButton *) sender;
    
    switch (button.tag) {
        case 0:
            //grass bg selected
            [playView updateTheme:@"grass"];
            break;
        case 1:
            //chalkboard bg selected
            [playView updateTheme:@"chalk"];
            break;
        case 2:
            //whiteboard bg selected
            [playView updateTheme:@"white"];
            break;
        case 3:
            //default play 1 selected
            playCoords = [loader setUp:play1Name editor:playView];
            [playView setLayoutSelected:play1Name];
            [playView applyFormation:playCoords];
            break;
        case 4:
            //default play 2 selected
            playCoords = [loader setUp:play2Name editor:playView];
            [playView setLayoutSelected:play2Name];
            [playView applyFormation:playCoords];
            break;
        case 5:
            //default play 3 selected
            playCoords = [loader setUp:play3Name editor:playView];
            [playView setLayoutSelected:play3Name];
            [playView applyFormation:playCoords];
            break;
        case 6: {
            //print play selected
            UIImage *playImage = [playView getPlaySnapshot];
            Class printControllerClass = NSClassFromString(@"UIPrintInteractionController");
            if (printControllerClass) {
                printController = [printControllerClass sharedPrintController];
                UIPrintInfo *printInfo = [UIPrintInfo printInfo];
                printInfo.outputType = UIPrintInfoOutputGeneral;
                
                printInfo.jobName = [NSString stringWithFormat:@"Print play"];
                printController.printInfo = printInfo;
                
                
                printController.printingItem = playImage;
                [printController presentFromRect:button.frame inView:self.view animated:YES completionHandler:printCompletion]; 
            }
        }
            break;
        case 7:{
            //reset play selected - alert user
            UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:@"Reset Play?" message:@"Reset the current play to it's last saved configuration?  This CANNOT be undone!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
            resetAlert.tag = 2;
            [resetAlert show];
        }
            
            break;
        case 8:
            //default play 1 selected
            playCoords = [loader setUp:opposingPlay1Name editor:playView];
            [playView applyOpposingFormation:playCoords];
            break;
            
        case 9:
            //default play 1 selected
            playCoords = [loader setUp:opposingPlay2Name editor:playView];
            [playView applyOpposingFormation:playCoords];
            break;
            
        case 10:
            //default play 1 selected
            playCoords = [loader setUp:opposingPlay3Name editor:playView];
            [playView applyOpposingFormation:playCoords];
            break;
    }
}

-(void)setUpTiles:(NSString*)playType {
    if ([playType isEqual:@"offense"]) {
        [_play1Button setBackgroundImage:[UIImage imageNamed:@"t_formation_tile.png"]  forState:UIControlStateNormal];
        [_play2Button setBackgroundImage:[UIImage imageNamed:@"i_formation_tile.png"]  forState:UIControlStateNormal];
        [_play3Button setBackgroundImage:[UIImage imageNamed:@"spread_formation_tile.png"]  forState:UIControlStateNormal];
        play1Name = @"offense_t";
        play2Name = @"offense_i";
        play3Name = @"offense_spread";
        
        [_opposingPlay1Button setBackgroundImage:[UIImage imageNamed:@"4_3_opposing_tile.png"] forState:UIControlStateNormal];
        [_opposingPlay2Button setBackgroundImage:[UIImage imageNamed:@"3_4_opposing_tile.png"] forState:UIControlStateNormal];
        [_opposingPlay3Button setBackgroundImage:[UIImage imageNamed:@"46_opposing_tile.png"] forState:UIControlStateNormal];
        
        opposingPlay1Name = @"opposing_4-3";
        opposingPlay2Name = @"opposing_3-4";
        opposingPlay3Name = @"opposing_46";
        
    } else {
        [_play1Button setBackgroundImage:[UIImage imageNamed:@"4_3_tile.png"]  forState:UIControlStateNormal];
        [_play2Button setBackgroundImage:[UIImage imageNamed:@"3_4_tile.png"]  forState:UIControlStateNormal];
        [_play3Button setBackgroundImage:[UIImage imageNamed:@"46_tile.png"]  forState:UIControlStateNormal];
        play1Name = @"defense_4-3";
        play2Name = @"defense_3-4";
        play3Name = @"defense_46";
        
        [_opposingPlay1Button setBackgroundImage:[UIImage imageNamed:@"t_opposing_formation_tile.png"] forState:UIControlStateNormal];
        [_opposingPlay2Button setBackgroundImage:[UIImage imageNamed:@"i_opposing_formation_tile.png"] forState:UIControlStateNormal];
        [_opposingPlay3Button setBackgroundImage:[UIImage imageNamed:@"spread_opposing_formation_tile.png"] forState:UIControlStateNormal];
        
        opposingPlay1Name = @"opposing_t";
        opposingPlay2Name = @"opposing_i";
        opposingPlay3Name = @"opposing_spread";
    }

}

//called by PlayCreationController, this sets up default positions for a 'new' play
-(void)setDefaultPositions:(NSString*)playType {
    loader = [[PlayLoader alloc] init];
    
    //need to ensure we have all of the required values for our different positions created
    [self setUpTiles:playType];
    
    frontNavigationController = (UINavigationController *) self.revealViewController.frontViewController;
    if (frontNavigationController != nil) {
        if ([frontNavigationController.topViewController isKindOfClass:[PlayCreationViewController class]]) {
            playView = (PlayCreationViewController *) frontNavigationController.topViewController;
        }
    }
    
    if ([playType  isEqual: @"offense"]) {
        playCoords = [loader setUp:play2Name editor:playView];
        [playView setLayoutSelected:play2Name];
        [playView applyFormation:playCoords];
    } else {
        playCoords = [loader setUp:play1Name editor:playView];
        [playView setLayoutSelected:play1Name];
        [playView applyFormation:playCoords];
    }
    //first apply the first default layout for user's players...
    
    
    //then apply the first default layout for the opposing players
    playCoords = [loader setUp:opposingPlay1Name editor:playView];
    [playView applyOpposingFormation:playCoords];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            //user chose to reset the play to the last saved configuration
            [playView resetPlay];
        }
    } else if (alertView.tag == 3) {
        //autosave alert
        if (buttonIndex == 1) {
            //user chose to enable autosave
            [playView enableAutoSave];
        } else {
            [_autoSaveSwitch setOn:NO animated:YES];
        }
    }
}

-(IBAction)helpTapped:(id)sender {
    [playView drawerToggled];
    [playView.revealViewController revealToggle:self];
    [playView startTutorial];
}

@end
