//
//  PlayerSetupViewController.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/26/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "PlayerSetupViewController.h"
#import "PlayerCreateTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Player.h"
#import "AppDelegate.h"

@interface PlayerSetupViewController ()

@end

@implementation PlayerSetupViewController
@synthesize offenseTable, defenseTable, addView, positionPicker, specialTable, isModifying;

NSMutableArray *offenseNames;
NSMutableArray *offensePositions;
NSMutableArray *offenseImages;

NSMutableArray *defenseNames;
NSMutableArray *defensePositions;
NSMutableArray *defenseImages;

NSMutableArray *specialNames;
NSMutableArray *specialPositions;
NSMutableArray *specialImages;

NSMutableArray *selectablePositions;
NSString *selectedType;
NSString *selectedPosition;
UIImagePickerController *imagePickerController;

NSMutableArray *offenseRemaining;
NSMutableArray *defenseRemaining;
NSArray *allPlayers;
NSManagedObjectContext *context;
AppDelegate *app;
UIView *tutorialView;
UIButton *tutorialDone;
UIButton *helpButton;
BOOL initialSetup;
BOOL isSelectingOldPlayer;
BOOL takingPicture;

//everything needed to allow the user to edit an already created player
BOOL editMode;
int editIndex;
NSString *editType;
int offenseRemainingCount;
int defenseRemainingCount;
UIBarButtonItem *doneButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (isModifying == false) {
        initialSetup = false;
    }
    takingPicture = false;
    
    //need to manually make a save button to be more apparent the default provided ios bar button item
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 60, 30);
    [saveBtn setTitle:@"Done" forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"Button_Bg.png"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(doneEditing) forControlEvents:UIControlEventTouchUpInside];
    
    doneButton = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    //UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                //target:self
                                                                                //action:@selector(doneEditing)];
    //set a background to make the button more apparent
    [doneButton setBackButtonBackgroundImage:[UIImage imageNamed:@"Button_Bg.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.frame = CGRectMake(0, 0, 30, 30);
    [helpButton addTarget:self action:@selector(startTutorial) forControlEvents:UIControlEventTouchUpInside];
    [helpButton setImage:[UIImage imageNamed:@"help_btn.png"] forState:UIControlStateNormal];
    UIBarButtonItem *helpItem = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
    NSArray *navItems = [[NSArray alloc] initWithObjects:doneButton,helpItem, nil];
    [[self navigationItem] setRightBarButtonItems:navItems];
    
    
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.navigationItem setTitle:@"Roster Setup"];
    
    //hide our back button by default until the user has setup the minimum number of players
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    //register our custom tableview cell for both tableviews
    UINib *customCell = [UINib nibWithNibName:@"PlayerCreateTableViewCell" bundle:nil];
    if (customCell != nil) {
        [offenseTable registerNib:customCell forCellReuseIdentifier:@"playerCell"];
        [defenseTable registerNib:customCell forCellReuseIdentifier:@"playerCell"];
        [specialTable registerNib:customCell forCellReuseIdentifier:@"playerCell"];
    }
    
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    context = app.managedObjectContext;
    
    //set our custom rowheight for both table views to fit our custom cell
    defenseTable.rowHeight = 121;
    offenseTable.rowHeight = 121;
    specialTable.rowHeight = 121;
    
    specialTable.hidden = YES;
    
    if (isModifying == false) {
        //init our custom mutable arrays for both table views to keep all data in sync during creation
        //offenseNames = [[NSMutableArray alloc] initWithObjects:@"Add Player", nil];
        offenseNames = [[NSMutableArray alloc] initWithObjects:@"Add Player", @"Offense Player1",@"Offense Player2",@"Offense Player3",@"Offense Player4",@"Offense Player5",@"Offense Player6",@"Offense Player7",@"Offense Player8",@"Offense Player9",@"Offense Player10",@"Offense Player11",@"Offense Player12", nil];
        //offensePositions = [[NSMutableArray alloc] initWithObjects:@"blank", nil];
        offensePositions = [[NSMutableArray alloc] initWithObjects:@"blank", @"Center", @"Offensive Guard", @"Offensive Guard", @"Offensive Tackle", @"Offensive Tackle", @"Tight End", @"Wide Receiver", @"Wide Receiver", @"Running Back", @"Running Back", @"Quarterback", @"Punter", nil];
        UIImage *addImage = [UIImage imageNamed:@"silhouette_add.png"];
        UIImage *silhouette = [UIImage imageNamed:@"player_silhouette.png"];
        //offenseImages = [[NSMutableArray alloc] initWithObjects:addImage, nil];
        offenseImages = [[NSMutableArray alloc] initWithObjects:addImage, silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette, nil];
        
        //defenseNames = [[NSMutableArray alloc] initWithObjects:@"Add Player", nil];
        defenseNames = [[NSMutableArray alloc] initWithObjects:@"Add Player", @"Defense Player1", @"Defense Player2", @"Defense Player3", @"Defense Player4", @"Defense Player5", @"Defense Player6", @"Defense Player7", @"Defense Player8", @"Defense Player9", @"Defense Player10", @"Defense Player11", nil];
        //defensePositions = [[NSMutableArray alloc] initWithObjects:@"blank", nil];
        defensePositions = [[NSMutableArray alloc] initWithObjects:@"blank", @"Defensive Tackle", @"Defensive Tackle", @"Defensive End", @"Defensive End", @"Middle Linebacker", @"Outside Linebacker", @"Outside Linebacker", @"Cornerback", @"Cornerback", @"Safety", @"Safety", nil];
        //defenseImages = [[NSMutableArray alloc] initWithObjects:addImage, nil];
        defenseImages = [[NSMutableArray alloc] initWithObjects:addImage, silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette,silhouette, nil];
        
        specialNames = [[NSMutableArray alloc] initWithObjects:@"Add Player", nil];
        specialPositions = [[NSMutableArray alloc] initWithObjects:@"blank", nil];
        specialImages = [[NSMutableArray alloc] initWithObjects:addImage, nil];
    } else {
        //load in the user's players since they already exist
        [self setUpPlayers];
    }
    
    
    
    //hide the addView overlay by default
    addView.hidden = YES;
    addView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    //set a default for our selectedType(and UIPicker values), which changes depending upon which type of player the user wants to create
    selectedType = @"offense";
    selectablePositions = [[NSMutableArray alloc] initWithObjects:@"Choose Position",@"Center",@"Offensive Guard",@"Offensive Tackle",@"Tight End", @"Wide Receiver", @"Running Back",@"Quarterback",@"Punter", nil];
    
    //set our view controller to handle when the user closes the keyboard, in the event they are updating a player's name
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _nameInput.delegate = self;
    
    positionPicker.delegate = self;
    
    [offenseTable setBackgroundColor:[UIColor clearColor]];
    [defenseTable setBackgroundColor:[UIColor clearColor]];
    [specialTable setBackgroundColor:[UIColor clearColor]];
    
    //[addView.layer setCornerRadius:8];
    //[addView.layer setMasksToBounds:YES];
    addView.layer.cornerRadius = 8;
    addView.layer.masksToBounds = YES;
    
    //set initial bool for editing to false, which corresponds to whether the user has opened a player for editing in the form
    editMode = false;
    
    
}
//special, offense, defense
-(void)setUpPlayers {
    //grab all offense players
    NSFetchRequest *playerFetch = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
    NSError *playerError;
    NSArray *allPlayers = [context executeFetchRequest:playerFetch error:&playerError];
    
    offenseNames = [[NSMutableArray alloc] initWithObjects:@"Add Player", nil];
    defenseNames = [[NSMutableArray alloc] initWithObjects:@"Add Player", nil];
    specialNames = [[NSMutableArray alloc] initWithObjects:@"Add Player", nil];
    
    offensePositions = [[NSMutableArray alloc] initWithObjects:@"blank", nil];
    defensePositions = [[NSMutableArray alloc] initWithObjects:@"blank", nil];
    specialPositions = [[NSMutableArray alloc] initWithObjects:@"blank", nil];
    
    UIImage *addImage = [UIImage imageNamed:@"silhouette_add.png"];
    offenseImages = [[NSMutableArray alloc] initWithObjects:addImage, nil];
    defenseImages = [[NSMutableArray alloc] initWithObjects:addImage, nil];
    specialImages = [[NSMutableArray alloc] initWithObjects:addImage, nil];
    
    //loop through all of the user's player and assign their values to the correct arrays
    for (Player *player in allPlayers) {
        if ([player.team isEqualToString:@"offense"]) {
            [offenseNames addObject:player.name];
            [offensePositions addObject:player.position];
            UIImage *playerImage = [UIImage imageWithData:player.image];
            [offenseImages addObject:playerImage];
        } else if ([player.team isEqualToString:@"defense"]) {
            [defenseNames addObject:player.name];
            [defensePositions addObject:player.position];
            UIImage *playerImage = [UIImage imageWithData:player.image];
            [defenseImages addObject:playerImage];
        } else if ([player.team isEqualToString:@"special"]) {
            [specialNames addObject:player.name];
            [specialPositions addObject:player.position];
            UIImage *playerImage = [UIImage imageWithData:player.image];
            [specialImages addObject:playerImage];
        }
    }
}

