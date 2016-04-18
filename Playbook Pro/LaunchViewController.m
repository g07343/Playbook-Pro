//
//  ViewController.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/16/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "LaunchViewController.h"
#import "PlaySelectionViewController.h"
#import "AppDelegate.h"
#import "PlayBook.h"
#import "OffensePlay.h"
#import "DefensePlay.h"
#import "PlayerSetupViewController.h"
#import <iAd/iAd.h>

@interface LaunchViewController ()

@end

@implementation LaunchViewController
@synthesize testString;

NSString *buttonSelected;
NSManagedObjectContext *context;
AppDelegate *app;
bool dataSaved;
NSManagedObjectContext *context;
AppDelegate *app;
NSMutableArray *gamesArray;
PlayBook *newPlay;
NSString *bookSelected;
int itemToDelete;
NSMutableArray *backupArray;
NSString *password;
BOOL isSelecting;
NSMetadataQuery *metadataQuery;
NSString *currentBook;
NSString *chosenBook;
BOOL isCopying;
BOOL modifyingRoster;
ADBannerView *banner;

- (void)viewDidLoad {
    testString = @"test!!!";
    //hide iOS status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    isSelecting = false;
    
    [super viewDidLoad];
    
    backupSelectView.hidden = YES;
    passwordView.hidden = YES;
    restorePasswordView.hidden = YES;
    restoringView.hidden = YES;
    bookList.rowHeight = 144;
    bookList.backgroundColor = [UIColor clearColor];
    tableViewBackground.layer.cornerRadius = 8;
    tableViewBackground.clipsToBounds = YES;
    
    bookList.layer.cornerRadius = 8;
    bookList.clipsToBounds = YES;
    
    //set initial selection to nil
    buttonSelected = nil;
    
    offenseBtn.enabled = NO;
    defenseBtn.enabled = NO;
    offenseCount.hidden = YES;
    defenseCount.hidden = YES;
    
    addNameView.layer.cornerRadius = 8;
    addNameView.hidden = YES;
    addNameField.delegate = self;
    
    banner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 66, 1024, 66)];
    [self.view addSubview:banner];
    banner.delegate = self;
    
    //initially hide the ad banner
    banner.alpha = 0.0;
    self.canDisplayBannerAds = NO;
    
    
}

-(BOOL)checkSaved {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL dataSaved = [defaults boolForKey:@"dataSetup"];
    return dataSaved;
}

