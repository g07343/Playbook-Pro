//
//  PlaySelectionViewController.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/17/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "PlaySelectionViewController.h"
#import "CollectionViewCell.h"
#import "PlayCreationViewController.h"
#import "AppDelegate.h"
#import "OffensePlay.h"
#import "DefensePlay.h"
#import "QuartzCore/QuartzCore.h"
#import "RemotePlaySelectionViewController.h"
#import "LaunchViewController.h"
#import "PlayBook.h"

@interface PlaySelectionViewController ()

@end

@implementation PlaySelectionViewController

UITapGestureRecognizer *singleTap;
UITapGestureRecognizer *copyTap;
long currentSelected;
NSMutableArray *playTitles;
NSMutableArray *playThumbs;
NSMutableArray *printThumbs;
NSIndexPath *selected;
UIBarButtonItem *downloadItem;
UIBarButtonItem *shareItem;
UIBarButtonItem *helpItem;
NSManagedObjectContext *context;
AppDelegate *app;
NSString *deletingTitle;
UIPrintInteractionController *printController;
BOOL printSelecting;
BOOL sendingRemotePlay;
NSArray *remoteData;



@synthesize buttonChosen, printView, selectionView, containerView, launchView, chosenBook;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sendingRemotePlay = false;
    
    containerView.backgroundColor = [UIColor clearColor];
    
    self.hidesBottomBarWhenPushed = YES;
    [[self.navigationController.childViewControllers objectAtIndex:1] hidesBottomBarWhenPushed];
    
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    context = app.managedObjectContext;
    
    //NSLog(@"Passed data was:  %@", buttonChosen);
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [helpButton setImage:[UIImage imageNamed:@"help_btn.png"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp:) forControlEvents:UIControlEventTouchUpInside];
    CGRect buttonFrame = CGRectMake(0, 0, 40, 40);
    [helpButton setFrame:buttonFrame];
    helpItem = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
    
    
    //helpItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"help_btn.png"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showHelp:)];
    downloadItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onClick:)];
    shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onClick:)];
    downloadItem.tag = 0;
    shareItem.tag = 1;
    self.navigationItem.rightBarButtonItems = @[downloadItem, shareItem, helpItem];
    
    // Set up our gesture recognizer to allow deleting a play
    UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(playLongPressed:)];
    longRecognizer.minimumPressDuration = 0.5;
    longRecognizer.delegate = self;
    
    //fix for iOS7 and above
    longRecognizer.delaysTouchesBegan = YES;
    
    [self.playCollection addGestureRecognizer:longRecognizer];

    //set up a tap gesture listener for our 'delete play' icons for each CollectionView cell
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deletePlay:)];
    singleTap.numberOfTapsRequired = 1;
    
    copyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyPlay:)];
    copyTap.numberOfTapsRequired = 1;
    
    //init our mutable array to hold all of the play titles
    playTitles = [[NSMutableArray alloc] init];
    playThumbs = [[NSMutableArray alloc] init];
    
    //set our navigation bar's title to match what type of plays are being displayed
    if ([buttonChosen  isEqual: @"offense"]) {
        //[self.navigationController setTitle:@"Offensive Plays"];
        self.navigationItem.title = @"Offensive Plays";
        [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar.backItem.backBarButtonItem setTintColor:[UIColor whiteColor] ];
    } else {
        self.navigationItem.title = @"Defensive Plays";
    }
}

-(IBAction)printPlays:(id)sender {
    [self resetCellColors];
    printView.hidden = YES;
    _playCollection.allowsMultipleSelection = NO;
    printSelecting = false;
    
    Class printControllerClass = NSClassFromString(@"UIPrintInteractionController");
    if (printControllerClass) {
        printController = [printControllerClass sharedPrintController];
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        
        printInfo.jobName = [NSString stringWithFormat:@"Print play"];
        printController.printInfo = printInfo;
        
        printController.printingItems = printThumbs;
        [printController presentFromBarButtonItem:shareItem animated:YES completionHandler:completionHandler];
        
    }
}