-(void)startTutorial {
    CGRect tutorialFrame = CGRectMake([[UIApplication sharedApplication] delegate].window.frame.origin.x, [[UIApplication sharedApplication] delegate].window.frame.origin.y, [[UIApplication sharedApplication] delegate].window.frame.size.width, [[UIApplication sharedApplication] delegate].window.frame.size.height);
    
    tutorialView = [[UIView alloc] initWithFrame:tutorialFrame];
    
    UIImageView *tutorialImageView = [[UIImageView alloc] initWithFrame:tutorialFrame];
    [tutorialImageView setImage:[UIImage imageNamed:@"roster_setup.png"]];
    
    tutorialDone = [[UIButton alloc] initWithFrame:CGRectMake(900, 600, 100, 70)];
    [tutorialDone setTitle:@"Got It!" forState:UIControlStateNormal];
    tutorialDone.titleLabel.font = [UIFont boldSystemFontOfSize:32];
    [tutorialDone setTitleColor:[UIColor colorWithRed:0.137 green:0.51 blue:0.902 alpha:1] forState:UIControlStateNormal];
    [tutorialDone setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [tutorialDone addTarget:self action:@selector(tutorialFinish:) forControlEvents:UIControlEventTouchUpInside];
    [tutorialView addSubview:tutorialImageView];
    [tutorialView addSubview:tutorialDone];
    [[[UIApplication sharedApplication] delegate].window addSubview:tutorialView];
}

-(IBAction)tutorialFinish:(id)sender {
    [tutorialView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"rosterSetupTutorialComplete"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)viewWillAppear:(BOOL)animated {
    BOOL tutorialComplete = [[NSUserDefaults standardUserDefaults] boolForKey:@"rosterSetupTutorialComplete"];
    if (!(tutorialComplete)) {
        [self startTutorial];
    }
    remainingView.hidden = YES;
    
    if (isModifying) {
        initialSetup = false;
        NSLog(@"User is modifying their already-created roster!");
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    //need to ensure we are only resetting the isModifying BOOL when NOT presenting the image picker controller
    if (takingPicture == false) {
        isModifying = false;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//hide status bar manually
- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//number of cells to display in the tableviews
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == offenseTable) {
        return offenseNames.count;
    } else if (tableView == defenseTable) {
        return defenseNames.count;
    } else if (tableView == specialTable) {
        return specialNames.count;
    }
    return 0;
}

//creation and reuse of cell objects for both tableviews
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCreateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell"];
    
    //figure out which table view is requesting cell, and then hook up appropriate data arrays
    if (tableView == offenseTable) {
        cell.playerName.text = offenseNames[indexPath.row];
        cell.playerPosition.text = offensePositions[indexPath.row];
        //if the first indexpath, don't show the position lable since it serves no purpose here
        if ([offenseNames[indexPath.row] isEqual:@"Add Player"]) {
            //cell.playerPosition.hidden = YES;
            cell.playerPosition.text = @"";
        }
        cell.playerImageHolder.image = offenseImages[indexPath.row];
    } else if (tableView == defenseTable) {
        cell.playerName.text = defenseNames[indexPath.row];
        cell.playerPosition.text = defensePositions[indexPath.row];
        //if the first indexpath, don't show the position lable since it serves no purpose here
        if ([defenseNames[indexPath.row] isEqual:@"Add Player"]) {
            //cell.playerPosition.hidden = YES;
            cell.playerPosition.text = @"";
        }
        cell.playerImageHolder.image = defenseImages[indexPath.row];
    } else if (tableView == specialTable) {
        cell.playerPosition.text = specialPositions[indexPath.row];
        if ([specialNames[indexPath.row] isEqual:@"Add Player"]) {
            cell.playerPosition.text = @"";
        }
        if (indexPath.row == 0) {
            cell.playerName.text = specialNames[indexPath.row];
        } else {
            NSString *formattedString;
            if (isModifying) {
                formattedString = [NSString stringWithFormat:@"%@", specialNames[indexPath.row]];
            } else {
                formattedString = [NSString stringWithFormat:@"%@ - %@", specialNames[indexPath.row], specialPositions[indexPath.row]];
            }
            
            cell.playerName.text = formattedString;
        }
        
        
        cell.playerImageHolder.image = specialImages[indexPath.row];
    }
    [cell.playerImageHolder.layer setCornerRadius:12];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//set our header titles for both tableviews
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == offenseTable) {
        return @"Offensive Roster";
    } else if (tableView == defenseTable) {
        if (initialSetup) {
            return @"All Players";
        } else {
            return @"Defensive Roster";
        }
        
    } else if (tableView == specialTable) {
        return @"Special Teams Roster";
    }
    return nil;
}

- (void)viewWillLayoutSubviews {
    
    if (isSelectingOldPlayer) {
        specialTable.frame = CGRectMake(offenseTable.frame.origin.x, offenseTable.frame.origin.y, specialTable.frame.size.width, specialTable.frame.size.height);
    }
}

-(void)viewDidLayoutSubviews {
    if (isSelectingOldPlayer) {
        specialTable.frame = CGRectMake(offenseTable.frame.origin.x, offenseTable.frame.origin.y, specialTable.frame.size.width, specialTable.frame.size.height);
    }
}

//set larger custom size for section headers for both table views
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
    //user wants to create a special teams player using an existing player
        isSelectingOldPlayer = YES;
        specialTable.frame = CGRectMake(offenseTable.frame.origin.x, offenseTable.frame.origin.y, specialTable.frame.size.width, specialTable.frame.size.height);
        
        NSFetchRequest *playerFetch = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
        NSError *fetchError = nil;
        allPlayers = [context executeFetchRequest:playerFetch error:&fetchError];
        if (allPlayers == nil) {
            NSLog(@"Error fetching players when adding a special team player!  Error was:  %@", fetchError.description);
        } else {
            defenseNames = [[NSMutableArray alloc] init];
            defensePositions = [[NSMutableArray alloc] init];
            defenseImages = [[NSMutableArray alloc] init];
            for (Player *player in allPlayers) {
                NSString *name = player.name;
                NSString *position = player.position;
                UIImage *image = [UIImage imageWithData:player.image ];
                [defenseNames addObject:name];
                [defensePositions addObject:position];
                [defenseImages addObject:image];
            }
            specialTable.userInteractionEnabled = NO;
            
            //reload the defense table, which is now serving as our 'selector'
            [defenseTable reloadData];
            [defenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            defenseTable.hidden = NO;
        }
        
    } else if (buttonIndex == 2) {
    //user wants to create a new special teams player
        selectedType = @"special";
        selectablePositions = [[NSMutableArray alloc] initWithObjects:@"Choose Position", @"Holder", @"Long Snapper", @"Punt Returner", @"Upback", @"Gunner", @"Jammer" ,nil];
        [positionPicker reloadAllComponents];
        _nameInput.userInteractionEnabled = YES;
        _addImageButton.userInteractionEnabled = YES;
        _doneButton.enabled = NO;
        _doneButton.alpha = 0.5;
        addView.hidden = NO;
        selectedPosition = nil;
    }
}