-(int) numberSaved {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
    [request setEntity:entity];
    
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    if (!error) {
        int unsignedConverted = (int)count;
        return unsignedConverted;
    } else {
        NSLog(@"error checking for save data! %@", error);
        return 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onClick:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button.tag == 1) {
        //user tapped the create new button
        NSLog(@"User tapped the create new playbook button!");
        
        [self performSegueWithIdentifier:@"SetupRoster" sender:nil];
    } else if (button.tag == 2) {
        //user tapped the offense button
        NSLog(@"User tapped OFFENSE button!");
        buttonSelected = @"offense";
        [self performSegueWithIdentifier:@"SelectPlays" sender:nil];
    } else if (button.tag == 3) {
        //user tapped the defense button
        NSLog(@"User tapped the DEFENSE button!");
        buttonSelected = @"defense";
        [self performSegueWithIdentifier:@"SelectPlays" sender:nil];
    } else if (button.tag == 4) {
        //user tapped cancel button when adding a new playbook/game
        NSLog(@"CANCEL");
        addNameField.delegate = self;
        [addNameField resignFirstResponder];
        addNameView.hidden = YES;
        
    } else if (button.tag == 5) {
        //user tapped the 'done' button when adding a new playbook/game
        
        NSString *trimmedString = [addNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([trimmedString length] > 0 || [trimmedString isEqual:@""] == FALSE) {
            BOOL wasMatched = false;
            //ensure the name the user chose isn't already created
            for (NSString *savedName in gamesArray) {
                if ([savedName isEqual:trimmedString]) {
                    //already saved game with this title, alert user
                    NSString *alertString = [NSString stringWithFormat:@"A game with the title '%@' already exists.  Please choose another name", trimmedString];
                    UIAlertView *existingAlert = [[UIAlertView alloc] initWithTitle:@"Game already exists" message:alertString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [existingAlert show];
                    wasMatched = true;
                    break;
                } else {
                    
                }
            }
            
            if (wasMatched != true) {
                //save a new 'game' object to core data and update tableview
                [addNameField resignFirstResponder];
                newPlay = [NSEntityDescription insertNewObjectForEntityForName:@"PlayBook" inManagedObjectContext:context];
                newPlay.name = trimmedString;
                
                //save new playbook to core data
                NSError *saveError = nil;
                [context save:&saveError];
                
                
                
                //add new name to array list
                //[gamesArray addObject:trimmedString];
                NSMutableArray *copiedNames = [[NSMutableArray alloc] initWithArray:gamesArray];
                [copiedNames addObject:trimmedString];
                
                gamesArray = [copiedNames copy];
                
                addNameView.hidden = YES;
                [bookList reloadData];
            }
            
        } else {
            UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"Name Empty" message:@"Please input a valid name for your new game." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [emptyAlert show];
            
        }
    } else if (button.tag == 6) {
        NSLog(@"Backup button tapped!");
        NSString *titleString = @"Backup or Restore Playbooks";
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Backup Playbooks",@"Restore Playbooks", nil];
        [actionSheet showFromRect:[(UIView*)backupBtn frame] inView:self.view animated:YES];
        actionSheet.tag = 1;
    } else if (button.tag == 7) {
        //'edit' roster button tapped
        NSLog(@"Roster button tapped!");
        modifyingRoster = true;
        [self performSegueWithIdentifier:@"SetupRoster" sender:nil];
    } else if (button.tag == 8) {
        //user closed the initial 'iCloud' view after first app launch
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (icloudSwitch.on) {
            [defaults setBool:true forKey:@"iCloudEnabled"];
            [defaults synchronize];
            [app toggleiCloud];
        } else {
            [defaults setBool:false forKey:@"iCloudEnabled"];
            [defaults synchronize];
            //[app toggleiCloud];
        }
        iCloudIntroView.hidden = YES;
        [defaults setBool:true forKey:@"iCloudPrefSet"];
        [defaults synchronize];
        tutorialView.hidden = NO;
        [self makeViewGlow:tutorialButton];
    }
}

//delegate method to capture user's choice in UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
        //user chose to backup playbooks
            if (gamesArray.count > 1) {
                UIAlertView *backupAlert = [[UIAlertView alloc] initWithTitle:@"Backup Type" message:@"Pick what type of backup you would like to perform.  *BACKUPS MAY TAKE A WHILE TO SAVE depending on your internet connection.  You may continue to use the app as normal in the meantime.*" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"All Playbooks", @"Pick Playbooks", nil];
                backupAlert.tag = 2;
                [backupAlert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Playbooks" message:@"You don't have any playbooks to back up yet.  Create a playbook to continue" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alert show];
            }
            
        } else if (buttonIndex == 1) {
        //user chose to restore from backup
            UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Restoring from a cloud backup may overwrite local copies of your playbooks, plays, and players.  Continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];
            restoreAlert.tag = 3;
            [restoreAlert show];
        }
    }
}


//this method lets us 'send' which button was tapped, offense or defense
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SelectPlays"]) {
        
        PlaySelectionViewController *playSelect = (PlaySelectionViewController *) [segue destinationViewController];
        playSelect.buttonChosen = buttonSelected;
        playSelect.launchView = self;
        if (chosenBook != nil) {
            playSelect.chosenBook = chosenBook;
        }
        chosenBook = nil;
    } else if ([[segue identifier] isEqualToString:@"SetupRoster"]) {
        PlayerSetupViewController *playerController = (PlayerSetupViewController*) [segue destinationViewController];
        if (modifyingRoster) {
            playerController.isModifying = true;
        }
    }
}