-(void)resetCellColors {
    for(UICollectionView *cell in _playCollection.visibleCells){
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
}

-(IBAction)onClick:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button.tag == 0) {

        RemotePlaySelectionViewController *remoteController = [[RemotePlaySelectionViewController alloc] initWithNibName:@"RemotePlaySelectionViewController" bundle:nil];
        remoteController.playType = buttonChosen;
        remoteController.view.frame = containerView.bounds;
        [containerView addSubview:remoteController.view];
        [self addChildViewController:remoteController];
        [remoteController setParent:self];
        [remoteController didMoveToParentViewController:self];
        selectionView.hidden = NO;
    } else if (button.tag == 1) {
        //print tapped - check if currently enabled
        if (printSelecting) {
            printView.hidden = YES;
            _playCollection.allowsMultipleSelection = NO;
            printSelecting = false;
            playThumbs = nil;
            //[_playCollection reloadData];
        } else {
            printView.hidden = NO;
            _playCollection.allowsMultipleSelection = YES;
            printSelecting = true;
            playThumbs = [[NSMutableArray alloc] init];
        }
    }
}

-(void)doneSelecting {
    selectionView.hidden = YES;
}

-(void)resetPrint {
    [_playCollection reloadData];
}

void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
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

//this method grabs all saved plays that the user created
-(void)grabPlays:(NSString*)type {
    //need to remove all data that feeds into the collection view first
    [playTitles removeAllObjects];
    [playThumbs removeAllObjects];
    [playTitles addObject:@"Create New"];
    UIImage *addIcon = [UIImage imageNamed:@"add_icon.png"];
    [playThumbs addObject:addIcon];
    
    if ([type isEqual: @"offense"]) {
        
        //retrieve items that were just saved out to check integrity
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"OffensePlay" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *secondError = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&secondError];
        if (fetchedObjects == nil) {
            NSLog(@"Problem retrieving offensive plays!  %@", secondError);
        } else {
            //loop through objects retrieved just to ensure they made it
            for (OffensePlay *retrievedPlay in fetchedObjects) {
                
                //ensure we are only adding plays that are 'owned' by the current playbook
                NSString *playOwner = retrievedPlay.owner;
                if ([playOwner isEqual:app.currentPlaybook]) {
                    NSString *playName = retrievedPlay.playName;
                    if (playName != nil) {
                        [playTitles addObject:retrievedPlay.playName];
                    } else {
                        [playTitles addObject:@"Missing Name"];
                    }
                    UIImage *playThumb = [UIImage imageWithData:retrievedPlay.snapshot];
                    if (playThumb != nil) {
                        [playThumbs addObject:playThumb];
                    } else {
                        [context deleteObject:retrievedPlay];
                        
                        NSError *error = nil;
                        
                        if (![context save:&error]) {
                            NSLog(@"Couldn't save: %@", error);
                        }
                    }
                }
            }
        }
        
    } else if ([type isEqual: @"defense"]) {
    
        //retrieve items that were just saved out to check integrity
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DefensePlay" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *secondError = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&secondError];
        if (fetchedObjects == nil) {
            NSLog(@"Problem retrieving offensive plays!  %@", secondError);
        } else {
            //loop through objects retrieved just to ensure they made it
            for (DefensePlay *retrievedPlay in fetchedObjects) {
                //ensure we are only returning plays that belong to the current playbook
                NSString *playOwner = retrievedPlay.owner;
                if ([playOwner isEqual:app.currentPlaybook]) {
                    NSString *playName = retrievedPlay.playName;
                    if (playName != nil) {
                        [playTitles addObject:retrievedPlay.playName];
                    } else {
                        [playTitles addObject:@"Missing Name"];
                    }
                    UIImage *playThumb = [UIImage imageWithData:retrievedPlay.snapshot];
                    [playThumbs addObject:playThumb];
                }
            }
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    BOOL tutorialComplete = [[NSUserDefaults standardUserDefaults] boolForKey:@"playSelectionTutorialFinished"];
    if (!(tutorialComplete)) {
        [app toggleNavbar:true];
        tutorialView.hidden = NO;
    } else {
        tutorialView.hidden = YES;
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
    selectionView.hidden = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
    self.navigationItem.backBarButtonItem = backButton;
    [self.navigationController setNavigationBarHidden:NO];
    printView.hidden = YES;
    printSelecting = false;
    printThumbs = [[NSMutableArray alloc] init];
    //load all saved out plays (if any) into our data source arrays for display in the view
    [self grabPlays:buttonChosen];
    [_playCollection reloadData];
    
    if (chosenBook != nil) {
        [self duplicateAndSave];
    }
}

//need to manually set our collection of items to print to nil when the view disappears
-(void)viewWillDisappear:(BOOL)animated {
    printThumbs = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//pass the number of items to display within the collection view
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [playTitles count];
}

//called for each cell that needs to be created - customize and load in each cell before returning it for display
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"demoCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        //cell.playTitle.text = @"Create New";
        UIImage *addIcon = [UIImage imageNamed:@"add_icon.png"];
        cell.playThumb.image = addIcon;
    } else {
        cell.playThumb.image = [playThumbs objectAtIndex:indexPath.row];
        
        //set the imageView tag to the current indexPath.row so we know which one to delete if the user taps the delete icon
        cell.playThumb.tag = indexPath.row;
        [cell.deleteIcon addGestureRecognizer:singleTap];
        [cell.duplicateIcon addGestureRecognizer:copyTap];
    }
    cell.playTitle.text = [playTitles objectAtIndex:indexPath.row];
    cell.deleteIcon.hidden = YES;
    cell.deleteIcon.userInteractionEnabled = NO;
    cell.duplicateIcon.hidden = YES;
    cell.duplicateIcon.userInteractionEnabled = NO;
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    cell.layer.cornerRadius = 16;
    return cell;
}

