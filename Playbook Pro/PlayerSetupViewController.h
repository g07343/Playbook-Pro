//
//  PlayerSetupViewController.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/26/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerSetupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

{
    IBOutlet UIView *remainingView;
    IBOutlet UIButton *closeRemaining;
    IBOutlet UILabel *positionsLabel1;
    IBOutlet UILabel *positionsLabel2;
    IBOutlet UILabel *positionsLabel3;
    IBOutlet UILabel *positionsLabel4;
    IBOutlet UILabel *positionsLabel5;
    IBOutlet UILabel *positionsLabel6;
    IBOutlet UILabel *positionsLabel7;
    IBOutlet UILabel *positionsLabel8;
    IBOutlet UILabel *remainingHeader;
}

@property (nonatomic, strong) IBOutlet UITableView *offenseTable;
@property (nonatomic, strong) IBOutlet UITableView *defenseTable;
@property (nonatomic, strong) IBOutlet UITableView *specialTable;
@property (nonatomic, strong) IBOutlet UIView *addView;
@property (nonatomic, strong) IBOutlet UIPickerView *positionPicker;
@property (nonatomic, strong) IBOutlet UITextField *nameInput;
@property (nonatomic, strong) IBOutlet UIButton *addImageButton;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic) BOOL isModifying;

-(IBAction)onClick:(id)sender;
-(IBAction)closeRemaining:(id)sender;
@end