//allow the user to manually enable/disable iCloud integration
-(void)valueChanged:(UISwitch*)theSwitch {
    BOOL isEnabled = theSwitch.on;
    if (isEnabled) {
        iCloudStatusLabel.text = @"ON";
        iCloudStatusLabel.textColor = [UIColor greenColor];
    } else {
        iCloudStatusLabel.text = @"OFF";
        iCloudStatusLabel.textColor = [UIColor lightGrayColor];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [self reloadTable];
}

-(void)viewWillAppear:(BOOL)animated {
    bookSelected = nil;
    modifyingRoster = false;
    copyView.hidden = YES;
    backupBtn.hidden = YES;
    offenseCount.hidden = YES;
    defenseCount.hidden = YES;
    rosterButton.hidden = YES;
    offenseBtn.enabled = NO;
    defenseBtn.enabled = NO;
    if (isCopying) {
        copyView.hidden = NO;
    }
    
    BOOL iCloudEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"];
    if (iCloudEnabled == true) {
        icloudSwitch.on = YES;
    }
    
    [icloudSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.navigationController.navigationBar setHidden:YES];
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    
    //if this is the first time the user has launched the app, prompt them for using iCloud
    BOOL iCloudSet = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudPrefSet"];
    if(iCloudSet) {
        iCloudIntroView.hidden = YES;
        //display either the first or second tutorial screens in sequence
        tutorialView.hidden = YES;
        BOOL didFinishFirstTutorial = [[NSUserDefaults standardUserDefaults] boolForKey:@"launchTutorialFinished"];
        BOOL didFinishSecondTutorial = [[NSUserDefaults standardUserDefaults] boolForKey:@"launchTutorialSecondFinished"];
        if (!(didFinishFirstTutorial)) {
            UIImage *firstImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath, @"initial_tutorial.png"]];
            [tutorialImageView setImage:firstImage];
            tutorialView.hidden = NO;
            [self makeViewGlow:tutorialButton];
        } else if (!(didFinishSecondTutorial)) {
            
            UIImage *test = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath,@"launch_tutorial.png"]];
            tutorialImageView.image = test;
            tutorialView.hidden = NO;
            [self makeViewGlow:tutorialButton];
        }
    } else {
        tutorialView.hidden = YES;
        //user has not set their iCloud use preference so prompt them
        iCloudIntroView.hidden = NO;
    }
    
    
    //for this view, hide the navigation bar, as it doesn't add anything
    [self.navigationController setNavigationBarHidden:YES];

    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app setLaunchView:self];
    context = app.managedObjectContext;
    
    
    dataSaved = [self checkSaved];
    
    
    
    ///////////////////////////////////
    NSFetchRequest *savedFetch = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
    NSError *fetchError;
    NSArray *playersArray = [context executeFetchRequest:savedFetch error:&fetchError];
    if (playersArray != nil && playersArray.count > 0) {
        dataSaved = true;
        rosterButton.hidden = NO;
    }
    
    
    
    
    
    
    
    
    
    //check bool and if true, a previous playbook was created, so display the offense/defense buttons
    if (dataSaved == true) {
        
        
        
        
        [self reloadTable];
        
//        int numOffensePlays = [self checkNumberPlays:@"offense"];
//        NSString *convertedNum = [NSString stringWithFormat:@"%i plays", numOffensePlays];
//        int numDefensePlays = [self checkNumberPlays:@"defense"];
//        NSString *convertedNum2 = [NSString stringWithFormat:@"%i plays", numDefensePlays];
//        offenseCount.text = convertedNum;
//        defenseCount.text = convertedNum2;
        
    } else {
        //[self reloadTable];
    }
    [self reloadTable];
    //[self performSelectorOnMainThread:@selector(toggleUI) withObject:nil waitUntilDone:NO];
    //[self toggleUI];
}