//this method lets us 'send' which button was tapped, offense or defense
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"PlayCreation"]) {
        if (sendingRemotePlay) {
            //pass the array to the play creation view controller
            PlayCreationViewController *playCreate = (PlayCreationViewController *) [segue destinationViewController];
            NSString *titleToPass = [remoteData objectAtIndex:0];
            playCreate.playChosenTitle = titleToPass;
            
            //set creation view controller's bool value so we know if we are making a new play, or editing an existing one
            playCreate.remotePlayData = remoteData;
            playCreate.createNew = false;
            playCreate.isSettingUp = true;
            playCreate.playType = buttonChosen;
            sendingRemotePlay = false;
            remoteData = nil;
        } else {
            CollectionViewCell *collectionCell = (CollectionViewCell *) [self.playCollection cellForItemAtIndexPath:selected];
            NSString *playTitle = collectionCell.playTitle.text;
            
            PlayCreationViewController *playCreate = (PlayCreationViewController *) [segue destinationViewController];
            playCreate.playChosenTitle = playTitle;
            
            //set creation view controller's bool value so we know if we are making a new play, or editing an existing one
            if ([playTitle isEqual:@"Create New"]) {
                playCreate.createNew = true;
            } else {
                playCreate.createNew = false;
            }
            
            playCreate.playType = buttonChosen;
        }
    }
}


//called when user selects a play
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (printSelecting) {
        if (indexPath.row != 0) {
            //add images to an array to be printed out!
            CollectionViewCell *collectionCell = (CollectionViewCell *) [self.playCollection cellForItemAtIndexPath:indexPath];
            UIImage *cellThumb = collectionCell.playThumb.image;
            collectionCell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
            [printThumbs addObject:cellThumb];
        }
        
    } else {
        //set to global var so we can quickly pass the title on to the creation view controller within prepareForSegue
        selected = indexPath;
        NSLog(@"Item %li selected by user!", (long)indexPath.row);
        [self performSegueWithIdentifier:@"PlayCreation" sender:self];
    }
}


-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Cell %li deselected!", (long)indexPath.row);
    if (indexPath.row != 0) {
        CollectionViewCell *collectionCell = (CollectionViewCell *) [self.playCollection cellForItemAtIndexPath:indexPath];
        UIImage *cellThumb = collectionCell.playThumb.image;
        for (int i = 0; i < printThumbs.count; i ++) {
            if ([cellThumb isEqual:printThumbs[i]]) {
                [printThumbs removeObjectAtIndex:i];
                break;
            }
        }
        collectionCell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    }
}

//handle the user long pressing a play item within the colleciton view, enabling deletion
-(void)playLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint point = [gestureRecognizer locationInView:self.playCollection];
    
    NSIndexPath *indexPath = [self.playCollection indexPathForItemAtPoint:point];
    if (indexPath ==  nil) {
        return;
    } else {
        //item long pressed, so reset all other cells to default
        [self resetDelete:(indexPath)];
        
        //create and cast custom cell to the item long pressed to access it's child views
        CollectionViewCell *collectionCell = (CollectionViewCell *) [self.playCollection cellForItemAtIndexPath:indexPath];
        
        //ensure that we aren't allowing the user to delete the 'add new play' cell
        if (!(indexPath.row == 0)) {
            collectionCell.deleteIcon.hidden = NO;
            collectionCell.deleteIcon.userInteractionEnabled = YES;
            [collectionCell.deleteIcon addGestureRecognizer:singleTap];
            
            collectionCell.duplicateIcon.hidden = NO;
            collectionCell.duplicateIcon.userInteractionEnabled = YES;
            [collectionCell.duplicateIcon addGestureRecognizer:copyTap];
            
            //set global var to match the selected indexPath in case the user wants to delete it
            selected = [self.playCollection indexPathForCell:collectionCell];
            currentSelected = selected.row;
            deletingTitle = collectionCell.playTitle.text;
        
        }
    }
}