//user selected a cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (initialSetup) {
        if (tableView == defenseTable) {
            PlayerCreateTableViewCell *cell = (PlayerCreateTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
            
            NSString *name = cell.playerName.text;
            UIImage *image;
            
            for (Player *player in allPlayers) {
                if ([player.name isEqual:name]) {
                    image = [UIImage imageWithData:player.image];
                    break;
                }
            }
            selectedType = @"special";
            //show the 'add' view and populate with the matched players data (and hide/reposition tableviews)
            _nameInput.text = name;
            
            [_addImageButton setBackgroundImage:image forState:UIControlStateNormal];
            selectablePositions = [[NSMutableArray alloc] initWithObjects:@"Choose Position", @"Holder", @"Long Snapper", @"Punt Returner", @"Upback", @"Gunner", @"Jammer" ,nil];
            [positionPicker reloadAllComponents];
            _doneButton.enabled = NO;
            _doneButton.alpha = 0.5;
            addView.hidden = NO;
            specialTable.frame = CGRectMake(offenseTable.frame.origin.x, offenseTable.frame.origin.y, specialTable.frame.size.width, specialTable.frame.size.height);
            defenseTable.hidden = YES;
            isSelectingOldPlayer = NO;
            
        } else {
            if (indexPath.row == 0) {
                //need to offer the user the choice to create a special teams player from an existing one
                UIAlertView *selectAlert = [[UIAlertView alloc] initWithTitle:@"Create Player" message:@"Would you like to use a previously created player or a new player?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Existing", @"New", nil];
                [selectAlert show];
            } else {
                //user wants to edit an already created special teams player
                editMode = true;
                int unsignedConverted = (int)indexPath.row;
                editIndex = unsignedConverted;
                editType = @"special";
                selectedPosition = specialPositions[indexPath.row];
                _nameInput.text = specialNames[indexPath.row];
                [_addImageButton setBackgroundImage:specialImages[indexPath.row] forState:UIControlStateNormal];
            
                selectablePositions = [[NSMutableArray alloc] initWithObjects:@"Choose Position", @"Holder", @"Long Snapper", @"Punt Returner", @"Upback", @"Gunner", @"Jammer" ,nil];
                [positionPicker reloadAllComponents];
                int pickerSelect;
                for (int i = 0; i < selectablePositions.count; i ++) {
                    if ([selectedPosition isEqual:selectablePositions[i]]) {
                        pickerSelect = i;
                        break;
                    }
                }
                [positionPicker selectRow:pickerSelect inComponent:0 animated:NO];

                specialTable.userInteractionEnabled = NO;
                addView.hidden = NO;
            }
        }
    } else {
        if (indexPath.row == 0) {
            //user tapped on the create new cell so allow the creation of a new player
            if (tableView == offenseTable) {
                selectedType = @"offense";
                selectablePositions = [[NSMutableArray alloc] initWithObjects:@"Choose Position",@"Center",@"Offensive Guard",@"Offensive Tackle",@"Tight End", @"Wide Receiver", @"Running Back",@"Quarterback",@"Punter", nil];
                [positionPicker reloadAllComponents];
                _doneButton.enabled = NO;
                _doneButton.alpha = 0.5;
                addView.hidden = NO;
                selectedPosition = nil;
            } else if (tableView == defenseTable) {
                selectedType = @"defense";
                selectablePositions = [[NSMutableArray alloc] initWithObjects:@"Choose Position", @"Defensive Tackle",@"Defensive End",@"Middle Linebacker",@"Outside Linebacker",@"Cornerback",@"Safety", nil];
                [positionPicker reloadAllComponents];
                _doneButton.enabled = NO;
                _doneButton.alpha = 0.5;
                addView.hidden = NO;
                selectedPosition = nil;
            }
        } else {
            //user tapped an already created player, so let them edit it within the original form
            if (tableView == offenseTable) {
                NSLog(@"NSLog selected player's position is:  %@", offensePositions[indexPath.row]);
                editMode = true;
                //convert so we're "64 bit safe"
                int unsignedConverted = (int)indexPath.row;
                editIndex = unsignedConverted;
                editType = @"offense";
                
                selectedPosition = offensePositions[indexPath.row];
                _nameInput.text = offenseNames[indexPath.row];
                [_addImageButton setBackgroundImage:offenseImages[indexPath.row] forState:UIControlStateNormal];
                selectablePositions = [[NSMutableArray alloc] initWithObjects:@"Choose Position",@"Center",@"Offensive Guard",@"Offensive Tackle",@"Tight End", @"Wide Receiver", @"Running Back",@"Quarterback",@"Punter", nil];
                [positionPicker reloadAllComponents];
                int pickerSelect;
                for (int i = 0; i < selectablePositions.count; i ++) {
                    if ([selectedPosition isEqual:selectablePositions[i]]) {
                        pickerSelect = i;
                        break;
                    }
                }
                [positionPicker selectRow:pickerSelect inComponent:0 animated:NO];
                _doneButton.enabled = YES;
                _doneButton.alpha = 1.0;
                addView.hidden = NO;
            } else if (tableView == defenseTable) {
                NSLog(@"NSLog selected player's position is:  %@", defensePositions[indexPath.row]);
                editMode = true;
                editIndex = (int) indexPath.row;
                editType = @"defense";
                
                selectedPosition = defensePositions[indexPath.row];
                _nameInput.text = defenseNames[indexPath.row];
                [_addImageButton setBackgroundImage:defenseImages[indexPath.row] forState:UIControlStateNormal];
                selectablePositions = [[NSMutableArray alloc] initWithObjects:@"Choose Position", @"Defensive Tackle",@"Defensive End",@"Middle Linebacker",@"Outside Linebacker",@"Cornerback",@"Safety", nil];
                [positionPicker reloadAllComponents];
                int pickerSelect;
                for (int i = 0; i < selectablePositions.count; i ++) {
                    if ([selectedPosition isEqual:selectablePositions[i]]) {
                        pickerSelect = i;
                        break;
                    }
                }
                [positionPicker selectRow:pickerSelect inComponent:0 animated:NO];
                _doneButton.enabled = YES;
                _doneButton.alpha = 1.0;
                addView.hidden = NO;
            }
        }
    }
    
}