-(void)makeViewGlow:(UIView*) view {
    view.layer.shadowColor = [UIColor whiteColor    ].CGColor;
    view.layer.shadowRadius = 10.0f;
    view.layer.shadowOpacity = 1.0f;
    view.layer.shadowOffset = CGSizeZero;
    
    [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        [UIView setAnimationRepeatCount:INFINITY];
        view.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        
    } completion:^(BOOL finished) {
        view.layer.shadowRadius = 0.0f;
        view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
}

-(void)resetContext {
    context = [app getContext];
}

//show the 'loading' UIView when migrating from iCloud to local
-(void)showLoading {
    restoringView.hidden = NO;
}

//dynamically toggle the UI if there is prior data saved
-(void)toggleUI {    
    if (gamesArray.count > 1 || dataSaved == true) {
        if (!(createNewBtn.hidden)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                rosterButton.hidden = NO;
                createNewBtn.hidden = YES;
                helpButton.hidden = NO;
                offenseBtn.hidden = NO;
                defenseBtn.hidden = NO;
                defenseCount.hidden = YES;
                offenseCount.hidden = YES;
                bookList.hidden = NO;
                tableViewBackground.hidden = NO;
                offenseBtn.enabled = NO;
                defenseBtn.enabled = NO;
                NSLog(@"UNHIDING BUTTONS!");
                if (createNewBtn != nil && bookList != nil) {
                    NSLog(@"Items aren't nil!");
                } else {
                    NSLog(@"Items WERE nil!");
                }
                
            });
        } else {
            NSLog(@"DEBUG:  Create new button WAS hidden!");
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            helpButton.hidden = YES;
            rosterButton.hidden = YES;
            offenseBtn.hidden = YES;
            defenseBtn.hidden = YES;
            defenseCount.hidden = YES;
            offenseCount.hidden = YES;
            addNameView.hidden = YES;
            bookList.hidden = YES;
            tableViewBackground.hidden = YES;
        });
    }
}

-(void)reloadTable {
    
    gamesArray = [[NSMutableArray alloc] init];
    
    [gamesArray addObject:@"New Game"];
    NSArray *objectsToAdd = [self checkNumberPlaybooks];
    [gamesArray addObjectsFromArray:objectsToAdd];
    if (gamesArray.count > 1 || dataSaved == true) {
        restoringView.hidden = YES;
    }
    //remove duplicates from array
//    for (int i = 0; i < gamesArray.count; i ++) {
//        NSString *currentBook = gamesArray[i];
//        for (int x = i + 1; x < gamesArray.count; x ++) {
//            if (x > gamesArray.count) {
//                break;
//            } else {
//                NSString *thisName = gamesArray[x];
//                if () {
//                
//                }
//            }
//        }
//    }
    
    dispatch_async(dispatch_get_main_queue(), ^{ [bookList reloadData]; });
    //[bookList reloadData];
    [self performSelectorOnMainThread:@selector(toggleUI) withObject:nil waitUntilDone:NO];
    //[self viewWillAppear:YES];
}


-(void)viewWillDisappear:(BOOL)animated {
    for (UITableViewCell *cell in [bookList visibleCells]) {
        //reset all coloring for all cell's custom background views
        UIView *background = cell.subviews[0];
        background.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
}

-(NSArray*)checkNumberPlaybooks {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"PlayBook"];
    
    NSError *error = nil;
    
    NSArray *allPlaybooks = [context executeFetchRequest:request error:&error];
    
    if (allPlaybooks == nil) {
        NSLog(@"Error retrieving list of PlayBooks from Core Data!  Error was:  %@", error.description);
    } else {
        NSMutableArray *retrievedNames = [[NSMutableArray alloc] init];
        for (PlayBook *book in allPlaybooks) {
            [retrievedNames addObject:book.name];
        }
        //return list of play names
        return retrievedNames;
    }
    
    return nil;
}