-(void)resetDelete:(NSIndexPath *)indexPath {
    
    for(CollectionViewCell *cell in self.playCollection.visibleCells){
        NSIndexPath *currentPath = [self.playCollection indexPathForCell:cell];
        if (currentPath != indexPath) {
            cell.deleteIcon.hidden = YES;
            cell.duplicateIcon.hidden = YES;
            cell.deleteIcon.userInteractionEnabled = NO;
            cell.duplicateIcon.userInteractionEnabled = NO;
        }
    }
}


-(void)deletePlay:(UIImageView *)imageView {
    
    //user tapped the delete icon, so display the dreaded "this cannot be undone!" dialog
    CollectionViewCell *collectionCell = (CollectionViewCell *) [self.playCollection cellForItemAtIndexPath:selected];
    NSString *selectedTitle = collectionCell.playTitle.text;
    NSString *completeMessage = [NSString stringWithFormat:@"Are you sure you want to delete %@?  This cannot be undone!", selectedTitle];
    
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Play" message:completeMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [deleteAlert show];
   
}

-(void)copyPlay:(UITapGestureRecognizer*)gesture {
    //user tapped the 'copy' icon after long pressing a play, so allow them to copy to another playbook
    NSString *current = [app currentPlaybook];
    [launchView copySelect:deletingTitle :current];
    NSLog(@"Copy play tapped!");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)duplicateAndSave {
    //grab the chosen playbook and copy a new instance of the Play Entity to add to it
    NSLog(@"Duplicate and save called with the book selected as:  %@", chosenBook);
    PlayBook *foundBook;
    //grab the playbook to ensure it doesn't already have a play with the same title
    NSFetchRequest *bookFetch = [[NSFetchRequest alloc] initWithEntityName:@"PlayBook"];
    NSArray *allBooks = [context executeFetchRequest:bookFetch error:nil];
    if (allBooks != nil && allBooks.count > 0) {
        //deletingTitle
        for (PlayBook *book in allBooks) {
            if ([book.name isEqual:deletingTitle]) {
                foundBook = book;
                break;
            }
        }
        //now that we have the correct playbook, check to ensure there isn't already a play by this name contained in it
        NSFetchRequest *offenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"OffensePlay"];
        NSArray *allOffense = [context executeFetchRequest:offenseFetch error:nil];
        NSFetchRequest *defenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"DefensePlay"];
        NSArray *allDefense = [context executeFetchRequest:defenseFetch error:nil];
        
        if (allOffense != nil && allOffense.count > 0) {
            for (OffensePlay *play in allOffense) {
                if ([play.playName isEqual:deletingTitle] && [play.owner isEqual:chosenBook]) {
                    //book already has the play so alert the user
                    NSString *alertString = [NSString stringWithFormat:@"A play with the name \'%@\' already exists in the playbook titled \'%@\'.", deletingTitle, chosenBook];
                    UIAlertView *duplicateAlert = [[UIAlertView alloc] initWithTitle:@"Play already exists" message:alertString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                    
                    chosenBook = nil;
                    [duplicateAlert show];
                    return;
                }
            }
        }
        
        if (allDefense != nil && allDefense.count > 0) {
            for (DefensePlay *play in allDefense) {
                if ([play.playName isEqual:deletingTitle] && [play.owner isEqual:chosenBook]) {
                    NSString *alertString = [NSString stringWithFormat:@"A play with the name \'%@\' already exists in the playbook titled \'%@\'.", deletingTitle, chosenBook];
                    UIAlertView *duplicateAlert = [[UIAlertView alloc] initWithTitle:@"Play already exists" message:alertString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                    
                    chosenBook = nil;
                    [duplicateAlert show];
                    return;
                }
            }
        }
    }
    if ([buttonChosen isEqual:@"offense"]) {
        NSFetchRequest *offenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"OffensePlay"];
        NSArray *allOffense = [context executeFetchRequest:offenseFetch error:nil];
        OffensePlay *playtoCopy;
        for (OffensePlay *play in allOffense) {
            if ([play.playName isEqual:deletingTitle] && [play.owner isEqual:[app currentPlaybook]]) {
                playtoCopy = play;
                break;
            }
        }
        //duplicate play in its entirety before copying it over to the selected playbook
        OffensePlay *newPlay = [NSEntityDescription insertNewObjectForEntityForName:@"OffensePlay" inManagedObjectContext:context];
        NSDictionary *offenseAttributes = [[NSEntityDescription entityForName:@"OffensePlay" inManagedObjectContext:context] attributesByName];
        for (NSString *attr in offenseAttributes) {
            [newPlay setValue:[playtoCopy valueForKey:attr] forKey:attr];
        }
        //manually set the 'owner' attribute to the selected book before saving
        newPlay.owner = chosenBook;
        NSError *saveError;
        [context save:&saveError];
    } else {
        NSFetchRequest *defenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"DefensePlay"];
        NSArray *allDefense = [context executeFetchRequest:defenseFetch error:nil];
        DefensePlay *playtoCopy;
        for (DefensePlay *play in allDefense) {
            if ([play.playName isEqual:deletingTitle] && [play.owner isEqual:[app currentPlaybook]]) {
                playtoCopy = play;
                break;
            }
        }
        DefensePlay *newPlay = [NSEntityDescription insertNewObjectForEntityForName:@"DefensePlay" inManagedObjectContext:context];
        NSDictionary *offenseAttributes = [[NSEntityDescription entityForName:@"DefensePlay" inManagedObjectContext:context] attributesByName];
        for (NSString *attr in offenseAttributes) {
            [newPlay setValue:[playtoCopy valueForKey:attr] forKey:attr];
        }
        //manually set the 'owner' attribute to the selected book before saving
        newPlay.owner = chosenBook;
        NSError *saveError;
        [context save:&saveError];
    }
    //alert the user that the play was copied over
    UIAlertView *copiedAlert = [[UIAlertView alloc] initWithTitle:@"Copy Successful" message:@"The selected play was copied successfully." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [copiedAlert show];
    
    //get rid of the name of the selected book since we no longer need it
    chosenBook = nil;
}

