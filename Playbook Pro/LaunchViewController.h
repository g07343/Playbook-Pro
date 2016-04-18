//
//  LaunchViewController.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/16/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface LaunchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate, ADBannerViewDelegate>
{
    IBOutlet UIButton *createNewBtn;
    IBOutlet UIButton *offenseBtn;
    IBOutlet UIButton *defenseBtn;
    IBOutlet UILabel *offenseCount;
    IBOutlet UILabel *defenseCount;
    IBOutlet UITableView *bookList;
    IBOutlet UIImageView *tableViewBackground;
    IBOutlet UIView *addNameView;
    IBOutlet UIButton *addNameButton;
    IBOutlet UIButton *addCancelButton;
    IBOutlet UITextField *addNameField;
    IBOutlet UIButton *backupBtn;
    IBOutlet UIView *passwordView;
    IBOutlet UITextField *passwordField;
    IBOutlet UIButton *passwordCancel;
    IBOutlet UIButton *passwordSave;
    IBOutlet UIView *backupSelectView;
    IBOutlet UIButton *backupSelectCancel;
    IBOutlet UIButton *backupSelectDone;
    IBOutlet UIView *restorePasswordView;
    IBOutlet UIButton *restorePasswordCancel;
    IBOutlet UIButton *restorePasswordSubmit;
    IBOutlet UITextField *restorePasswordField;
    IBOutlet UIView *restoringView;
    IBOutlet UIButton *helpButton;
    IBOutlet UIView *tutorialView;
    IBOutlet UIImageView *tutorialImageView;
    IBOutlet UISwitch *icloudSwitch;
    IBOutlet UIButton *rosterButton;
    IBOutlet UIView *copyView;
    IBOutlet UIButton *iCloudIntroButton;
    IBOutlet UIView *iCloudIntroView;
    IBOutlet UILabel *iCloudStatusLabel;
    IBOutlet UIButton *tutorialButton;
}

@property NSString *testString;
-(IBAction)onClick:(id)sender;
-(IBAction)backupClick:(id)sender;
-(IBAction)restoreClick:(id)sender;
-(void)restoreComplete;
-(void)reloadTable;
-(IBAction)helpTapped:(id)sender;
-(IBAction)tutorialDone:(id)sender;
-(void)resetContext;
-(void)showLoading;
-(void)copySelect:(NSString*)playName :(NSString*)bookName;
-(IBAction)cancelCopy:(id)sender;
@end