//create footers for both table views to tell the user how many players remaining for each before they're done
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView == offenseTable) {
        UILabel *remainingLabel = [[UILabel alloc] init];
        int remaining = [self checkPlayersRemaining:@"offense"];
        NSString *labelString = [[NSString alloc] initWithFormat:@"%i players remaining. Tap to view.", remaining];
        offenseRemainingCount = remaining;
        remainingLabel.text = labelString;
        remainingLabel.textColor = [UIColor whiteColor];
        remainingLabel.textAlignment = NSTextAlignmentCenter;
        remainingLabel.backgroundColor = [UIColor colorWithRed:0.004 green:0.494 blue:0.522 alpha:1];
        
        //allow the user to tap the footer so they can see the positions that are still needed (will HOPEFULLY BE IMPLEMENTED IN FUTURE BUILD...not enough time now)
        remainingLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(offenseFooterTap:)];
        [remainingLabel addGestureRecognizer:tapGesture];
        return  remainingLabel;
    } else if (tableView == defenseTable) {
        UILabel *remainingLabel = [[UILabel alloc] init];
        int remaining = [self checkPlayersRemaining:@"defense"];
        NSString *labelString = [[NSString alloc] initWithFormat:@"%i players remaining. Tap to view.", remaining];
        defenseRemainingCount = remaining;
        remainingLabel.text = labelString;
        remainingLabel.textColor = [UIColor whiteColor];
        remainingLabel.textAlignment = NSTextAlignmentCenter;
        remainingLabel.backgroundColor = [UIColor colorWithRed:0.004 green:0.494 blue:0.522 alpha:1];
        
        //allow user to tap defense footer to see positions still needed (only if in initial roster setup)
        if (initialSetup) {
            remainingLabel.text = @"";
            return remainingLabel;
        } else {
            remainingLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(defenseFooterTap:)];
            [remainingLabel addGestureRecognizer:tapGesture];
        }
        
        return  remainingLabel;
    } else if (tableView == specialTable) {
        UILabel *footerLabel = [[UILabel alloc] init];
        footerLabel.text = @"";
        footerLabel.backgroundColor = [UIColor colorWithRed:0.004 green:0.494 blue:0.522 alpha:1];
        return footerLabel;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //if user is modifying the roster (after initial setup) actually delete the player from Core Data
        if (isModifying) {
            if (tableView == offenseTable) {
                Player *deletePlayer = [self checkExisting:offenseNames[indexPath.row] :@"offense"];
                [context deleteObject:deletePlayer];
            } else if (tableView == defenseTable) {
                Player *deletePlayer = [self checkExisting:defenseNames[indexPath.row] :@"defense"];
                [context deleteObject:deletePlayer];
            } else {
                Player *deletePlayer = [self checkExisting:specialNames[indexPath.row] :@"special"];
                [context deleteObject:deletePlayer];
            }
        }
        
        //delete item since the user tapped the delete button and then reload all table data/values
        if (tableView == offenseTable) {
            [offensePositions removeObjectAtIndex:indexPath.row];
            [offenseNames removeObjectAtIndex:indexPath.row];
            [offenseImages removeObjectAtIndex:indexPath.row];
            [offenseTable reloadData];
            [offenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
        } else if (tableView == defenseTable) {
            [defensePositions removeObjectAtIndex:indexPath.row];
            [defenseNames removeObjectAtIndex:indexPath.row];
            [defenseImages removeObjectAtIndex:indexPath.row];
            [defenseTable reloadData];
            [defenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
        } else {
            [specialPositions removeObjectAtIndex:indexPath.row];
            [specialNames removeObjectAtIndex:indexPath.row];
            [specialImages removeObjectAtIndex:indexPath.row];
            [specialTable reloadData];
            [specialTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
        }
        [self checkRoster];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (initialSetup) {
        if (tableView == specialTable) {
            return true;
        } else {
            return false;
        }
    } else {
        if (indexPath.row == 0) {
            return false;
        } else {
            return true;
        }
    }
}

 -(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
     return 44;
 }

-(void)offenseFooterTap:(UIGestureRecognizer*)recognizer {
    [self showRemainingView:@"offense"];
    
}

-(void)defenseFooterTap:(UIGestureRecognizer*)recognizer {
    if (initialSetup == false) {
        [self showRemainingView:@"defense"];
    }
}

-(int)checkPlayersRemaining:(NSString*)type {
    //loop through two arrays that list all needed postions for each team type and return the number of players that haven't been created yet
    if ([type isEqual:@"offense"]) {
        NSLog(@"reloading offense footer!");
        NSMutableArray *positions = [[NSMutableArray alloc] initWithObjects:@"Center",@"Offensive Guard",@"Offensive Guard",@"Offensive Tackle",@"Offensive Tackle",@"Tight End", @"Wide Receiver", @"Wide Receiver", @"Running Back",@"Running Back",@"Quarterback",@"Punter", nil];
        
        NSMutableArray *currentOffense = offensePositions;
        
        for (int i = (int)[currentOffense count]-1; i >=0; i --) {
            for (int x = (int)[positions count]-1; x>=0; x --) {
                if ([currentOffense[i] isEqual:(positions[x])]) {
                    [positions removeObjectAtIndex:x];
                    x--;
                }
            }
        }
        offenseRemaining = positions;
        return (int)[positions count];
    } else if ([type isEqual:@"defense"]) {
        NSMutableArray *positions = [[NSMutableArray alloc] initWithObjects:@"Defensive Tackle",@"Defensive Tackle",@"Defensive End",@"Defensive End",@"Middle Linebacker",@"Outside Linebacker",@"Outside Linebacker",@"Cornerback",@"Cornerback",@"Safety",@"Safety", nil];
        
        NSMutableArray *currentDefense = defensePositions;
        
        for (int i = (int)[currentDefense count]-1; i>=0; i --) {
            for (int x = (int)[positions count]-1; x>=0; x --) {
                if ([currentDefense[i] isEqual:(positions[x])]) {
                    [positions removeObjectAtIndex:x];
                    x--;
                }
            }
        }
        defenseRemaining = positions;
        return (int) positions.count;
    }
    return 0;
}

//this method checks to see if a player is already saved out to Core Data and returns it if so
-(Player*)checkExisting:(NSString*)name :(NSString*)team {
    NSFetchRequest *playerFetch = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
    NSError *playerError;
    NSArray *allPlayers = [context executeFetchRequest:playerFetch error:&playerError];
    
    Player *matchedPlayer;
    for (Player *thisPlayer in allPlayers) {
        if ([thisPlayer.name isEqualToString:name] && [thisPlayer.team isEqualToString:team]) {
            matchedPlayer = thisPlayer;
            break;
        }
    }
    
    if (matchedPlayer != nil) {
        return matchedPlayer;
    } else {
        return nil;
    }
}

//handle the taps for our two buttons on the player creation form view
-(IBAction)onClick:(id)sender {
    NSLog(@"Done button was clicked in the editing popover!");
    UIButton *button = (UIButton*) sender;
    if (button.tag == 0) {
        //user tapped the 'done' button, so only dismiss the creation view if all data has been added
        if (isModifying) {
            if (editMode == true) {
                Player *editPlayer;
                if ([editType isEqualToString:@"offense"]) {
                    editPlayer = [self checkExisting:offenseNames[editIndex] :editType];
                    if (editPlayer == nil) {
                        editPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
                        
                    }
                    editPlayer.team = @"offense";
                    [offenseNames replaceObjectAtIndex:editIndex withObject:_nameInput.text];
                    [offensePositions replaceObjectAtIndex:editIndex withObject:selectedPosition];
                    [offenseImages replaceObjectAtIndex:editIndex withObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    //selectedPosition = nil;
                    //[self resetForm:@"offense"];
                    [offenseTable reloadData];
                    [offenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                    editType = nil;
                    editMode = false;
                    editIndex = 0;
                } else if ([editType isEqualToString:@"defense"]) {
                    editPlayer = [self checkExisting:defenseNames[editIndex] :editType];
                    if (editPlayer == nil) {
                        editPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
                    }
                    editPlayer.team = @"defense";
                    [defenseNames replaceObjectAtIndex:editIndex withObject:_nameInput.text];
                    [defensePositions replaceObjectAtIndex:editIndex withObject:selectedPosition];
                    [defenseImages replaceObjectAtIndex:editIndex withObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    //selectedPosition = nil;
                    //[self resetForm:@"defense"];
                    [defenseTable reloadData];
                    [defenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                    editType = nil;
                    editMode = false;
                    editIndex = 0;
                } else if ([editType isEqualToString:@"special"]) {
                    editPlayer = [self checkExisting:specialNames[editIndex] :editType];
                    if (editPlayer == nil) {
                        editPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
                    }
                    editPlayer.team = @"special";
                    [specialNames replaceObjectAtIndex:editIndex withObject:_nameInput.text];
                    [specialPositions replaceObjectAtIndex:editIndex withObject:selectedPosition];
                    [specialImages replaceObjectAtIndex:editIndex withObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    //selectedPosition = nil;
                    //[self resetForm:@"special"];
                    specialTable.userInteractionEnabled = YES;
                    [specialTable reloadData];
                    [specialTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                    editType = nil;
                    editMode = false;
                    editIndex = 0;
                }
                
                //set the values, since this part is the same regardless of what 'team' the player object is a part of
                editPlayer.name = _nameInput.text;
                editPlayer.position = selectedPosition;
                NSData *imageData = UIImageJPEGRepresentation([_addImageButton backgroundImageForState:UIControlStateNormal], 1.0);
                editPlayer.image = imageData;
                [self resetForm:@"offense"];
                
                
                
                NSError *saveError;
                [context save:&saveError];
            } else {
                //player is adding a new player while editing the entire roster
                Player *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
                if ([selectedType isEqualToString:@"offense"]) {
                    newPlayer.team = @"offense";
                    [offenseNames addObject:_nameInput.text];
                    [offensePositions addObject:selectedPosition];
                    [offenseImages addObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    //selectedPosition = nil;
                    //[self resetForm:@"offense"];
                    [offenseTable reloadData];
                    [offenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                    editType = nil;
                    editMode = false;
                    editIndex = 0;
                } else if ([selectedType isEqualToString:@"defense"]) {
                    newPlayer.team = @"defense";
                    [defenseNames addObject:_nameInput.text];
                    [defensePositions addObject:selectedPosition];
                    [defenseImages addObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    //selectedPosition = nil;
                    //[self resetForm:@"defense"];
                    [defenseTable reloadData];
                    [defenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                    editType = nil;
                    editMode = false;
                    editIndex = 0;
                } else if ([selectedType isEqualToString:@"special"]) {
                    newPlayer.team = @"special";
                    [specialNames addObject:_nameInput.text];
                    [specialPositions addObject:selectedPosition];
                    [specialImages addObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    //selectedPosition = nil;
                    
                    [specialTable reloadData];
                    [specialTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                    editType = nil;
                    editMode = false;
                    editIndex = 0;
                    
                    
                }
                
                newPlayer.name = _nameInput.text;
                newPlayer.position = selectedPosition;
                selectedPosition = nil;
                NSData *imageData = UIImageJPEGRepresentation([_addImageButton backgroundImageForState:UIControlStateNormal], 1.0);
                newPlayer.image = imageData;
                [self resetForm:@"special"];
                NSError *saveError;
                [context save:&saveError];
                
            }
            
        } else {
            //check to see if we were editing or creating a new player
            if (editMode == true) {
                if ([editType isEqual:@"offense"]) {
                    
                    
                    [offenseNames replaceObjectAtIndex:editIndex withObject:_nameInput.text];
                    [offensePositions replaceObjectAtIndex:editIndex withObject:selectedPosition];
                    [offenseImages replaceObjectAtIndex:editIndex withObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    selectedPosition = nil;
                    [self resetForm:@"offense"];
                    [offenseTable reloadData];
                    [offenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                    editType = nil;
                    editMode = false;
                    editIndex = 0;
                } else if ([editType isEqual:@"defense"]) {
                    [defenseNames replaceObjectAtIndex:editIndex withObject:_nameInput.text];
                    [defensePositions replaceObjectAtIndex:editIndex withObject:selectedPosition];
                    [defenseImages replaceObjectAtIndex:editIndex withObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    selectedPosition = nil;
                    [self resetForm:@"defense"];
                    [defenseTable reloadData];
                    [defenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                    editType = nil;
                    editMode = false;
                    editIndex = 0;
                } else if ([editType isEqual:@"special"]) {
                    BOOL isDuplicate = false;
                    for (PlayerCreateTableViewCell *cell in [specialTable visibleCells]) {
                        NSString *playerSavedName = [NSString stringWithFormat:@"%@", cell.playerName.text];
                        NSString *proposedName = [NSString stringWithFormat:@"%@ - %@", _nameInput.text, selectedPosition];
                        if ([playerSavedName isEqual:proposedName]) {
                            isDuplicate = true;
                            NSString *alertString = [NSString stringWithFormat:@"A player named %@ in the position \'%@\' has already been created.  Please choose another position.", _nameInput.text, selectedPosition];
                            UIAlertView *duplicateAlert = [[UIAlertView alloc] initWithTitle:@"Duplicate" message:alertString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                            [duplicateAlert show];
                            return;
                        }
                    }
                    if (isDuplicate == false) {
                        [specialNames replaceObjectAtIndex:editIndex withObject:_nameInput.text];
                        [specialPositions replaceObjectAtIndex:editIndex withObject:selectedPosition];
                        [specialImages replaceObjectAtIndex:editIndex withObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                        selectedPosition = nil;
                        [self resetForm:@"special"];
                        specialTable.userInteractionEnabled = YES;
                        [specialTable reloadData];
                        [specialTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                        editType = nil;
                        editMode = false;
                        editIndex = 0;
                    }
                    
                }
                [self checkRoster];
                isSelectingOldPlayer = NO;
            } else {
                if ([selectedType  isEqual: @"offense"]) {
                    [offenseNames addObject:_nameInput.text];
                    [offensePositions addObject:selectedPosition];
                    [offenseImages addObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    selectedPosition = nil;
                    [self resetForm:@"offense"];
                    [offenseTable reloadData];
                    [offenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                } else if ([selectedType isEqual:(@"defense")]) {
                    [defenseNames addObject:_nameInput.text];
                    [defensePositions addObject:selectedPosition];
                    [defenseImages addObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                    selectedPosition = nil;
                    [self resetForm:@"defense"];
                    [defenseTable reloadData];
                    [defenseTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                } else if ([selectedType isEqual:@"special"]) {
                    BOOL isDuplicate = false;
                    for (PlayerCreateTableViewCell *cell in [specialTable visibleCells]) {
                        NSString *playerSavedName = [NSString stringWithFormat:@"%@", cell.playerName.text];
                        NSString *proposedName = [NSString stringWithFormat:@"%@ - %@", _nameInput.text, selectedPosition];
                        if ([playerSavedName isEqual:proposedName]) {
                            isDuplicate = true;
                            NSString *alertString = [NSString stringWithFormat:@"A player named %@ in the position \'%@\' has already been created.  Please choose another position.", _nameInput.text, selectedPosition];
                            UIAlertView *duplicateAlert = [[UIAlertView alloc] initWithTitle:@"Duplicate" message:alertString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                            [duplicateAlert show];
                            return;
                        }
                    }
                    if (isDuplicate == false) {
                        [specialNames addObject:_nameInput.text];
                        [specialPositions addObject:selectedPosition];
                        [specialImages addObject:[_addImageButton backgroundImageForState:UIControlStateNormal]];
                        selectedPosition = nil;
                        specialTable.userInteractionEnabled = YES;
                        [self resetForm:@"special"];
                        [specialTable reloadData];
                        [specialTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
                    }
                    
                }
                [self checkRoster];
                isSelectingOldPlayer = NO;
            }
            [self checkRoster];
            isSelectingOldPlayer = NO;
        }
        
        
    } else if (button.tag == 1) {
        //user tapped the add image button, so allow them to take a picture to associate with this player
        NSLog(@"Tapped the add image button!");
        [self addPicture];
    } else if (button.tag == 2) {
        //user tapped the cancel button, so hide and reset the 'add' form
        editMode = false;
        editIndex = 0;
        editType = nil;
        addView.hidden = YES;
        [self resetForm:nil];
        [self checkRoster];
        specialTable.userInteractionEnabled = YES;
        offenseTable.userInteractionEnabled = YES;
        defenseTable.userInteractionEnabled = YES;
        isSelectingOldPlayer = NO;
    }
}

-(void)checkRoster {
    if (offenseRemainingCount == 0 && defenseRemainingCount == 0) {
        NSLog(@"All players created!");
        NSLog(@"Remaining offense:  %i    Remaining defense:  %i", offenseRemainingCount, defenseRemainingCount);
        doneButton.enabled = YES;
    } else {
        NSLog(@"Still need players...");
        NSLog(@"Remaining offense:  %i    Remaining defense:  %i", offenseRemainingCount, defenseRemainingCount);
        doneButton.enabled = NO;
    }
}

-(void)doneEditing {
    if (addView.hidden == YES) {
        if (isModifying) {
             //if the user is modifying an already created roster, grab them so we can update existing players where needed
           
        }
        //if the user has completed the offense and defense portions of initial roster creation...
        if (initialSetup) {
           
            if (isModifying) {
                //don't need to do anything since saving during modification is handled by the UIPopover form when dismissing it
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.navigationController popViewControllerAnimated:YES];
                return;
                
            } else {
                //user just finished setting up special teams players, so save out and dismiss activity
                offenseTable.hidden = YES;
                defenseTable.hidden = YES;
                specialTable.hidden = NO;
                
                //simply set a bool in NSUserDefaults to signal that data has been setup
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:YES forKey:@"dataSetup"];
                [defaults synchronize];
                
                //save out our special team players as their own entities
                for (int i = 1; i < specialNames.count; i ++) {
                    Player *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
                    newPlayer.name = [NSString stringWithFormat:@"%@ - %@", specialNames[i], specialPositions[i]];
                    newPlayer.position = specialPositions[i];
                    newPlayer.team = @"special";
                    NSData *imageData = UIImageJPEGRepresentation(specialImages[i], 1.0);
                    newPlayer.image = imageData;
                }
                
                NSError *error = nil;
                
                if (![[app managedObjectContext]save:&error]) {
                    NSLog(@"Error saving out special team players!  %@", error);
                }
            }
            
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            if (isModifying) {
                //don't need to do anything since saving during modification is handled by the UIPopover form when dismissing it
                //[self dismissViewControllerAnimated:YES completion:nil];
                //[self.navigationController popViewControllerAnimated:YES];
                //return;
                initialSetup = true;
                offenseTable.hidden = YES;
                defenseTable.hidden = YES;
                specialTable.hidden = NO;
                return;
                
            }
            //core data time!  Create players for each team
            for (int i = 1; i < offenseNames.count; i++) {
                
                Player *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
                newPlayer.name = offenseNames[i];
                newPlayer.position = offensePositions[i];
                newPlayer.team = @"offense";
                NSData *imageData = UIImageJPEGRepresentation(offenseImages[i], 1.0);
                newPlayer.image = imageData;
            }
            
            for (int i = 1; i < defenseNames.count; i++) {
                Player *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
                newPlayer.name = defenseNames[i];
                newPlayer.position = defensePositions[i];
                newPlayer.team = @"defense";
                NSData *imageData = UIImageJPEGRepresentation(defenseImages[i], 1.0);
                newPlayer.image = imageData;
            }
            
            //after creating each player object, save manually
            NSError *error = nil;
            
            if (![[app managedObjectContext]save:&error]) {
                NSLog(@"Error saving core data!  %@", error);
            }
            
            
            initialSetup = true;
            offenseTable.hidden = YES;
            defenseTable.hidden = YES;
            specialTable.hidden = NO;
        }
    }
    
}

-(void)resetForm:(NSString*)type {
    addView.hidden = YES;
    [positionPicker selectRow:0 inComponent:0 animated:NO];
    [_addImageButton setBackgroundImage:[UIImage imageNamed:@"silhouette_add.png"] forState:UIControlStateNormal];
    _nameInput.text = nil;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([selectedType isEqual:@"offense"]) {
        return selectablePositions.count;
    } else if ([selectedType isEqual:@"defense"]) {
        return selectablePositions.count;
    } else if ([selectedType isEqual:@"special"]) {
        return selectablePositions.count;
    }
    return 0;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return selectablePositions[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"User selected %@", selectablePositions[row]);
    NSString *selected = selectablePositions[row];
    if ([selected isEqual:@"Choose Position"]) {
        selectedPosition = nil;
    } else {
        selectedPosition = selectablePositions[row];
    }
    [self checkForm];
}

//ensure the user inputs valid data for at least the players name and position (image isn't required)
-(void)checkForm {
    if (selectedPosition != nil) {
        
        NSString *inputString = _nameInput.text;
        NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmed = [inputString stringByTrimmingCharactersInSet:whiteSpace];
        if ([trimmed length] == 0) {
            _doneButton.enabled = NO;
            _doneButton.alpha = 0.5;
            return;
        }
        
        if (_nameInput.text != nil && [_nameInput.text isEqual:@""] == false && _nameInput.text.length > 0) {
            _doneButton.enabled = YES;
            _doneButton.alpha = 1.0;
        } else {
            _doneButton.enabled = NO;
            _doneButton.alpha = 0.5;
        }
    } else {
        _doneButton.enabled = NO;
        _doneButton.alpha = 0.5;
    }
}

//disable the done button when editing, as in some instances the user may be able to exit the form with invalid data
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _doneButton.enabled = NO;
    _doneButton.alpha = 0.5;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *errorString = [NSString stringWithFormat:@"A player with the name %@ has already been created.  Please input a new name.", _nameInput.text];
    UIAlertView *duplicateAlert = [[UIAlertView alloc] initWithTitle:@"Player already Exists!" message:errorString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [_nameInput.text stringByTrimmingCharactersInSet:whiteSpace];
    for (NSString *name in offenseNames) {
        if ([trimmed isEqual:name]) {
            [duplicateAlert show];
            [_nameInput becomeFirstResponder];
            return;
        }
    }
    
    for (NSString *name in defenseNames) {
        if ([trimmed isEqual:name]) {
            [duplicateAlert show];
            [_nameInput becomeFirstResponder];
            return;
        }
    }
    [self checkForm];
}

//this method lets us end editing on the Play name text field when the user taps the 'done' button
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_nameInput resignFirstResponder];
    [self checkForm];
    return NO;
}


-(BOOL)keyboardWillHide:(NSNotification *)notification {
    [_nameInput resignFirstResponder];
    [self checkForm];
    return YES;
}


-(void)addPicture {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    // image picker needs a delegate,
    [imagePickerController setDelegate:self];
    takingPicture = true;
    // Place image picker on the screen
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:imagePickerController animated:YES completion:^{
            NSLog(@"Completed block");
        }];
    }];
}

- (void)addPhotoObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCameraOverlay) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil ];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCameraOverlay) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil ];
}

-(void)removeCameraOverlay {
    if (imagePickerController) {
        //self.cameraPicker.cameraOverlayView = nil;
        imagePickerController.cameraOverlayView = nil;
    }
}

-(void)addCameraOverlay {
    if (imagePickerController) {
        //self.cameraPicker.cameraOverlayView = self.myCameraOverlayView;
        imagePickerController.cameraOverlayView = self.view;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"didFinishPickingMedia");
    UIImage *pictureTaken = (UIImage*) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    //reduce the size of the captured image, since we only need a thumbnail
    CGSize destinationSize = CGSizeMake(89, 74);
    UIGraphicsBeginImageContext(destinationSize);
    [pictureTaken drawInRect:CGRectMake(0,0,destinationSize.width, destinationSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //apply our thumbnail to the add picture button
    [_addImageButton setBackgroundImage:thumbnail forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    takingPicture = false;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showRemainingView:(NSString*)type {
    //disable all other UI
    offenseTable.userInteractionEnabled = NO;
    defenseTable.userInteractionEnabled = NO;
    doneButton.enabled = NO;
    helpButton.enabled = NO;
    
    NSArray *positions;
    NSArray *labels;
    if ([type isEqual:@"offense"]) {
        remainingHeader.text = @"Minimum positions to complete Offense roster:";
        positions = [[NSArray alloc] initWithObjects:@"1 x Center", @"2 x Offensive Guard", @"2 x Offensive Tackle", @"1 x Tight End", @"2 x Wide Receiver", @"2 x Running Back", @"1 x Quarterback", @"1 x Punter", nil];
        labels = [[NSArray alloc] initWithObjects:positionsLabel1, positionsLabel2, positionsLabel3, positionsLabel4, positionsLabel5, positionsLabel6, positionsLabel7, positionsLabel8, nil];
        for (int i = 0; i < positions.count; i ++) {
            UILabel *currentLabel = labels[i];
            [currentLabel setText:positions[i]];
        }
        positionsLabel7.hidden = NO;
        positionsLabel8.hidden = NO;
    } else {
        remainingHeader.text = @"Minimum positions to complete Defense roster:";
        positions = [[NSArray alloc] initWithObjects:@"2 x Defensive Tackle", @"2 x Defensive End", @"1 x Middle Linebacker", @"2 x Outside Linebacker", @"2 x Cornerback", @"2 x Safety", nil];
        labels = [[NSArray alloc] initWithObjects:positionsLabel1, positionsLabel2, positionsLabel3, positionsLabel4, positionsLabel5, positionsLabel6, nil];
        for (int i = 0; i < positions.count; i ++) {
            UILabel *currentLabel = labels[i];
            [currentLabel setText:positions[i]];
        }
        positionsLabel7.hidden = YES;
        positionsLabel8.hidden = YES;
    }
    remainingView.hidden = NO;
}

-(IBAction)closeRemaining:(id)sender {
    remainingView.hidden = YES;
    offenseTable.userInteractionEnabled = YES;
    defenseTable.userInteractionEnabled = YES;
    doneButton.enabled = YES;
    helpButton.enabled = YES;
}

@end