//only delete the selected play if the user confirms via the dialog
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.playCollection performBatchUpdates:^{
            [playTitles removeObjectAtIndex:currentSelected];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelected inSection:0];
            [self.playCollection deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            [self.playCollection reloadData];
            
            //actually delete the play object from Core Data
            if ([buttonChosen isEqual:@"offense"]) {
                //grab offense plays and find the one to delete
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"OffensePlay" inManagedObjectContext:context];
                [fetchRequest setEntity:entity];
                
                NSError *error = nil;
                NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
                if (fetchedObjects == nil) {
                    NSLog(@"Error deleting an offensive play!  %@", error);
                } else {
                    
                    
                    for (OffensePlay *play in fetchedObjects) {
                        
                        if ([play.playName isEqual:deletingTitle] && [play.owner isEqual:[app currentPlaybook]]) {
                            NSLog(@"deleting play!");
                            [context deleteObject:play];
                            
                            NSError *error = nil;
                            
                            if (![context save:&error]) {
                                NSLog(@"Couldn't save: %@", error);
                            }
                        }
                    }
                }
            } else {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"DefensePlay" inManagedObjectContext:context];
                [fetchRequest setEntity:entity];
                
                NSError *error = nil;
                NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
                if (fetchedObjects == nil) {
                    NSLog(@"Error deleting an offensive play!  %@", error);
                } else {
                    for (DefensePlay *play in fetchedObjects) {
                        if ([play.playName isEqual:deletingTitle] && [play.owner isEqual:[app currentPlaybook]]) {
                            NSLog(@"deleting play!");
                            [context deleteObject:play];
                            
                            NSError *error = nil;
                            
                            if (![context save:&error]) {
                                NSLog(@"Couldn't save: %@", error);
                            }
                        }
                    }
                    
                }
            }
        } completion:^(BOOL finished){
            
        }];
    }
}

-(void)loadRemote:(NSArray*)remotePlay {
    sendingRemotePlay = true;
    remoteData = remotePlay;
    
    //remove the remote view controller 
    [[[self childViewControllers] objectAtIndex:0] removeFromParentViewController];
    [self performSegueWithIdentifier:@"PlayCreation" sender:self];
}

-(void)showHelp:(id)sender {
    self.navigationController.navigationBar.hidden = YES;
    tutorialView.hidden = NO;
}

-(IBAction)tutorialDone:(id)sender {
    tutorialView.hidden = YES;
    self.navigationController.navigationBar.hidden = NO;
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"playSelectionTutorialFinished"];
}

@end