-(int)checkNumberPlays:(NSString*)type {
    if ([type isEqual:@"offense"]) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"OffensePlay" inManagedObjectContext:context];
        [request setEntity:entity];
        
        
        NSError *error = nil;
        NSUInteger count = [context countForFetchRequest:request error:&error];
        
        if (!error) {
            int unsignedConverted = (int)count;
            return unsignedConverted;
        } else {
            NSLog(@"error checking for offense plays! %@", error);
            return 0;
        }
    } else if ([type isEqual: @"defense"]) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DefensePlay" inManagedObjectContext:context];
        [request setEntity:entity];
        
        
        NSError *error = nil;
        NSUInteger count = [context countForFetchRequest:request error:&error];
        
        if (!error) {
            int unsignedConverted = (int)count;
            return unsignedConverted;
        } else {
            NSLog(@"error checking for save data! %@", error);
            return 0;
        }
    }
    
    return 100;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // NSLog(@"There are %i games saved to the device!!!", gamesArray.count);
    
        return [gamesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.layer.cornerRadius = 8;
    cell.frame = CGRectOffset(cell.frame, 10, 10);
    //cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = gamesArray[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:24];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, bookList.frame.size.width, 134)];
    backgroundView.layer.cornerRadius = 8;
    backgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [cell insertSubview:backgroundView belowSubview:cell.contentView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        UIView *bgView = [selectedCell.subviews objectAtIndex:0];
        bgView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        NSString *name = selectedCell.textLabel.text;
        for (int i = 0; i < backupArray.count; i ++) {
            if ([name isEqual:backupArray[i]]) {
                [backupArray removeObjectAtIndex:i];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isCopying) {
        if (indexPath.row != 0) {
            NSString *selected = gamesArray[indexPath.row];
            if ([selected isEqual:currentBook]) {
            //user picked the playbook that already contains the play to copy
                UIAlertView *existsAlert = [[UIAlertView alloc] initWithTitle:@"Play already exists" message:@"The playbook you selected is the one that already contains this play" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [existsAlert show];
            } else {
                //user picked a book that was different than the one that already contains the play
                chosenBook = gamesArray[indexPath.row];
                [self copyTo:chosenBook];
            }
            
        }
    } else {
        if (isSelecting) {
            if (indexPath.row != 0) {
                UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
                UIView *bgView = [selectedCell.subviews objectAtIndex:0];
                bgView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
                [backupArray addObject:gamesArray[indexPath.row]];
            }
        } else {
            for (UITableViewCell *cell in [bookList visibleCells]) {
                //reset all coloring for all cell's custom background views
                UIView *background = cell.subviews[0];
                background.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            }
            
            if (indexPath.row != 0) {
                //user chose an already existing game
                
                //NSLog(@"User chose game:  %@", gamesArray[indexPath.row]);
                UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
                
                //need to manually highlight the selected cell so we can "emulate" the selected state for our custom bg view
                UIView *bgView = [selectedCell.subviews objectAtIndex:0];
                bgView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
                
                bookSelected = gamesArray[indexPath.row];
                [app setCurrentPlaybook:bookSelected];
                
                //update and if necessary, enable the play buttons
                [self updateButtons];
            } else {
                //user wants to add a new game
                addNameField.text = nil;
                addNameView.hidden = NO;
                offenseBtn.enabled = NO;
                defenseBtn.enabled = NO;
                offenseCount.hidden = YES;
                defenseCount.hidden = YES;
                
                //set text entry field to first responder by default
                [addNameField becomeFirstResponder];
            }
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [addNameField resignFirstResponder];
    return YES;
}

-(void)updateButtons {
    //grab number of both offense and defense plays contained in the selected book
    NSArray *numPlays = [self getNumPlays:bookSelected];
    
    offenseCount.text = [NSString stringWithFormat:@"%li plays", (long)[[numPlays objectAtIndex:0] integerValue]];
    defenseCount.text = [NSString stringWithFormat:@"%li plays", (long)[[numPlays objectAtIndex:1] integerValue]];
    
    offenseBtn.enabled = YES;
    defenseBtn.enabled = YES;
    offenseCount.hidden = NO;
    defenseCount.hidden = NO;
    
}

//grab and return the number of offensive and defensive plays "owned" by the currently selected game/playbook
-(NSArray*)getNumPlays:(NSString*)name {
    NSMutableArray *countHolder = [[NSMutableArray alloc] initWithCapacity:2];
    
    NSFetchRequest *offenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"OffensePlay"];
    
    NSError *offenseError = nil;
    
    NSArray *fetchedOffense = [context executeFetchRequest:offenseFetch error:&offenseError];
    
    if (fetchedOffense == nil) {
    
    } else {
        int matchedCounter = 0;
        for (OffensePlay *offensePlay in fetchedOffense) {
            if ([offensePlay.owner isEqual: bookSelected]) {
                matchedCounter ++;
            }
        }
        
        [countHolder insertObject:[NSNumber numberWithInt:matchedCounter] atIndex:0];
    }
    

    NSFetchRequest *defenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"DefensePlay"];
    
    NSError *defenseError = nil;
    
    NSArray *fetchedDefense = [context executeFetchRequest:defenseFetch error:&defenseError];
    
    if (fetchedDefense == nil) {
    
    } else {
        int matchedCounter = 0;
        for (DefensePlay *defensePlay in fetchedDefense) {
            if ([defensePlay.owner isEqual: bookSelected]) {
                matchedCounter ++;
            }
        }
        
        [countHolder insertObject:[NSNumber numberWithInt:matchedCounter] atIndex:1];
    }
    
    //return the array of counts
    return countHolder;
}

//allow user to delete games/playbooks
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return false;
    } else {
        if (isCopying) {
            return false;
        }
        return true;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        itemToDelete = (int) indexPath.row;
        UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Playbook?" message:@"Are you sure you want to delete this playbook?  All plays stored within it will be lost!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        deleteAlert.tag = 1;
        [deleteAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            //user chose to delete a playbook, so remove all plays and playbook from core data
            NSString *bookName = [gamesArray objectAtIndex:itemToDelete];
            
            NSFetchRequest *bookRequest = [[NSFetchRequest alloc] initWithEntityName:@"PlayBook"];
            NSError *bookError = nil;
            
            NSArray *playbookArray = [context executeFetchRequest:bookRequest error:&bookError];
            if (playbookArray == nil) {
                NSLog(@"Error fetching all playbooks when attempting to delete one!  Error was:  %@", bookError.description);
            } else {
                for (PlayBook *book in playbookArray) {
                    if ([book.name isEqual:bookName]) {
                        [context deleteObject:book];
                        NSError *error;
                        [context save:&error];
                        break;
                    }
                }
                
                //now that we found and deleted the selected playbook, delete all plays that were stored to it
                NSFetchRequest *offenseRequest = [[NSFetchRequest alloc] initWithEntityName:@"OffensePlay"];
                NSError *offenseError = nil;
                
                NSArray *offenseArray = [context executeFetchRequest:offenseRequest error:&offenseError];
                
                if (offenseArray == nil) {
                    NSLog(@"Error fetching list of offense plays when deleting a playbook!  Error was:  %@", offenseError.description);
                } else {
                    for (OffensePlay *offensePlay in offenseArray) {
                        if ([offensePlay.owner isEqual:bookName]) {
                            [context deleteObject:offensePlay];
                            NSError *error;
                            [context save:&error];
                        }
                    }
                }
                
                NSFetchRequest *defenseRequest = [[NSFetchRequest alloc] initWithEntityName:@"DefensePlay"];
                NSError *defenseError = nil;
                
                NSArray *defenseArray = [context executeFetchRequest:defenseRequest error:&defenseError];
                
                if (defenseArray == nil) {
                    NSLog(@"Error fetching list of defensive plays when deleteing a playbook!  Error was:  %@", defenseError.description);
                } else {
                    for (DefensePlay *defensePlay in defenseArray) {
                        if ([defensePlay.owner isEqual:bookName]) {
                            [context deleteObject:defensePlay];
                            NSError *error;
                            [context save:&error];
                        }
                    }
                }
            }
            //ensure we reset our buttons so we don't let the user add plays to a playbook that was just deleted
            offenseBtn.enabled = NO;
            defenseBtn.enabled = NO;
            offenseCount.hidden = YES;
            defenseCount.hidden = YES;
            
            //actually remove the now deleted playbook from our tableView
            gamesArray = [[NSMutableArray alloc] init];
            
            [gamesArray addObject:@"New Game"];
            [gamesArray addObjectsFromArray:[self checkNumberPlaybooks]];
            
            //[gamesArray removeObjectAtIndex:itemToDelete];
            [bookList reloadData];
            [bookList reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            //backup all was selected
            bookList.userInteractionEnabled = NO;
            offenseBtn.enabled = NO;
            offenseCount.hidden = YES;
            defenseBtn.enabled = NO;
            defenseCount.hidden = YES;
            passwordView.hidden = NO;
            backupBtn.enabled = NO;
            //[app backupBooks:nil];
        } else if (buttonIndex == 2) {
            //user wants to select which playbooks are backed up
            
            //set up our array for backups in case the user chooses to back up playbooks to the clouid
            backupArray = [[NSMutableArray alloc] init];
            
            backupSelectView.hidden = NO;
            offenseBtn.enabled = NO;
            offenseCount.hidden = YES;
            defenseBtn.enabled = NO;
            defenseCount.hidden = YES;
            backupBtn.enabled = NO;
            
            //need to allow multiple selection of playbooks now
            isSelecting = true;
            bookList.allowsMultipleSelection = YES;
            [self resetCells];
        }
    } else if (alertView.tag == 3) {
        if (buttonIndex == 1) {
            //user chose to proceed to restore from Parse
            restorePasswordView.hidden = NO;
            bookList.userInteractionEnabled = NO;
            offenseBtn.enabled = NO;
            defenseBtn.enabled = NO;
            defenseCount.hidden = YES;
            offenseCount.hidden = YES;
        }
    } else if (alertView.tag == 99) {
        //user toggled the iCloud switch
        if (buttonIndex == 0) {
            //user cancelled enabling iCloud
            icloudSwitch.on = NO;
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"iCloudEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            //user chose to enable iCloud
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"iCloudEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [app toggleiCloud];
            
        }
    } else if (alertView.tag == 100) {
        //user is toggling iCloug switch to turn off
        if (buttonIndex == 0) {
            icloudSwitch.on = YES;
            
        } else {
            icloudSwitch.on = NO;
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"iCloudEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            restoringView.hidden = NO;
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"iCloudEnabled"];
            
            [app toggleiCloud];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.text = @"Select a Playbook/Game";
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.backgroundColor = [UIColor colorWithRed:0.004 green:0.494 blue:0.522 alpha:1];
    headerLabel.layer.cornerRadius = 8;
    headerLabel.clipsToBounds = YES;
    return headerLabel;
}

//this is basically another 'onClick' method to handle touch events for all buttons relating to backing up (regualr onClick was getting too crowded)
-(IBAction)backupClick:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button.tag == 0) {
    //password cancel button tapped
        passwordView.hidden = YES;
        backupBtn.enabled = YES;
        bookList.multipleTouchEnabled = NO;
        bookList.userInteractionEnabled = YES;
        isSelecting = false;
        [passwordField resignFirstResponder];
        [self resetCells];
    } else if (button.tag == 1) {
    //password submit button tapped
        NSString *inputPassword = passwordField.text;
        NSString *trimmedString = [inputPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedString.length > 0) {
            if (backupArray.count > 0) {
                [app backupBooks:backupArray password:trimmedString];
            } else {
                [app backupBooks:nil password:trimmedString];
            }
            passwordView.hidden = YES;
            backupBtn.enabled = YES;
            [passwordField resignFirstResponder];
            [self resetCells];
        } else {
            UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:@"Password Error" message:@"Please enter a valid password before continuing." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [passwordAlert show];
        }
        
    } else if (button.tag == 2) {
    //backup selection cancel button tapped
        backupSelectView.hidden = YES;
        backupBtn.enabled = YES;
        isSelecting = false;
        bookList.allowsMultipleSelection = NO;
        bookList.userInteractionEnabled = YES;
        [self resetCells];
    } else if (button.tag == 3) {
    //backup select done button tapped
         NSLog(@"Selection done");
        if (backupArray.count > 0) {
            for (int i = 0; i < backupArray.count; i ++) {
                NSString *playbookName = backupArray[i];
                NSLog(@"User chose to backup playbook:  %@", playbookName);
            }
            isSelecting = false;
            bookList.allowsMultipleSelection = NO;
            bookList.userInteractionEnabled = NO;
            backupSelectView.hidden = YES;
            passwordView.hidden = NO;
        } else {
            UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"No Playbooks selected" message:@"Please add at least one playbook to back up." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [emptyAlert show];
        }
        backupBtn.enabled = YES;
    }
}

-(void)resetCells {
    for (UITableViewCell *cell in [bookList visibleCells]) {
        UIView *bgView = [cell.subviews objectAtIndex:0];
        bgView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
    bookList.userInteractionEnabled = YES;
}

-(IBAction)restoreClick:(id)sender {
    UIButton *button = (UIButton*) sender;
    
    if (button.tag == 1) {
        restorePasswordView.hidden = YES;
        bookList.userInteractionEnabled = YES;
    } else if (button.tag == 2) {
        //ensure the user entered a password and check to see if the backup on Parse even exists before restoring
        NSString *inputPassword = restorePasswordField.text;
        NSString *trimmedString = [inputPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedString.length > 0) {
            BOOL passwordValid = [app checkPassword:trimmedString];
            if (passwordValid) {
                NSLog(@"BACKUP FOUND!");
                //hide during restoration
                restorePasswordView.hidden = YES;
                backupBtn.enabled = YES;
                restoringView.hidden = NO;
                [app restoreFromBackup:trimmedString controller:self];
            } else {
                UIAlertView *invalidAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Password" message:@"There were no cloud backups found using the supplied password." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [invalidAlert show];
            }
        } else {
            UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Please input a password to continue" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [emptyAlert show];
        }
    }
}

-(void)restoreComplete {
    restoringView.hidden = YES;
    UIAlertView *doneAlert = [[UIAlertView alloc] initWithTitle:@"Restore Complete" message:@"Backup completed successfully." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [doneAlert show];
    bookList.userInteractionEnabled = YES;
    
    gamesArray = [[NSMutableArray alloc] init];
    
    [gamesArray addObject:@"New Game"];
    [gamesArray addObjectsFromArray:[self checkNumberPlaybooks]];
    
    //in case the backup restore was done on a clean install of app
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"dataSetup"];
    [defaults synchronize];
    
    [self viewWillAppear:YES];
    [bookList reloadData];
}

-(IBAction)helpTapped:(id)sender {
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    UIImage *secondImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath,@"launch_tutorial.png"]];
    [tutorialImageView setImage:secondImage];
    
    tutorialView.hidden = NO;
    [self makeViewGlow:tutorialButton];
}

-(void)tutorialDone:(id)sender {
    
    BOOL firstFinished = [[NSUserDefaults standardUserDefaults] boolForKey:@"launchTutorialFinished"];
    BOOL secondFinished = [[NSUserDefaults standardUserDefaults] boolForKey:@"launchTutorialSecondFinished"];
    
    //detect which 'step' in the launch tutorial we're in and set values/images appropriately
    if (firstFinished == false) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"launchTutorialFinished"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (secondFinished == false) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"launchTutorialSecondFinished"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    tutorialView.hidden = YES;
}

//user chose a book to copy the play selected to, so send the name back and send the user back to the play selection controller
-(void)copyTo:(NSString*)selectedName {
    isCopying = false;
    offenseBtn.hidden = NO;
    defenseBtn.hidden = NO;
    helpButton.hidden = NO;
    rosterButton.hidden = NO;
    icloudSwitch.hidden = NO;
    offenseCount.hidden = NO;
    defenseCount.hidden = NO;
    [self performSegueWithIdentifier:@"SelectPlays" sender:self];
}

//method called when the user needs to select a playbook to copy a selected play to
-(void)copySelect:(NSString*)playName :(NSString*)bookName {
    //hide literally everything except for the playbooks, forcing the user to pick one
    offenseBtn.hidden = YES;
    defenseBtn.hidden = YES;
    helpButton.hidden = YES;
    rosterButton.hidden = YES;
    icloudSwitch.hidden = YES;
    offenseCount.hidden = YES;
    defenseCount.hidden = YES;
    copyView.hidden = NO;
    currentBook = bookName;
    
    isCopying = true;
}

//user chose not to copy the play after all, so return to the play selection view controller
-(IBAction)cancelCopy:(id)sender {
    currentBook = nil;
    chosenBook = nil;
    isCopying = false;
    offenseBtn.hidden = NO;
    defenseBtn.hidden = NO;
    helpButton.hidden = NO;
    rosterButton.hidden = NO;
    icloudSwitch.hidden = NO;
    offenseCount.hidden = NO;
    defenseCount.hidden = NO;
    [self performSegueWithIdentifier:@"SelectPlays" sender:self];
    
}










-(void)bannerViewWillLoadAd:(ADBannerView *)banner {
    NSLog(@"Ad Banner will load ad.");
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    NSLog(@"Ad banner did load ad.");
    
    //show the ad banner
    [UIView animateWithDuration:0.5 animations:^{
        banner.alpha = 1.0;
    }];
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner {
    NSLog(@"Ad Banner action did finish.");
    
   
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Unable to show ads.  Error:  %@", [error localizedDescription]);
    
    //hide the ad banner since there are no ads to display
    [UIView animateWithDuration:05 animations:^{
        banner.alpha = 0.0;
    }];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    NSLog(@"Ad Banner action is about to begin.");
    
    
    
    return YES;
}
@end
