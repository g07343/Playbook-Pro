//
//  PlayCreationViewController.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/19/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "PlayCreationViewController.h"
#import "SWRevealViewController.h"
#import "PlayerTokenViewController.h"
#import "PlaySelectionViewController.h"
#import "AppDelegate.h"
#import "Player.h"
#import "OffensePlay.h"
#import "DefensePlay.h"
#import "PlaySettingsViewController.h"

//remove this import later since it's only added to upload plays to Parse
#import <Parse/Parse.h>

@interface PlayCreationViewController ()

@end

@implementation PlayCreationViewController

@synthesize red, blue, green, opacity, brush, lastPoint, mouseSwiped, isSettingUp, eraserOn, bgImage, playChosenTitle, container1, container2, container3, container4, container5, container6, container7, container8, container9, container10, container11, player1, player2, player3, player4, player5, player6, player7, player8, player9, player10, player11, darkOverlay, nameField, rosterHelper, playerToSwap, createNew, playType, allContainers, allViewControllers, remotePlayData, opposingPlayer1, opposingPlayer2, opposingPlayer3, opposingPlayer4, opposingPlayer5, opposingPlayer6, opposingPlayer7, opposingPlayer8, opposingPlayer9, opposingPlayer10, opposingPlayer11, layoutSelected;

BOOL drawingEnabled;
BOOL hasDrawn;
BOOL drawerOpen;
BOOL currentlyDragging;
BOOL isTakingPicture;
BOOL userWarned;
UIBarButtonItem *drawItem;
UIBarButtonItem *settingsItem;
UIBarButtonItem *rosterItem;
UIBarButtonItem *saveItem;

//remove this if publising app!
UIBarButtonItem *parseSave;
//

SWRevealViewController *revealViewController;
//NSMutableArray *allContainers;
//NSMutableArray *allViewControllers;
UILongPressGestureRecognizer *longRecognizer;
UILongPressGestureRecognizer *dragRecognizer;
UITapGestureRecognizer *tapRecognizer;
UITapGestureRecognizer *secondTap;
UITapGestureRecognizer *cancelTap;
UIImagePickerController *imagePickerController;
PlayerTokenViewController *selectedPlayer;
UIImageView *selectedImage;
int currentSelected = 999;
NSMutableArray *matchedPlayer;
NSManagedObjectContext *context;
AppDelegate *app;
DefensePlay *defensePlay;
OffensePlay *offensePlay;
UIImage *transparent;
NSMutableArray *correctPlayers;
NSMutableArray *playerHolder;
NSString *swappedName;
NSTimer* autoTimer;
NSMutableArray *opposingPlayerArray;
NSMutableArray *opposingCoords;
NSMutableArray *opposingOriginalCoords;
UIButton *nextButton;
UIImageView *tutorialImageView;
UIView *tutorialView;
UIButton *skipTutorial;
UIPageControl *tutorialControl;
int tutorialCounter;
NSArray *tutorialImages;
NSMutableArray *positionsArray;
NSString *positionToSwap;

-(void)resetController {
    defensePlay = nil;
    offensePlay = nil;
    [matchedPlayer removeAllObjects];
    currentSelected = 999;
    selectedPlayer = nil;
    for (PlayerTokenViewController *player in allViewControllers) {
        player.playerName = nil;
        player.position = nil;
        player.xPosition = 0;
        player.yPosition = 0;
        player.imageFile = nil;
        drawingEnabled = false;
        hasDrawn = false;
        drawerOpen = false;
        currentlyDragging = false;
        isSettingUp = false;
        playChosenTitle = nil;
        
        _tempCanvas.image = nil;
        _drawingCanvas.image = nil;
        opposingCoords = opposingOriginalCoords;
        
        //reset image views to their default layout
        for (int i = 0; i < opposingCoords.count; i ++) {
            NSArray *oldCoords = opposingOriginalCoords[i];
            [opposingCoords replaceObjectAtIndex:i withObject:oldCoords];
        }
        
    }
    
    //need to remove this observer so it doesn't interfere with UITextField editing within the Launch Controller
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(IBAction)tutorialNext:(id)sender {
    if (tutorialCounter == 3) {
        tutorialView.hidden = YES;
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"editTutorialCompleted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tutorialView removeFromSuperview];
        
    } else if (tutorialCounter < 3) {
        tutorialCounter ++;
        tutorialImageView.image = nil;
        
        //use this method to grab our images instead of "imageNamed", since the latter causes nearly 60mb for the four tutorial images as it caches them!
        NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
        UIImage *test = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath,tutorialImages[tutorialCounter]]];
        
        UIImage *currentImage = test;
        tutorialImageView.image = currentImage;
        tutorialControl.currentPage = tutorialCounter;
        if (tutorialCounter == 3) {
            [nextButton setTitle:@"Got It!" forState:UIControlStateNormal];
        }
    }
}

-(IBAction)skipTutorial:(id)sender {
    tutorialView.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"editTutorialCompleted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [tutorialImageView removeFromSuperview];
    [tutorialView removeFromSuperview];
}

-(void)tutorialSwipe:(UISwipeGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        //user swipped right so go back to previous tutorial screen
        if (tutorialCounter > 0) {
            tutorialCounter --;
            tutorialImageView.image = nil;
            
            //use this method to grab our images instead of "imageNamed", since the latter causes nearly 60mb for the four tutorial images as it caches them!
            NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
            UIImage *test = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath,tutorialImages[tutorialCounter]]];
        
            //UIImage *currentImage = [UIImage imageNamed:tutorialImages[tutorialCounter]];
            tutorialImageView.image = test;
            tutorialControl.currentPage = tutorialCounter;
            [nextButton setTitle:@"Next" forState:UIControlStateNormal];
        }
    } else {
        //user swipped left so go forward to next tutorial screen
        if (tutorialCounter < 3) {
            tutorialCounter ++;
            tutorialImageView.image = nil;
            
            //use this method to grab our images instead of "imageNamed", since the latter causes nearly 60mb for the four tutorial images as it caches them!
            NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
            UIImage *test = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath,tutorialImages[tutorialCounter]]];
            
            UIImage *currentImage = test;
            tutorialImageView.image = currentImage;
            tutorialControl.currentPage = tutorialCounter;
            if (tutorialCounter == 3) {
                [nextButton setTitle:@"Got It!" forState:UIControlStateNormal];
            }
        }
        
    }
}

-(void)startTutorial {
    tutorialImages = [[NSArray alloc] initWithObjects:@"player_drag.png",@"player_edit.png",@"player_swap",@"menu_bar", nil];
    tutorialCounter = 0;
    
    CGRect tutorialFrame = CGRectMake([[UIApplication sharedApplication] delegate].window.frame.origin.x, [[UIApplication sharedApplication] delegate].window.frame.origin.y, [[UIApplication sharedApplication] delegate].window.frame.size.width, [[UIApplication sharedApplication] delegate].window.frame.size.height);
    
    tutorialView = [[UIView alloc] initWithFrame:tutorialFrame];
    tutorialImageView = [[UIImageView alloc] initWithFrame:tutorialFrame];
    [tutorialImageView setImage:[UIImage imageNamed:@"player_drag.png"]];
    [tutorialView addSubview:tutorialImageView];
    
    skipTutorial = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 80, 150, 80)];
    [skipTutorial setTitle:@"Skip Tutorial" forState:UIControlStateNormal];
    [tutorialView addSubview:skipTutorial];
    [skipTutorial addTarget:self action:@selector(skipTutorial:) forControlEvents:UIControlEventTouchUpInside];
    
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 150, self.view.frame.size.height - 80, 150, 80)];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [tutorialView addSubview:nextButton];
    [nextButton addTarget:self action:@selector(tutorialNext:) forControlEvents:UIControlEventTouchUpInside];
    
    [nextButton setTitleColor:[UIColor colorWithRed:0.137 green:0.51 blue:0.902 alpha:1] forState:UIControlStateNormal];
    [skipTutorial setTitleColor:[UIColor colorWithRed:0.137 green:0.51 blue:0.902 alpha:1] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [skipTutorial setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    tutorialControl = [[UIPageControl alloc] initWithFrame:CGRectMake(412, self.view.frame.size.height - 90, 200, 100)];
    [tutorialControl setNumberOfPages:4];
    //tutorialControl.view.Center = tutorialView.superview.center;
    
    [tutorialView addSubview:tutorialControl];
    
    //add gestures to allow swiping between pages
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [tutorialView addGestureRecognizer:swipeLeft];
    [tutorialView addGestureRecognizer:swipeRight];
    
    
    
    [[[UIApplication sharedApplication] delegate].window addSubview:tutorialView];
}

- (void)viewDidLoad {
    
    BOOL tutorialCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:@"editTutorialCompleted"];
    if (! tutorialCompleted) {
        [self startTutorial];
    }
    
    //set the values for the original positions of the opposing players so we can reset them between reloads of this controller
    NSArray *array0 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 35.0f], [NSNumber numberWithFloat: 153], nil];
    NSArray *array1 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 136.0f], [NSNumber numberWithFloat: 256], nil];
    NSArray *array2 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 276.0f], [NSNumber numberWithFloat: 258], nil];
    NSArray *array3 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 444.0f], [NSNumber numberWithFloat: 260], nil];
    NSArray *array4 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 610.0f], [NSNumber numberWithFloat: 260], nil];
    NSArray *array5 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 743.0f], [NSNumber numberWithFloat: 260], nil];
    NSArray *array6 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 515.0f], [NSNumber numberWithFloat: 160], nil];
    NSArray *array7 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 357.0f], [NSNumber numberWithFloat: 160], nil];
    NSArray *array8 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 832.0f], [NSNumber numberWithFloat: 159], nil];
    NSArray *array9 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 243.0f], [NSNumber numberWithFloat: 61], nil];
    NSArray *array10 = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat: 615.0f], [NSNumber numberWithFloat: 60], nil];
    
    opposingOriginalCoords = [[NSMutableArray alloc] initWithObjects:array0, array1, array2, array3, array4, array5, array6, array7, array8, array9, array10, nil];
    
    isTakingPicture = false;
    //set up our two vars that give us what we need to work with Core Data
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    context = app.managedObjectContext;
    
    //method to disable iOS7's swipe to navigate view controllers option, which conflicts with drawing in some instances here
    [self disableAnnoyingSwipe];
    
    //set the helper view that appear when using the player roster slide out menu to be invisible by default
    rosterHelper.hidden = YES;
    
    //set our view controller to handle when the user closes the keyboard, in the event they are updating a player's name
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //make our overlay and name entry fields invisible
    darkOverlay.hidden = YES;
    nameField.hidden = YES;
    
    currentlyDragging = NO;
    
    [nameField setDelegate:self];
    
    allContainers = [[NSMutableArray alloc] initWithObjects:container1,container2, container3, container4, container5, container6, container7, container8, container9, container10, container11, nil];
    
    opposingPlayerArray = [[NSMutableArray alloc] initWithObjects:opposingPlayer1, opposingPlayer2, opposingPlayer3, opposingPlayer4, opposingPlayer5, opposingPlayer6, opposingPlayer7, opposingPlayer8, opposingPlayer9, opposingPlayer10, opposingPlayer11, nil];
    
    
    for (int i = 0; i < allContainers.count; i++) {
        UIView *view = allContainers[i];
        longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(playerLongPressed:)];
        longRecognizer.minimumPressDuration = 0.3;
        longRecognizer.delegate = self;
        //fix for iOS7 and above
        longRecognizer.delaysTouchesBegan = YES;
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTapped:)];
        
        tapRecognizer.delegate = self;
        tapRecognizer.delaysTouchesBegan = YES;
        
        [view addGestureRecognizer:longRecognizer];
        [view addGestureRecognizer:tapRecognizer];
        if (i == 10) {
            [container11 addGestureRecognizer:longRecognizer];
            [container11 addGestureRecognizer:tapRecognizer];
        }
    }
    
    for (UIImageView *opposingPlayer in opposingPlayerArray) {
        opposingPlayer.userInteractionEnabled = YES;
        dragRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(opposingPlayerLongPressed:)];
        
        //apply the gesture recognizer so that the user can press on an 'opposing' player and reposition them
        dragRecognizer.delegate = self;
        dragRecognizer.delaysTouchesBegan = YES;
        dragRecognizer.minimumPressDuration = 1.0;
        dragRecognizer.numberOfTapsRequired = 0;
        [opposingPlayer addGestureRecognizer:dragRecognizer];
        
        
//        NSNumber *xVal = [NSNumber numberWithFloat:opposingPlayer.frame.origin.x];
//        NSNumber *yVal = [NSNumber numberWithFloat:opposingPlayer.frame.origin.y];
//        
//        //add the current onscreen coordinates to an array for tracking/updating/saving
//        NSArray *coords = [[NSArray alloc] initWithObjects:xVal, yVal, nil];
//        [opposingCoords addObject:coords];
    }
    
    //set the navigation bar title to reflect what was passed, and retrieve our players that were saved if it's not the default title of 'Create New'
    if (playChosenTitle != nil) {
        self.navigationItem.title = playChosenTitle;
        
    } else {
        self.navigationItem.title = @"Create New";
    }
    
    //
    
    
    //set drawing 'off' by default
    drawingEnabled = false;
    _redButton.hidden = YES;
    _blueButton.hidden = YES;
    _blackButton.hidden = YES;
    _eraserButton.hidden = YES;
    
    //set our drawerOpen bool to false, which we'll use to keep track of if the settings drawer is open
    drawerOpen = false;
    
    //manually add our Navigation items
    UIImage *drawIcon = [UIImage imageNamed:@"marker_icon.png"];
    drawItem = [[UIBarButtonItem alloc] initWithImage:drawIcon style:UIBarButtonItemStylePlain target:self action:@selector(onClick:)];
    drawItem.tag = 4;
    
    //manually add our settings icon
    UIImage *settingsIcon = [UIImage imageNamed:@"settings_icon.png"];
    
    settingsItem = [[UIBarButtonItem alloc] initWithImage:settingsIcon style:UIBarButtonItemStylePlain target:self action:@selector(onClick:)];
    settingsItem.tag = 0;
    
    //manually add the roster icon
    UIImage *rosterIcon = [UIImage imageNamed:@"roster_icon.png"];
    rosterItem = [[UIBarButtonItem alloc]initWithImage:rosterIcon style:UIBarButtonItemStylePlain target:self action:@selector(onClick:)];
    rosterItem.tag = 5;
    
    //manually add a save button
    saveItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(onClick:)];
    saveItem.tag = 7;
    
    //this button is only here to allow creation of downloadable plays hosted on Parse and should be removed from the final published product!
    //parseSave = [[UIBarButtonItem alloc] initWithTitle:@"Parse" style:UIBarButtonItemStylePlain target:self action:@selector(onClick:)];
    //parseSave.tag = 8;
    
    self.revealViewController.rearViewRevealWidth = 400; //default is 260!
    self.revealViewController.rightViewRevealWidth = 90;
    
    self.navigationItem.rightBarButtonItems = @[settingsItem, drawItem, rosterItem, saveItem];
    
    
    revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.settingsButton setTarget:self.revealViewController];
        //[self.settingsButton setAction:@selector(revealToggle:)];
        [self.settingsButton setAction:@selector(disableDrawing)];
        
        [rosterItem setTarget:self.revealViewController];
        [rosterItem setAction:@selector(rightRevealToggle:)];
        
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        
    } else {
        NSLog(@"Reveal view controller was nil!");
    }
    
    
    //set our drawing variables to default values
    red = 0.0/255.0;
    blue = 0.0/255.0;
    green = 0.0/255.0;
    brush = 10.0;
    opacity = 1.0;
    eraserOn = false;
    
    [super viewDidLoad];
}

-(void)setUpPlay:(NSString*)name {
    playerHolder = [[NSMutableArray alloc] init];
    NSLog(@"setUpPlay called with passed:  %@", name);
    
    //first grab all of the players appropriate to the playType
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *secondError = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&secondError];
    if (fetchedObjects == nil) {
        NSLog(@"Problem retrieving objects!  %@", secondError);
    }
    //set up an array to hold only players who belong to the appropriate roster
    correctPlayers = [[NSMutableArray alloc] init];
    
    //add only players that match the current playType (offense or defense) to the array
    for (Player *retrievedPlayer in fetchedObjects) {
        if ([retrievedPlayer.team isEqual:playType] || [retrievedPlayer.team isEqual:@"special"]) {
            //NSLog(@"Player retrieved position:  %@", retrievedPlayer.position);
            [correctPlayers addObject:retrievedPlayer];
        }
    }
    
    if (name != nil) {
    //name was not nil so grab the existing play and load it in
        
        NSArray *array0 = [[NSArray alloc] initWithObjects:@"x0x",@"x0y", nil];
        NSArray *array1 = [[NSArray alloc] initWithObjects:@"x1x",@"x1y", nil];
        NSArray *array2 = [[NSArray alloc] initWithObjects:@"x2x",@"x2y", nil];
        NSArray *array3 = [[NSArray alloc] initWithObjects:@"x3x",@"x3y", nil];
        NSArray *array4 = [[NSArray alloc] initWithObjects:@"x4x",@"x4y", nil];
        NSArray *array5 = [[NSArray alloc] initWithObjects:@"x5x",@"x5y", nil];
        NSArray *array6 = [[NSArray alloc] initWithObjects:@"x6x",@"x6y", nil];
        NSArray *array7 = [[NSArray alloc] initWithObjects:@"x7x",@"x7y", nil];
        NSArray *array8 = [[NSArray alloc] initWithObjects:@"x8x",@"x8y", nil];
        NSArray *array9 = [[NSArray alloc] initWithObjects:@"x9x",@"x9y", nil];
        NSArray *array10 = [[NSArray alloc] initWithObjects:@"x10x",@"x10y", nil];
        NSArray *attributeNames = [[NSArray alloc] initWithObjects:array0, array1, array2, array3, array4, array5, array6, array7, array8, array9, array10, nil];
        
        //ensure we have default coord values established so we can replace later
        if (opposingCoords == nil || opposingCoords.count == 0) {
            opposingCoords = [[NSMutableArray alloc] init];
            for (int i = 0; i < opposingPlayerArray.count; i ++) {
                UIImageView *currentImage = opposingPlayerArray[i];
                NSNumber *xVal = [NSNumber numberWithFloat:currentImage.frame.origin.x];
                NSNumber *yVal = [NSNumber numberWithFloat:currentImage.frame.origin.y];
                NSArray *coordsArray = [[NSArray alloc] initWithObjects:xVal, yVal, nil];
                [opposingCoords addObject:coordsArray];
            }
            
        }
        
        if ([playType isEqual:@"offense"]) {
        //play is an offense play, so grab it from Core Data using passed name
            NSFetchRequest *fetchOffensePlays = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"OffensePlay" inManagedObjectContext:context];
            [fetchOffensePlays setEntity:entity];
            
            NSError *offenseError = nil;
            NSArray *fetchedOffensePlays = [context executeFetchRequest:fetchOffensePlays error:&offenseError];
            if (fetchedOffensePlays == nil) {
                NSLog(@"Error retrieving list of offensive plays!  %@", offenseError);
            } else {
                for (OffensePlay *currentOffensePlay in fetchedOffensePlays) {
                    if ([currentOffensePlay.owner isEqual:app.currentPlaybook]) {
                        if ([currentOffensePlay.playName isEqual:playChosenTitle]) {
                            offensePlay = currentOffensePlay;
                            break;
                        }
                    }
                }
                
                //restore the correct theme that the user last saved out
                [self updateTheme:offensePlay.theme];
                NSData *utilityData = offensePlay.utilityPlayers;
                NSArray *utilityArray = [NSKeyedUnarchiver unarchiveObjectWithData:utilityData];
                
                //now that we have the selected play object, grab and set all of it's data
                if (offensePlay.drawCanvas != nil) {
                    UIImage *drawnImage = [UIImage imageWithData:offensePlay.drawCanvas];
                    self.drawingCanvas.image = drawnImage;
                }
                
                //now that we have the saved play, load in the players from it into our waiting view controllers/views
                for (int i = 0; i < 11; i++) {
                    PlayerTokenViewController *playerToken = (PlayerTokenViewController*) allViewControllers[i];
                    switch (i) {
                        case 0:
                            playerToken.playerName = offensePlay.player0Name;
                            playerToken.xPosition = [offensePlay.player0X floatValue];
                            playerToken.yPosition = [offensePlay.player0Y floatValue];
                            break;
                        case 1:
                            playerToken.playerName = offensePlay.player1Name;
                            playerToken.xPosition = [offensePlay.player1X floatValue];
                            playerToken.yPosition = [offensePlay.player1Y floatValue];
                            break;
                        case 2:
                            playerToken.playerName = offensePlay.player2Name;
                            playerToken.xPosition = [offensePlay.player2X floatValue];
                            playerToken.yPosition = [offensePlay.player2Y floatValue];
                            break;
                        case 3:
                            playerToken.playerName = offensePlay.player3Name;
                            playerToken.xPosition = [offensePlay.player3X floatValue];
                            playerToken.yPosition = [offensePlay.player3Y floatValue];
                            break;
                        case 4:
                            playerToken.playerName = offensePlay.player4Name;
                            playerToken.xPosition = [offensePlay.player4X floatValue];
                            playerToken.yPosition = [offensePlay.player4Y floatValue];
                            break;
                        case 5:
                            playerToken.playerName = offensePlay.player5Name;
                            playerToken.xPosition = [offensePlay.player5X floatValue];
                            playerToken.yPosition = [offensePlay.player5Y floatValue];
                            break;
                        case 6:
                            playerToken.playerName = offensePlay.player6Name;
                            playerToken.xPosition = [offensePlay.player6X floatValue];
                            playerToken.yPosition = [offensePlay.player6Y floatValue];
                            break;
                        case 7:
                            playerToken.playerName = offensePlay.player7Name;
                            playerToken.xPosition = [offensePlay.player7X floatValue];
                            playerToken.yPosition = [offensePlay.player7Y floatValue];
                            break;
                        case 8:
                            playerToken.playerName = offensePlay.player8Name;
                            playerToken.xPosition = [offensePlay.player8X floatValue];
                            playerToken.yPosition = [offensePlay.player8Y floatValue];
                            break;
                        case 9:
                            playerToken.playerName = offensePlay.player9Name;
                            playerToken.xPosition = [offensePlay.player9X floatValue];
                            playerToken.yPosition = [offensePlay.player9Y floatValue];
                            break;
                        case 10:
                            playerToken.playerName = offensePlay.player10Name;
                            playerToken.xPosition = [offensePlay.player10X floatValue];
                            playerToken.yPosition = [offensePlay.player10Y floatValue];
                            break;
                            
                        default:
                            break;
                    }
                }
                
                NSFetchRequest *fetchOffensePlayers = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
                [fetchOffensePlayers setEntity:entity];
                
                NSError *offensePlayerError = nil;
                NSArray *fetchedOffensePlayers = [context executeFetchRequest:fetchOffensePlayers error:&offensePlayerError];
                if (fetchedOffensePlayers == nil) {
                    NSLog(@"Error retrieving players within offensive play setup:  %@", offensePlayerError);
                } else {
                    
                    //add images and positions after retrieving list of offensive roster players using the players' names
                    for (int i = 0; i < allViewControllers.count; i ++) {
                        Player *foundPlayer;
                        PlayerTokenViewController *currentPlayerController = allViewControllers[i];
                        UIView *view = allContainers[i];
                        
                        //loop through entire roster and grab the correct player by name
                        for (int x = 0; x < fetchedOffensePlayers.count; x++) {
                            Player *currentPlayer = fetchedOffensePlayers[i];
                            
                            if ([currentPlayerController.playerName isEqual:currentPlayer.name]) {
                                foundPlayer = currentPlayer;
                                break;
                            }
                        }
                        //set values from the found player before iterating and repeating for remaining view controllers
                        
                        
                        view.frame = CGRectMake(currentPlayerController.xPosition, currentPlayerController.yPosition, view.frame.size.width, view.frame.size.height);
                        currentPlayerController.viewWidth = view.frame.size.width;
                        currentPlayerController.viewHeight = view.frame.size.height;
                        NSString *playerName = currentPlayerController.playerName;
                        currentPlayerController.position = [self getPlayerPosition:playerName];
                        UIImage *playerImage = [self getPlayerImage:playerName];
                        currentPlayerController.imageFile = playerImage;
                        currentPlayerController.playerPicture.image = playerImage;
                        currentPlayerController.nameHolder.text = currentPlayerController.playerName;
                        
                        if (utilityArray.count > 0) {
                            for (NSArray *utilityPlayer in utilityArray) {
                                if (utilityPlayer.count > 0) {
                                    
                                    NSString *thisName = currentPlayerController.playerName;
                                    NSString *utilityName = [utilityPlayer objectAtIndex:0];
                                    NSLog(@"Checking current player:  %@    against stored utility player:  %@", thisName, utilityName);
                                    if ([thisName isEqual:utilityName]) {
                                        currentPlayerController.isUtility = true;
                                        currentPlayerController.position = utilityPlayer[1];
                                        NSLog(@"PLAYER MATCH FOR UTILITY!");
                                    }
                                }
                            }
                        }
                        
                        
                    }
                
                }
                
//                for (NSArray *utilityPlayer in utilityArray) {
//                    NSString *name = utilityPlayer[0];
//                    NSString *position = utilityPlayer[1];
//                    NSLog(@"UTILITY NAME:  %@    UTILITY POSITION:  %@", name, position);
//                }
                
//                for (int i = 0; i < allViewControllers.count; i++) {
//                    PlayerTokenViewController *token = allViewControllers[i];
//                    if (utilityArray.count > 0) {
//                        for (NSArray *utilityPlayer in utilityArray) {
//                            if (utilityPlayer.count > 0) {
//                                NSString *currentPlayer = token.playerName;
//                                NSString *utilityName = utilityPlayer[0];
//                                if ([currentPlayer isEqual:utilityName]) {
//                                    NSString *name = utilityPlayer[0];
//                                    NSString *position = utilityPlayer[1];
//                                    token.playerName = name;
//                                    token.position = position;
//                                    token.isUtility = true;
//                                    continue;
//                                }
//                            } 
//                            
//                        }
//                    } else {
//                        break;
//                    }
//                }
                
                //update view positions for the opposing player objects
                for (int i = 0; i < opposingPlayerArray.count; i ++) {
                    UIImageView *currentView = opposingPlayerArray[i];
                    NSArray *currentCoords = attributeNames[i];
                    //NSNumber *xVal = currentCoords[0];
                    NSNumber *xVal = [offensePlay valueForKey:currentCoords[0]];
                    //NSNumber *yVal = currentCoords[1];
                    NSNumber *yVal = [offensePlay valueForKey:currentCoords[1]];
                    NSArray *theseCoords = [[NSArray alloc] initWithObjects:xVal, yVal, nil];
                    [opposingCoords replaceObjectAtIndex:i withObject:theseCoords];
                    [currentView setFrame:CGRectMake([xVal floatValue], [yVal floatValue], currentView.frame.size.width, currentView.frame.size.height)];
                }
                
            }
            
        } else {
        //play is an defense play, so grab it from Core Data using passed name
            NSFetchRequest *fetchDefensePlays = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"DefensePlay" inManagedObjectContext:context];
            [fetchDefensePlays setEntity:entity];
            
            NSError *defenseError = nil;
            NSArray *fetchedDefensePlays = [context executeFetchRequest:fetchDefensePlays error:&defenseError];
            if (fetchDefensePlays == nil) {
                NSLog(@"Error retrieving list of offensive plays!  %@", defenseError);
            } else {
                for (DefensePlay *currentDefensePlay in fetchedDefensePlays) {
                    if ([currentDefensePlay.owner isEqual:app.currentPlaybook]) {
                        if ([currentDefensePlay.playName isEqual:playChosenTitle]) {
                            defensePlay = currentDefensePlay;
                            break;
                        }
                    }
                }
                
                //restore the correct theme that the user last saved out
                [self updateTheme:defensePlay.theme];

                NSData *utilityData = defensePlay.utilityPlayers;
                NSArray *utilityArray = [NSKeyedUnarchiver unarchiveObjectWithData:utilityData];
                
                //now that we have the selected play object, grab and set all of it's data
                if (defensePlay.drawCanvas != nil) {
                    UIImage *drawnImage = [UIImage imageWithData:defensePlay.drawCanvas];
                    self.drawingCanvas.image = drawnImage;
                }
                
                //now that we have the saved play, load in the players from it into our waiting view controllers/views
                for (int i = 0; i < 11; i++) {
                    PlayerTokenViewController *playerToken = (PlayerTokenViewController*) allViewControllers[i];
                    switch (i) {
                        case 0:
                            playerToken.playerName = defensePlay.player0Name;
                            playerToken.xPosition = [defensePlay.player0X floatValue];
                            playerToken.yPosition = [defensePlay.player0Y floatValue];
                            break;
                        case 1:
                            playerToken.playerName = defensePlay.player1Name;
                            playerToken.xPosition = [defensePlay.player1X floatValue];
                            playerToken.yPosition = [defensePlay.player1Y floatValue];
                            break;
                        case 2:
                            playerToken.playerName = defensePlay.player2Name;
                            playerToken.xPosition = [defensePlay.player2X floatValue];
                            playerToken.yPosition = [defensePlay.player2Y floatValue];
                            break;
                        case 3:
                            playerToken.playerName = defensePlay.player3Name;
                            playerToken.xPosition = [defensePlay.player3X floatValue];
                            playerToken.yPosition = [defensePlay.player3Y floatValue];
                            break;
                        case 4:
                            playerToken.playerName = defensePlay.player4Name;
                            playerToken.xPosition = [defensePlay.player4X floatValue];
                            playerToken.yPosition = [defensePlay.player4Y floatValue];
                            break;
                        case 5:
                            playerToken.playerName = defensePlay.player5Name;
                            playerToken.xPosition = [defensePlay.player5X floatValue];
                            playerToken.yPosition = [defensePlay.player5Y floatValue];
                            break;
                        case 6:
                            playerToken.playerName = defensePlay.player6Name;
                            playerToken.xPosition = [defensePlay.player6X floatValue];
                            playerToken.yPosition = [defensePlay.player6Y floatValue];
                            break;
                        case 7:
                            playerToken.playerName = defensePlay.player7Name;
                            playerToken.xPosition = [defensePlay.player7X floatValue];
                            playerToken.yPosition = [defensePlay.player7Y floatValue];
                            break;
                        case 8:
                            playerToken.playerName = defensePlay.player8Name;
                            playerToken.xPosition = [defensePlay.player8X floatValue];
                            playerToken.yPosition = [defensePlay.player8Y floatValue];
                            break;
                        case 9:
                            playerToken.playerName = defensePlay.player9Name;
                            playerToken.xPosition = [defensePlay.player9X floatValue];
                            playerToken.yPosition = [defensePlay.player9Y floatValue];
                            break;
                        case 10:
                            playerToken.playerName = defensePlay.player10Name;
                            playerToken.xPosition = [defensePlay.player10X floatValue];
                            playerToken.yPosition = [defensePlay.player10Y floatValue];
                            break;
                            
                        default:
                            break;
                    }
                }
                
                NSFetchRequest *fetchDefensePlayers = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
                [fetchDefensePlayers setEntity:entity];
                
                NSError *defensePlayerError = nil;
                NSArray *fetchedDefensePlayers = [context executeFetchRequest:fetchDefensePlayers error:&defensePlayerError];
                if (fetchedDefensePlayers == nil) {
                    NSLog(@"Error retrieving players within offensive play setup:  %@", defensePlayerError);
                } else {
                    
                    //add images and positions after retrieving list of offensive roster players using the players' names
                    for (int i = 0; i < allViewControllers.count; i ++) {
                        
                        PlayerTokenViewController *currentPlayerController = allViewControllers[i];
                        UIView *view = allContainers[i];
                        Player *foundPlayer;
                        Player *currentPlayer;
                        UIImage *playerPic;
                        //loop through entire roster and grab the correct player by name
                        for (int x = 0; x < fetchedDefensePlayers.count; x++) {
                            currentPlayer = fetchedDefensePlayers[i];
                            
                            if ([currentPlayerController.playerName isEqual:currentPlayer.name]) {
                                foundPlayer = currentPlayer;
                                
                                break;
                            }
                        }
                        //set values from the found player before iterating and repeating for remaining view controllers
                        //currentPlayerController.position = foundPlayer.position;
                        
                        
                        view.frame = CGRectMake(currentPlayerController.xPosition, currentPlayerController.yPosition, view.frame.size.width, view.frame.size.height);
                        currentPlayerController.viewWidth = view.frame.size.width;
                        currentPlayerController.viewHeight = view.frame.size.height;
                        NSString *playerName = currentPlayerController.playerName;
                        
                        currentPlayerController.position = [self getPlayerPosition:playerName];
                        playerPic = [self getPlayerImage:playerName];
                        
                        currentPlayerController.imageFile = playerPic;
                        //currentPlayerController.playerPicture.image = currentPlayerController.imageFile;
                        //[currentPlayerController.playerPicture setImage:playerPic];
                        currentPlayerController.playerPicture.image = playerPic;
                        currentPlayerController.nameHolder.text = currentPlayerController.playerName;
                        
                        if (utilityArray.count > 0) {
                            for (NSArray *utilityPlayer in utilityArray) {
                                if (utilityPlayer.count > 0) {
                                    
                                    NSString *thisName = currentPlayerController.playerName;
                                    NSString *utilityName = [utilityPlayer objectAtIndex:0];
                                    NSLog(@"Checking current player:  %@    against stored utility player:  %@", thisName, utilityName);
                                    if ([thisName isEqual:utilityName]) {
                                        currentPlayerController.isUtility = true;
                                        currentPlayerController.position = utilityPlayer[1];
                                        NSLog(@"PLAYER MATCH FOR UTILITY!");
                                    }
                                }
                            }
                        }
                        
                    }
                    
                }
                
                //update view positions for the opposing player objects
                for (int i = 0; i < opposingPlayerArray.count; i ++) {
                    UIImageView *currentView = opposingPlayerArray[i];
                    NSArray *currentCoords = attributeNames[i];
                    //NSNumber *xVal = currentCoords[0];
                    NSNumber *xVal = [defensePlay valueForKey:currentCoords[0]];
                    //NSNumber *yVal = currentCoords[1];
                    NSNumber *yVal = [defensePlay valueForKey:currentCoords[1]];
                    NSArray *theseCoords = [[NSArray alloc] initWithObjects:xVal, yVal, nil];
                    [opposingCoords replaceObjectAtIndex:i withObject:theseCoords];
                    [currentView setFrame:CGRectMake([xVal floatValue], [yVal floatValue], currentView.frame.size.width, currentView.frame.size.height)];
                }
                
            }
        }
        //[self.view setNeedsLayout];
    } else {
    //load in players from roster to container views, since the user wants to create a new play (which players they are doesn't matter)
        
        //set up our players to a default positioning that makes sense depending on type (offense or defense)
        PlaySettingsViewController *settings = (PlaySettingsViewController*) revealViewController.rearViewController;
        [settings setDefaultPositions:playType];
        
    }
   //isSettingUp = NO;
    
}

-(UIImage*)getPlayerImage:(NSString*)name {
    for (int i = 0; i < correctPlayers.count; i++) {
        Player *player = correctPlayers[i];
        NSString *playerName = player.name;
        
        if ([name isEqual:playerName]) {
            //found the correct player so return the image representing them.
            UIImage *localImage = [UIImage imageWithData:player.image];
            return localImage;
        }
    }
    return nil;
}

-(NSString*)getPlayerPosition:(NSString*)name {
    for (int i = 0; i < correctPlayers.count; i++) {
        Player *player = correctPlayers[i];
        NSString *playerName = player.name;
        if ([name isEqual:playerName]) {
            NSString *playerPosition = player.position;
            return playerPosition;
        }
    }
    return nil;
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear and currentSelected is:  %i", currentSelected);
    //set up our array of UIImageView objects to represent the opposing team
    opposingPlayerArray = [[NSMutableArray alloc] initWithObjects:opposingPlayer1, opposingPlayer2, opposingPlayer3, opposingPlayer4, opposingPlayer5, opposingPlayer6, opposingPlayer7, opposingPlayer8, opposingPlayer9, opposingPlayer10, opposingPlayer11, nil];
    
    userWarned = false;
    
    if (remotePlayData != nil) {
        [self setUpRemote];
        
    } else {
        if (isTakingPicture == false) {
            if (createNew == false) {
                //editing a preexisting play, so load the players saved and position appropriately
                isSettingUp = true;
                playerHolder = [[NSMutableArray alloc] init];
                [self setUpPlay:playChosenTitle];
            } else {
                if (imagePickerController == nil) {
                    //creating a new play, so load in players and assign to default positions
                    playerHolder = [[NSMutableArray alloc] init];
                    [self setUpPlay:nil];
                }
            }
        }
    }
}

//this method is ONLY called when we are loading in a retrieved play from Parse.com
-(void)setUpRemote {
    NSMutableArray *allData = [[NSMutableArray alloc] initWithArray:remotePlayData];
    [allData removeObjectAtIndex:0];
    [allData removeObjectAtIndex:0];
    NSString *titleString = [remotePlayData objectAtIndex:0];
    self.navigationItem.title = titleString;
    
    UIImage *canvas = [remotePlayData objectAtIndex:1];
    _drawingCanvas.image = canvas;
    
    for (int i = 0; i < allData.count; i ++) {
       
            PlayerTokenViewController *player = allViewControllers[i];
            UIView *container = allContainers[i];
        
       
        
        
        
            NSArray *coords = allData[i];
            NSNumber *x = coords[0];
            NSNumber *y = coords[1];
            float xFloat = [x floatValue];
            float yFloat = [y floatValue];
            player.xPosition = xFloat;
            player.yPosition = yFloat;
            container.frame = CGRectMake(xFloat, yFloat, container.frame.size.width, container.frame.size.height);
        
        
    }
    
    //now apply saved players to each of the positioned view controllers (this will need to be changed later if we're going to address player positions...)
    NSMutableArray *matchedPlayerArray = [[NSMutableArray alloc] init];
    NSFetchRequest *playerFetch = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
    [playerFetch setEntity:entity];
    
    NSError *offensePlayerError = nil;
    NSArray *fetchedPlayers = [context executeFetchRequest:playerFetch error:&offensePlayerError];
    if (fetchedPlayers == nil) {
        NSLog(@"Error retrieving offensive players when loading remote play!  Error:  %@", offensePlayerError.description);
        
    } else {
        
        for (Player *currentPlayer in fetchedPlayers) {
            if ([currentPlayer.team isEqual:playType]) {
                [matchedPlayerArray addObject:currentPlayer];
            }
        }
    }
    
    for (int i = 0; i < allViewControllers.count; i ++) {
        PlayerTokenViewController *current = allViewControllers[i];
        Player *matched = matchedPlayerArray[i];
        current.playerName = matched.name;
        current.nameHolder.text = matched.name;
        UIImage *playerIcon = [UIImage imageWithData:matched.image];
        current.imageFile = playerIcon;
        current.playerPicture.image = playerIcon;
        current.position = matched.position;
    }
    [self updateTheme:@"grass"];
    remotePlayData = nil;
}

-(void)disableAnnoyingSwipe {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer != longRecognizer && gestureRecognizer != tapRecognizer) {
//        return YES;
//    }
    if (![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    return YES;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (allViewControllers == nil) {
        allViewControllers = [[NSMutableArray alloc] initWithObjects:@"string", @"string", @"string", @"string", @"string", @"string", @"string", @"string", @"string", @"string",@"string", nil];
    }
    NSString *segueName = segue.identifier;
    for (int i = 1; i < 12; i++) {
        NSString *comparisonString = [[NSString alloc] initWithFormat:@"container%i",i];
        int sync = i -1;
        if ([segueName isEqualToString: comparisonString]) {
            PlayerTokenViewController *player = [segue destinationViewController];
            
            //we use this to add our viewController objects to an array dynamically to keep them "synced" with the container objects that hold them
            switch (i) {
                case 1:
                    player1 = player;
                    //[allViewControllers addObject:player1];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player1];
                    break;
                case 2:
                    player2 = player;
                    //[allViewControllers addObject:player2];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player2];
                    break;
                case 3:
                    player3 = player;
                    //[allViewControllers addObject:player3];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player3];
                    break;
                case 4:
                    player4 = player;
                    //[allViewControllers addObject:player4];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player4];
                    break;
                case 5:
                    player5 = player;
                    //[allViewControllers addObject:player5];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player5];
                    break;
                case 6:
                    player6 = player;
                    //[allViewControllers addObject:player6];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player6];
                    break;
                case 7:
                    player7 = player;
                    //[allViewControllers addObject:player7];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player7];
                    break;
                case 8:
                    player8 = player;
                    //[allViewControllers addObject:player8];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player8];
                    break;
                case 9:
                    player9 = player;
                    //[allViewControllers addObject:player9];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player9];
                    break;
                case 10:
                    player10 = player;
                    //[allViewControllers addObject:player10];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player10];
                    break;
                case 11:
                    player11 = player;
                    //[allViewControllers addObject:player11];
                    [allViewControllers replaceObjectAtIndex:sync withObject:player11];
                    break;
                    
            }
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (drawingEnabled) {
        
        NSLog(@"touchesBegan!");
        mouseSwiped = NO;
        UITouch *touch = [touches anyObject];
        lastPoint = [touch locationInView:self.view];
        if (eraserOn) {
            brush = 20;
        } else {
            brush = 10;
        }
    }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (drawingEnabled) {
        hasDrawn = true;
        mouseSwiped = YES;
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.view];
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.drawingCanvas.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
        if (eraserOn == false) {
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        } else {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
        }
        
        
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.drawingCanvas.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.drawingCanvas setAlpha:opacity];
        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (drawingEnabled) {
        if(!mouseSwiped) {
            UIGraphicsBeginImageContext(self.view.frame.size);
            [self.tempCanvas.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            CGContextFlush(UIGraphicsGetCurrentContext());
            self.tempCanvas.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        UIGraphicsBeginImageContext(self.tempCanvas.frame.size);
        [self.tempCanvas.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
        [self.tempCanvas.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
        self.tempCanvas.image = UIGraphicsGetImageFromCurrentImageContext();
        
        self.tempCanvas.image = nil;
        [self.tempCanvas setAlpha:0];
        [self.tempCanvas setHidden:YES];
        [self.drawingCanvas setAlpha:1];
        UIGraphicsEndImageContext();
    }
}

//allow the user to change the drawing color by changing our float values
-(IBAction)onClick:(id)sender {
    NSLog(@"onClick fires!");
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        //settings icon tapped
        NSLog(@"Settings tapped!");
        [revealViewController revealToggleAnimated:YES];
        
        [self disableDrawing];
        
    } else if (button.tag == 1) {
        //blue was chosen
        red = 0.0/255.0;
        green = 0.0/255.0;
        blue = 255.0/255.0;
        eraserOn = false;
        [self swapMarkers:@"blue"];
    } else if (button.tag == 2) {
        //red was chosen
        red = 255.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
        eraserOn = false;
        [self swapMarkers:@"red"];
    } else if (button.tag == 3) {
        //black was chosen
        red = 0.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
        eraserOn = false;
        [self swapMarkers:@"black"];
    } else if (button.tag == 4) {
        NSLog(@"Draw Tapped!");
        if (drawingEnabled == true) {
            drawingEnabled = false;
            _redButton.hidden = YES;
            _blueButton.hidden = YES;
            _blackButton.hidden = YES;
            _eraserButton.hidden = YES;
            [drawItem setTintColor:[UIColor blueColor]];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
            for (UIView *view in allContainers) {
                [view addGestureRecognizer:longRecognizer];
                [view addGestureRecognizer:tapRecognizer];
            }
            
        } else {
            drawingEnabled = true;
            _redButton.hidden = NO;
            _blueButton.hidden = NO;
            _blackButton.hidden = NO;
            _eraserButton.hidden = NO;
            [drawItem setTintColor:[UIColor whiteColor]];
            [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
            for (UIView *view in allContainers) {
                [view removeGestureRecognizer:longRecognizer];
                [view removeGestureRecognizer:tapRecognizer];
            }
            
        }
    } else if (button.tag == 5) {
        NSLog(@"Roster button tapped!");
    } else if (button.tag == 6) {
        //eraser was chosen
        eraserOn = true;
        [self swapMarkers:@"eraser"];
    } else if (button.tag == 7) {
        //save button was tapped, so call the savePlay method (below)
        [self savePlay:@"manual"];
    } else if (button.tag == 8) {
        //bar button item for saving downloadable plays to parse - should be removed from published app
        [self saveToParse];
    }
}

//get rid of below method for public build before publishing!
-(void)saveToParse {
    PFObject *playObject;
    if ([playType isEqual:@"offense"]) {
        playObject = [PFObject objectWithClassName:@"OffensePlay"];
    } else {
        playObject = [PFObject objectWithClassName:@"DefensePlay"];
    }
    
    NSString *title = self.navigationItem.title;
    [playObject setObject:title forKey:@"playName"];
    
    //grab snapshot of total play so we can use it for an thumbnail in play selection screen or to print out later
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *snapshotData = [NSData dataWithData:UIImageJPEGRepresentation(snapshot, 1.0)];
    PFFile *snapShotFile = [PFFile fileWithData:snapshotData];
    [playObject setObject:snapShotFile forKey:@"snapshot"];
    
    
    if (hasDrawn) {
        UIGraphicsBeginImageContextWithOptions(self.drawingCanvas.bounds.size, self.drawingCanvas.opaque, 0.0);
        [self.drawingCanvas.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *drawing = UIGraphicsGetImageFromCurrentImageContext();
        _drawingCanvas.image = drawing;
        UIGraphicsEndImageContext();
        
        NSData *drawCanvasData = [NSData dataWithData:UIImagePNGRepresentation(drawing)];
        PFFile *imageFile = [PFFile fileWithData:drawCanvasData];
        
        [playObject setObject:imageFile forKey:@"drawCanvas"];
    }
    
    //set all of the 11 player's positions
    NSArray *attributesHolder = [[NSArray alloc] initWithObjects:@"player1Pos", @"player2Pos", @"player3Pos", @"player4Pos", @"player5Pos", @"player6Pos", @"player7Pos", @"player8Pos", @"player9Pos", @"player10Pos", @"player11Pos", nil];
    NSMutableArray *coords;
    
    for (int i = 0; i < allViewControllers.count; i ++) {
        PlayerTokenViewController *thisPlayer = allViewControllers[i];
        NSNumber *xNumber = [NSNumber numberWithFloat:thisPlayer.xPosition];
        NSNumber *yNumber = [NSNumber numberWithFloat:thisPlayer.yPosition];
        
        coords = [[NSMutableArray alloc] initWithObjects:xNumber, yNumber, nil];
        [playObject setObject:coords forKey:attributesHolder[i]];
    }
    
    //save out
    [playObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Saved successfully!");
        } else {
            NSLog(@"Error Saving!  Error was:  %@", error.description);
        }
    }];
}

-(void)resetPlay {
    //TO DO - Find a way to refactor the mess that is below to not need so dang much code (darn multiple Play entities!)
    NSString *currentTitle = self.navigationItem.title;
    //if ([currentTitle isEqual:playChosenTitle]) {
        //need to check first to ensure that a play by this name already exists in core data before trying to load it
        NSFetchRequest *fetchRequest;
        if ([playType isEqual:@"offense"]) {
            fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"OffensePlay"];
        } else {
            fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DefensePlay"];
        }
        
        NSError *fetchError = nil;
        NSArray *retrievedPlays = [context executeFetchRequest:fetchRequest error:&fetchError];
        
        if (retrievedPlays == nil) {
            NSLog(@"Error fetching saved plays when attempting to reset play to default settings!  %@", fetchError);
        } else {
            if ([playType isEqual:@"offense"]) {
                for (OffensePlay *offPlay in retrievedPlays) {
                    if ([offPlay.playName isEqual:currentTitle]) {
                        [self setUpPlay:currentTitle];
                        return;
                    }
                }
            } else {
                for (DefensePlay *defPlay in retrievedPlays) {
                    if ([defPlay.playName isEqual:currentTitle]) {
                        [self setUpPlay:currentTitle];
                        return;
                    }
                }
            }
        }
        //create alert view to inform the user that they are trying to reset a play that hasn't been previously saved out
        NSString *alertString = [[NSString alloc] initWithFormat:@"A previously saved instance of play \'%@\' could not be found.  Cannot reset play.", currentTitle];
        UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:@"Cannot Reset" message:alertString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [restoreAlert show];
    //}
}

-(UIImage*)getPlaySnapshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //detect when the user taps the 'rename button within the alert view presented during save
    if (alertView.tag == 8) {
        if (buttonIndex == 1) {
            [revealViewController revealToggle:self];
            [self disableDrawing];
            //renameActive
            PlaySettingsViewController *playSettings = (PlaySettingsViewController*) revealViewController.rearViewController;
            [playSettings renameActive];
            //asdf
        }
    } else if (alertView.tag == 99) {
        if (buttonIndex == 2) {
            NSLog(@"Swapping to utility!");
            playerToSwap.position = positionToSwap;
            playerToSwap.isUtility = true;
        }
    } else if (alertView.tag == 11) {
        //UIAlert concerning overwriting existing play
        if (buttonIndex == 1) {
            userWarned = true;
            [self savePlay:@"manual"];
        }
    }
}

//reusable method to save our play out to Core Data
-(void)savePlay:(NSString*)type {
    if ([self.navigationItem.title isEqual:@"Create New"]) {
    //force user to rename the play so we don't run into any naming conflicts
        UIAlertView *renameAlert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please choose a valid name for your play before saving." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
        renameAlert.tag = 8;
        [renameAlert show];
        
    } else {
        NSLog(@"Type passed to save function is:  %@", type);
        isSettingUp = YES;
        BOOL oldPlay = false;
        NSMutableArray *utilityPlayers = [[NSMutableArray alloc] init];
        //set up a reusable array of arrays for saving out the positions of the opposing players
        NSArray *array0 = [[NSArray alloc] initWithObjects:@"x0x",@"x0y", nil];
        NSArray *array1 = [[NSArray alloc] initWithObjects:@"x1x",@"x1y", nil];
        NSArray *array2 = [[NSArray alloc] initWithObjects:@"x2x",@"x2y", nil];
        NSArray *array3 = [[NSArray alloc] initWithObjects:@"x3x",@"x3y", nil];
        NSArray *array4 = [[NSArray alloc] initWithObjects:@"x4x",@"x4y", nil];
        NSArray *array5 = [[NSArray alloc] initWithObjects:@"x5x",@"x5y", nil];
        NSArray *array6 = [[NSArray alloc] initWithObjects:@"x6x",@"x6y", nil];
        NSArray *array7 = [[NSArray alloc] initWithObjects:@"x7x",@"x7y", nil];
        NSArray *array8 = [[NSArray alloc] initWithObjects:@"x8x",@"x8y", nil];
        NSArray *array9 = [[NSArray alloc] initWithObjects:@"x9x",@"x9y", nil];
        NSArray *array10 = [[NSArray alloc] initWithObjects:@"x10x",@"x10y", nil];
        NSArray *attributeNames = [[NSArray alloc] initWithObjects:array0, array1, array2, array3, array4, array5, array6, array7, array8, array9, array10, nil];
        
        //Player *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
        if ([playType isEqual:@"offense"]) {
            //first check to see if this play already exists by comparing it's title to one saved
            NSFetchRequest *fetchOffensePlays = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"OffensePlay" inManagedObjectContext:context];
            
            [fetchOffensePlays setEntity:entity];
            
            NSError *offenseError = nil;
            NSArray *fetchedOffensePlays = [context executeFetchRequest:fetchOffensePlays error:&offenseError];
            if (fetchedOffensePlays == nil) {
                NSLog(@"Error retrieving list of offensive plays!  %@", offenseError);
            } else {
                NSString *currentName = self.navigationItem.title;
                playChosenTitle = currentName;
                for (OffensePlay *currentOffensePlay in fetchedOffensePlays) {
                    if ([currentOffensePlay.playName isEqual:currentName]) {
                        NSLog(@"match found already saved!");
                        offensePlay = currentOffensePlay;
                        
                        //offensePlay = [[NSManagedObject alloc]initWithEntity:offensePlay insertIntoManagedObjectContext:context];
                        
                        oldPlay = true;
                        break;
                    }
                }
            }
            
            if (oldPlay == false) {
                offensePlay = [NSEntityDescription insertNewObjectForEntityForName:@"OffensePlay" inManagedObjectContext:context];
                //offensePlay = [[OffensePlay alloc] init];
            } else {
                if (!userWarned) {
                    //alert the user they are about to overwrite an already saved play
                    NSString *overwriteString = [NSString stringWithFormat:@"A play with the name \'%@\' already exists!  Overwrite?", self.navigationItem.title];
                    UIAlertView *overwriteAlert = [[UIAlertView alloc] initWithTitle:@"Overwrite Existing Play?" message:overwriteString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                    overwriteAlert.tag = 11;
                    [overwriteAlert show];
                    return;
                }
            }
            
            offensePlay.playName = self.navigationItem.title;
            
            
            offensePlay.owner = app.currentPlaybook;
            
            //grab snapshot of total play so we can use it for an thumbnail in play selection screen or to print out later
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
            [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
            //reduce the size of the snapshot image in case it was created on a retina iPad (which is likely)
            CGSize destinationSize = CGSizeMake(1024, 768);
            UIGraphicsBeginImageContext(destinationSize);
            [snapshot drawInRect:CGRectMake(0,0,destinationSize.width, destinationSize.height)];
            UIImage *reducedSnapshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *snapshotData = [NSData dataWithData:UIImageJPEGRepresentation(reducedSnapshot, 1.0)];
            offensePlay.snapshot = snapshotData;
            
            //save out the current theme by checking which background is onscreen
            UIImage *grassImage = [UIImage imageNamed:@"Grass_bg.jpg"];
            UIImage *chalkImage = [UIImage imageNamed:@"chalkboard_bg.jpg"];
            NSData *grassData = UIImagePNGRepresentation(grassImage);
            NSData *chalkData = UIImagePNGRepresentation(chalkImage);
            
            NSData *currentBackground = UIImagePNGRepresentation( bgImage.image);
            NSInteger currentSize = currentBackground.length;
            NSInteger grassSize = grassData.length;
            NSInteger chalkSize = chalkData.length;
            
            if (currentSize == grassSize) {
                offensePlay.theme = @"grass";
            } else if (currentSize == chalkSize) {
                offensePlay.theme = @"chalk";
            } else if (currentBackground == nil) {
                offensePlay.theme = @"white";
            }
            
            //grab the current layer that the user has drawn on so it can be restored later (only if they have drawn to it though, otherwise it
            //loads in a black screen later)
            if (hasDrawn) {
                UIGraphicsBeginImageContextWithOptions(self.drawingCanvas.bounds.size, self.drawingCanvas.opaque, 0.0);
                [self.drawingCanvas.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *drawing = UIGraphicsGetImageFromCurrentImageContext();
                _drawingCanvas.image = drawing;
                UIGraphicsEndImageContext();
                
                //reduce the size of the snapshot image in case it was created on a retina iPad (which is likely)
                CGSize destinationSize = CGSizeMake(1024, 768);
                UIGraphicsBeginImageContext(destinationSize);
                [drawing drawInRect:CGRectMake(0,0,destinationSize.width, destinationSize.height)];
                UIImage *reducedCanvas = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                NSData *drawCanvasData = [NSData dataWithData:UIImagePNGRepresentation(reducedCanvas)];
                
                offensePlay.drawCanvas = drawCanvasData;
            }
            
            //save out the positioning of all of the opposing players
            
            
            for (int i = 0; i < opposingCoords.count; i ++) {
                NSArray *currentAttributes = attributeNames[i];
                NSArray *currentValues = opposingCoords[i];
                NSNumber *xVal = [currentValues objectAtIndex:0];
                NSNumber *yVal = [currentValues objectAtIndex:1];
                [offensePlay setValue:xVal forKey:currentAttributes[0]];
                [offensePlay setValue:yVal forKey:currentAttributes[1]];
                NSLog(@"Saving out coords %@ and %@ for opposing player!", xVal, yVal);
            }
            
            //loop through all view controllers grabbing data for each and assigning it as appropriate to the OffensePlay entity
            for (int i = 0; i < allContainers.count; i ++) {
                PlayerTokenViewController *thisPlayer = allViewControllers[i];
                UIView *containerView = allContainers[i];
                
                //NSLog(@"Player  %@  is at X Coordinate:  %f  and Y Coordinate:  %f", thisPlayer.playerName, containerView.frame.origin.x, containerView.frame.origin.y);
                
                switch (i) {
                    case 0:
                        //offensePlay.player0Name = thisPlayer.playerName;
                        offensePlay.player0Name = thisPlayer.nameHolder.text;
                        offensePlay.player0X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player0Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 1:
                        //offensePlay.player1Name = thisPlayer.playerName;
                        offensePlay.player1Name = thisPlayer.nameHolder.text;
                        offensePlay.player1X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player1Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 2:
                        //offensePlay.player2Name = thisPlayer.playerName;
                        offensePlay.player2Name = thisPlayer.nameHolder.text;
                        offensePlay.player2X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player2Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 3:
                        //offensePlay.player3Name = thisPlayer.playerName;
                        offensePlay.player3Name = thisPlayer.nameHolder.text;
                        offensePlay.player3X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player3Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 4:
                        //offensePlay.player4Name = thisPlayer.playerName;
                        offensePlay.player4Name = thisPlayer.nameHolder.text;
                        offensePlay.player4X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player4Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 5:
                        //offensePlay.player5Name = thisPlayer.playerName;
                        offensePlay.player5Name = thisPlayer.nameHolder.text;
                        offensePlay.player5X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player5Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 6:
                       // offensePlay.player6Name = thisPlayer.playerName;
                        offensePlay.player6Name = thisPlayer.nameHolder.text;
                        offensePlay.player6X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player6Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 7:
                        //offensePlay.player7Name = thisPlayer.playerName;
                        offensePlay.player7Name = thisPlayer.nameHolder.text;
                        offensePlay.player7X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player7Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 8:
                        //offensePlay.player8Name = thisPlayer.playerName;
                        offensePlay.player8Name = thisPlayer.nameHolder.text;
                        offensePlay.player8X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player8Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 9:
                        //offensePlay.player9Name = thisPlayer.playerName;
                        offensePlay.player9Name = thisPlayer.nameHolder.text;
                        offensePlay.player9X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player9Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 10:
                        //offensePlay.player10Name = thisPlayer.playerName;
                        offensePlay.player10Name = thisPlayer.nameHolder.text;
                        offensePlay.player10X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        offensePlay.player10Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                        
                    default:
                        break;
                }
                
            }
            
            if (utilityPlayers.count > 0) {
                NSData *utilityData = [NSKeyedArchiver archivedDataWithRootObject:utilityPlayers];
                offensePlay.utilityPlayers = utilityData;
            } else {
                offensePlay.utilityPlayers = nil;
            }
            

        }  else {
            //DefensePlay *play = [NSEntityDescription insertNewObjectForEntityForName:@"DefensePlay" inManagedObjectContext:context];
            BOOL oldPlay = false;
            //first check to see if this play already exists by comparing it's title to one saved
            NSFetchRequest *fetchDefensePlays = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"DefensePlay" inManagedObjectContext:context];
            [fetchDefensePlays setEntity:entity];
            
            NSError *defenseError = nil;
            NSArray *fetchedDefensePlays = [context executeFetchRequest:fetchDefensePlays error:&defenseError];
            if (fetchedDefensePlays == nil) {
                NSLog(@"Error retrieving list of offensive plays!  %@", defenseError);
            } else {
                NSString *currentName = self.navigationItem.title;
                playChosenTitle = currentName;
                for (DefensePlay *currentDefensePlay in fetchedDefensePlays) {
                    if ([currentDefensePlay.playName isEqual:currentName]) {
                        NSLog(@"match found already saved!");
                        defensePlay = currentDefensePlay;
                        oldPlay = true;
                        break;
                    }
                }
            }
            
            if (oldPlay == false) {
                defensePlay = [NSEntityDescription insertNewObjectForEntityForName:@"DefensePlay" inManagedObjectContext:context];
            } else {
                if (!userWarned) {
                    //alert the user they are about to overwrite an already saved play
                    NSString *overwriteString = [NSString stringWithFormat:@"A play with the name \'%@\' already exists!  Overwrite?", self.navigationItem.title];
                    UIAlertView *overwriteAlert = [[UIAlertView alloc] initWithTitle:@"Overwrite Existing Play?" message:overwriteString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                    overwriteAlert.tag = 11;
                    [overwriteAlert show];
                    return;
                }
            }
            
            
            
            defensePlay.playName = self.navigationItem.title;
            NSLog(@"Title saved was:  %@", self.navigationItem.title);
            
            defensePlay.owner = app.currentPlaybook;
            
            //grab snapshot of total play so we can use it for an thumbnail in play selection screen or to print out later
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
            [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            //reduce the size of the snapshot image in case it was created on a retina iPad (which is likely)
            CGSize destinationSize = CGSizeMake(1024, 768);
            UIGraphicsBeginImageContext(destinationSize);
            [snapshot drawInRect:CGRectMake(0,0,destinationSize.width, destinationSize.height)];
            UIImage *reducedSnapshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *snapshotData = [NSData dataWithData:UIImageJPEGRepresentation(reducedSnapshot, 1.0)];
            defensePlay.snapshot = snapshotData;
            
            //save out the current theme by checking which background is onscreen
            UIImage *grassImage = [UIImage imageNamed:@"Grass_bg.jpg"];
            UIImage *chalkImage = [UIImage imageNamed:@"chalkboard_bg.jpg"];
            NSData *grassData = UIImagePNGRepresentation(grassImage);
            NSData *chalkData = UIImagePNGRepresentation(chalkImage);
            
            
            NSData *currentBackground = UIImagePNGRepresentation(bgImage.image);
            NSInteger currentSize = currentBackground.length;
            NSInteger grassSize = grassData.length;
            NSInteger chalkSize = chalkData.length;
            
            if (currentSize == grassSize) {
                defensePlay.theme = @"grass";
                NSLog(@"Grass saved!");
            } else if (currentSize == chalkSize) {
                defensePlay.theme = @"chalk";
                NSLog(@"Chalk saved!");
            } else if (currentBackground == nil) {
                defensePlay.theme = @"white";
                NSLog(@"White saved!");
            }
            
            if (hasDrawn) {
                //grab the current layer that the user has drawn on so it can be restored later
                UIGraphicsBeginImageContextWithOptions(self.drawingCanvas.bounds.size, self.drawingCanvas.opaque, 0.0);
                [self.drawingCanvas.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *drawing = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                //reduce the size of the snapshot image in case it was created on a retina iPad (which is likely)
                CGSize destinationSize = CGSizeMake(1024, 768);
                UIGraphicsBeginImageContext(destinationSize);
                [drawing drawInRect:CGRectMake(0,0,destinationSize.width, destinationSize.height)];
                UIImage *reducedCanvas = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                NSData *drawCanvasData = [NSData dataWithData:UIImagePNGRepresentation(reducedCanvas)];
                
                defensePlay.drawCanvas = drawCanvasData;
            }
            
            //save out the positioning of all of the opposing players
            NSLog(@"Number of coordinates for the current defense play is:  %lu", (unsigned long)opposingCoords.count);
            for (int i = 0; i < opposingCoords.count; i ++) {
                NSArray *currentAttributes = attributeNames[i];
                NSArray *currentValues = opposingCoords[i];
                NSNumber *xVal = [currentValues objectAtIndex:0];
                NSNumber *yVal = [currentValues objectAtIndex:1];
                [defensePlay setValue:xVal forKey:currentAttributes[0]];
                [defensePlay setValue:yVal forKey:currentAttributes[1]];
            }
            
            //play.drawCanvas = drawCanvasData;
            
            
            
            for (int i = 0; i < allContainers.count; i ++) {
                PlayerTokenViewController *thisPlayer = allViewControllers[i];
                UIView *containerView = allContainers[i];
                NSLog(@"Player  %@  is at X Coordinate:  %f  and Y Coordinate:  %f", thisPlayer.playerName, containerView.frame.origin.x, containerView.frame.origin.y);
                switch (i) {
                    case 0:
                        defensePlay.player0Name = thisPlayer.nameHolder.text;
                        defensePlay.player0X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player0Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 1:
                        defensePlay.player1Name = thisPlayer.nameHolder.text;
                        defensePlay.player1X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player1Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 2:
                        defensePlay.player2Name = thisPlayer.nameHolder.text;
                        defensePlay.player2X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player2Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 3:
                        defensePlay.player3Name = thisPlayer.nameHolder.text;
                        defensePlay.player3X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player3Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 4:
                        defensePlay.player4Name = thisPlayer.nameHolder.text;
                        defensePlay.player4X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player4Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 5:
                        defensePlay.player5Name = thisPlayer.nameHolder.text;
                        defensePlay.player5X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player5Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 6:
                        defensePlay.player6Name = thisPlayer.nameHolder.text;
                        defensePlay.player6X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player6Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 7:
                        defensePlay.player7Name = thisPlayer.nameHolder.text;
                        defensePlay.player7X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player7Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 8:
                        defensePlay.player8Name = thisPlayer.nameHolder.text;
                        defensePlay.player8X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player8Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 9:
                        defensePlay.player9Name = thisPlayer.nameHolder.text;
                        defensePlay.player9X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player9Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                    case 10:
                        defensePlay.player10Name = thisPlayer.nameHolder.text;
                        defensePlay.player10X = [NSNumber numberWithFloat:(containerView.frame.origin.x)];
                        defensePlay.player10Y = [NSNumber numberWithFloat:(containerView.frame.origin.y)];
                        if (thisPlayer.isUtility) {
                            NSString *name = thisPlayer.nameHolder.text;
                            NSString *position = thisPlayer.position;
                            NSArray *utilityArray = [[NSArray alloc] initWithObjects:name, position, nil];
                            [utilityPlayers addObject:utilityArray];
                        }
                        break;
                        
                    default:
                        break;
                }
                
            }
            
            if (utilityPlayers.count > 0) {
                NSData *utilityData = [NSKeyedArchiver archivedDataWithRootObject:utilityPlayers];
                defensePlay.utilityPlayers = utilityData;
            } else {
                defensePlay.utilityPlayers = nil;
            }
            
        }
        
        
        //save out our play object
        NSError *error = nil;
        
        if (![[app managedObjectContext]save:&error]) {
            NSLog(@"Error saving core data!  %@", error);
        }
        
        //only alert the user if they initiated the save
        if ([type isEqual:@"manual"]) {
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Save Play" message:@"Save play successful" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [saveAlert show];
        }
    }
    
    userWarned = false;
}

//this method simply toggles the images assigned to the marker and eraser buttons to indicate which is 'active'
-(void)swapMarkers:(NSString *)selected {
    if ([selected isEqual:@"blue"]) {
        [_redButton setBackgroundImage:[UIImage imageNamed:@"marker_red_closed.png"] forState:UIControlStateNormal];
        [_blackButton setBackgroundImage:[UIImage imageNamed:@"marker_black_closed.png"] forState:UIControlStateNormal];
        [_blueButton setBackgroundImage:[UIImage imageNamed:@"marker_blue_open.png"] forState:UIControlStateNormal];
        [_eraserButton setBackgroundImage:[UIImage imageNamed:@"dry_eraser.png"] forState:UIControlStateNormal];
        
    } else if ([selected isEqual:@"red"]) {
        [_redButton setBackgroundImage:[UIImage imageNamed:@"marker_red_open.png"] forState:UIControlStateNormal];
        [_blackButton setBackgroundImage:[UIImage imageNamed:@"marker_black_closed.png"] forState:UIControlStateNormal];
        [_blueButton setBackgroundImage:[UIImage imageNamed:@"marker_blue_closed.png"] forState:UIControlStateNormal];
        [_eraserButton setBackgroundImage:[UIImage imageNamed:@"dry_eraser.png"] forState:UIControlStateNormal];
        
    } else if ([selected isEqual:@"black"]) {
        [_redButton setBackgroundImage:[UIImage imageNamed:@"marker_red_closed.png"] forState:UIControlStateNormal];
        [_blackButton setBackgroundImage:[UIImage imageNamed:@"marker_black_open.png"] forState:UIControlStateNormal];
        [_blueButton setBackgroundImage:[UIImage imageNamed:@"marker_blue_closed.png"] forState:UIControlStateNormal];
        [_eraserButton setBackgroundImage:[UIImage imageNamed:@"dry_eraser.png"] forState:UIControlStateNormal];
    } else if ([selected isEqual:@"eraser"]) {
        [_redButton setBackgroundImage:[UIImage imageNamed:@"marker_red_closed.png"] forState:UIControlStateNormal];
        [_blackButton setBackgroundImage:[UIImage imageNamed:@"marker_black_closed.png"] forState:UIControlStateNormal];
        [_blueButton setBackgroundImage:[UIImage imageNamed:@"marker_blue_closed.png"] forState:UIControlStateNormal];
        [_eraserButton setBackgroundImage:[UIImage imageNamed:@"dry_eraser_selected.png"] forState:UIControlStateNormal];
        
    }
}

-(void)opposingPlayerLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    //NSLog(@"OPPOSING PLAYER LONG PRESSED!");
    int selected = 0;
    UIImageView *locaSelectedImage = (UIImageView*) [gestureRecognizer view];
    selectedImage = locaSelectedImage;
    NSNumber *xVal;
    NSNumber *yVal;
    
    for (int i = 0; i < opposingPlayerArray.count; i ++) {
        UIImageView *thisImageView = opposingPlayerArray[i];
        if (thisImageView == selectedImage) {
            selected = i;
            break;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        currentlyDragging = YES;
        [self disableDrawing];
        
        //need to set a 'highlighted state to give feedback to the user that they are now dragging
        for (int i = 0; i < opposingPlayerArray.count; i ++) {
            UIImageView *thisImageView = opposingPlayerArray[i];
            if (thisImageView == selectedImage) {
                selected = i;
                break;
            }
        }
        //now that we have a direct reference to the
        selectedImage.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        //selectedImage = opposingPlayerArray[selected];
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        currentlyDragging = YES;
        
        CGPoint point = [gestureRecognizer locationInView:self.view];
        int widthPosition = point.x - selectedImage.frame.size.width /2;
        int heightPosition = point.y - selectedImage.frame.size.height /2;
        CGRect newFrame = CGRectMake(widthPosition, heightPosition, 89, 74);
        [selectedImage setFrame:newFrame];
        
        //update the array of coords for this object so it isn't reset in viewDidLayoutSubviews
        xVal = [NSNumber numberWithInteger:widthPosition];
        yVal = [NSNumber numberWithInteger:heightPosition];
        
        NSArray *newCoords = [[NSArray alloc] initWithObjects:xVal,yVal, nil];
        [opposingCoords replaceObjectAtIndex:selected withObject:newCoords];
        
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        currentlyDragging = NO;
        xVal = [NSNumber numberWithFloat:selectedImage.frame.origin.x];
        yVal = [NSNumber numberWithFloat:selectedImage.frame.origin.y];
        //user is done dragging so update the saved coordinates for the dragged image view so viewDidLayoutSubviews doesn't put them back where they started
        selectedImage.backgroundColor = [UIColor clearColor];
        NSArray *newCoords = [[NSArray alloc] initWithObjects:xVal,yVal, nil];
        [opposingCoords replaceObjectAtIndex:selected withObject:newCoords];
    }
    
}

-(void)playerLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    //NSLog(@"Player long pressed");
    int selected;
    UIView *selectedContainer = (UIView*)[gestureRecognizer view];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self disableDrawing];
        
        currentlyDragging = YES;
        for (int i = 0; i < allContainers.count; i ++) {
            UIView *view = allContainers[i];
            if (selectedContainer == view) {
                //NSLog(@"Container found at:  %i", i);
                selected = i;
                break;
            }
        }
        selectedPlayer = (PlayerTokenViewController *) allViewControllers[selected];
        
        [selectedPlayer viewSelected];
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"state changed!");
        currentlyDragging = YES;
        CGPoint point = [gestureRecognizer locationInView:self.view];
        int widthPosition = point.x - selectedContainer.frame.size.width /2;
        int heightPosition = point.y - selectedContainer.frame.size.height /2;
        CGRect newFrame = CGRectMake(widthPosition, heightPosition, 89, 108);
        
        [selectedContainer setFrame:newFrame];
        //NSLog(@"X value is:  %f  and Y value is:  %f", point.x, point.y);
    
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        selectedContainer.frame = CGRectMake(selectedContainer.frame.origin.x, selectedContainer.frame.origin.y, selectedContainer.frame.size.width, selectedContainer.frame.size.height);
        selectedPlayer.xPosition = selectedContainer.frame.origin.x;
        selectedPlayer.yPosition = selectedContainer.frame.origin.y;
        currentlyDragging = NO;
        //[selectedPlayer viewSelected];
        for (PlayerTokenViewController *token in allViewControllers) {
            if (bgImage.image == nil) {
                token.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
            } else {
                token.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
            }
        }
    }
}

-(void)viewWillLayoutSubviews {
    for (int i = 0; i < allViewControllers.count; i ++) {
        //89 108
        PlayerTokenViewController *thisPlayer = allViewControllers[i];
        [thisPlayer setViewWidth:89];
        [thisPlayer setViewHeight:108];
    }
}

-(void)viewDidLayoutSubviews {
    NSLog(@"view did layout");
    //need to turn off autolayout for each of the players so that they aren't CONSTANTLY being reset to their starting positions when drawing
    //which, causes viewDidLayoutSubViews to be called automatically within the touchesBegan method.
    
    //ensure on first run that we populate the coordinates array for our 'opposing' players
    if (opposingCoords == nil || opposingCoords.count == 0) {
        opposingCoords = [[NSMutableArray alloc] init];
        for (int i = 0; i < opposingPlayerArray.count; i ++) {
            UIImageView *currentImage = opposingPlayerArray[i];
            NSNumber *xVal = [NSNumber numberWithFloat:currentImage.frame.origin.x];
            NSNumber *yVal = [NSNumber numberWithFloat:currentImage.frame.origin.y];
            NSArray *coordsArray = [[NSArray alloc] initWithObjects:xVal, yVal, nil];
            [opposingCoords addObject:coordsArray];
        }
        
    }
    
    if (isSettingUp) {
        NSLog(@"is setting up is true");
        //need to grab layouts for each player
        for (int i = 0; i < allContainers.count; i ++) {
            PlayerTokenViewController *player = (PlayerTokenViewController*) allViewControllers[i];
            UIView *view = allContainers[i];
            UIImageView *opposingPlayer = opposingPlayerArray[i];
            float floatX = 0.0;
            float floatY = 0.0;
            if (opposingCoords != nil && opposingCoords.count > 0) {
                NSArray *coords = opposingCoords[i];
                
                floatX = [coords[0] floatValue];
                floatY = [coords[1] floatValue];
               //NSLog(@"Coords stored for opposing player number %i are %f and %f", i, floatX, floatY);
            }
            
            view.translatesAutoresizingMaskIntoConstraints = YES;
            opposingPlayer.translatesAutoresizingMaskIntoConstraints = YES;
            if (currentlyDragging) {
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                //opposingPlayer.frame = CGRectMake(opposingPlayer.frame.origin.x, opposingPlayer.frame.origin.y, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                opposingPlayer.frame = CGRectMake(floatX, floatY, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                
            } else {
                view.frame = CGRectMake(player.xPosition, player.yPosition, view.frame.size.width, view.frame.size.height);
                if (opposingCoords != nil && opposingCoords.count > 0) {
                    opposingPlayer.frame = CGRectMake(floatX, floatY, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                }
            }
        }
        return;
    } else {
        NSLog(@"Is setting up was false");
        if (drawingEnabled == NO) {
            for (UIView *view in allContainers) {
                view.translatesAutoresizingMaskIntoConstraints = YES;
                CGRect originalRect = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                [view setFrame:originalRect];
                
            }
            
            for ( int i = 0; i < opposingPlayerArray.count; i ++) {
                UIImageView *opposingPlayer = opposingPlayerArray[i];
                NSArray *coords = opposingCoords[i];
                
                float floatX = [coords[0] floatValue];
                float floatY = [coords[1] floatValue];
                if (opposingCoords != nil && opposingCoords.count == 11) {
                    if (currentlyDragging) {
                        opposingPlayer.frame = CGRectMake(floatX, floatY, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                    } else {
                        opposingPlayer.frame = CGRectMake(floatX, floatY, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                    }
                    
                    CGRect newRect = CGRectMake(floatX, floatY, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                    [opposingPlayer setFrame:newRect];
                    NSLog(@"Coords stored for opposing player number %i are %f and %f", i, floatX, floatY);
                } else {
                    CGRect originalRect = CGRectMake(opposingPlayer.frame.origin.x, opposingPlayer.frame.origin.y, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                    [opposingPlayer setFrame:originalRect];
                }
            }
        } else {
            NSLog(@"DRAWING WAS ENABLED");
            for (UIView *view in allContainers) {
                view.translatesAutoresizingMaskIntoConstraints = YES;
                CGRect originalRect = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                [view setFrame:originalRect];
                
            }
            
            for ( int i = 0; i < opposingPlayerArray.count; i ++) {
                UIImageView *opposingPlayer = opposingPlayerArray[i];
                NSArray *coords = opposingCoords[i];
                
                float floatX = [coords[0] floatValue];
                float floatY = [coords[1] floatValue];
                if (opposingCoords != nil && opposingCoords.count == 11) {
                    if (currentlyDragging) {
                        opposingPlayer.frame = CGRectMake(floatX, floatY, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                    } else {
                        opposingPlayer.frame = CGRectMake(floatX, floatY, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                    }
                    
                    CGRect newRect = CGRectMake(floatX, floatY, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                    [opposingPlayer setFrame:newRect];
                    NSLog(@"Coords stored for opposing player number %i are %f and %f", i, floatX, floatY);
                } else {
                    CGRect newRect = CGRectMake(floatX, floatY, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
                    [opposingPlayer setFrame:newRect];
                }
            }
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"View will disappear");
    if (isTakingPicture == false) {
        [self resetController];
        [nameField resignFirstResponder];
    }
}

-(void)disableDrawing {
    drawingEnabled = false;
    _redButton.hidden = YES;
    _blueButton.hidden = YES;
    _blackButton.hidden = YES;
    _eraserButton.hidden = YES;
    [drawItem setTintColor:[UIColor blueColor]];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    for (UIView *view in allContainers) {
        [view addGestureRecognizer:longRecognizer];
        
    }
}

-(void)resetBackButton {
    [self.navigationItem setHidesBackButton:NO];
    //self.navigationItem.rightBarButtonItems = @[settingsItem, drawItem, rosterItem];
    for (int i = 0; i < self.navigationItem.rightBarButtonItems.count; i ++) {
        UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[i];
        item.enabled = YES;
        
    }
}

-(void)hideBackButton {
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    //self.navigationItem.rightBarButtonItems = @[settingsItem, drawItem, rosterItem];
    for (int i = 0; i < self.navigationItem.rightBarButtonItems.count; i ++) {
        UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[i];
        item.enabled = NO;
        
    }
    
}

//this method lets us update the title displayed within the navigation bar when the user updates it
-(void)updatePlayTitle:(NSString *)title {
    self.navigationItem.title = title;
}

//method to update the theme (background) from the settings menu
-(void)updateTheme:(NSString *)name {
    if ([name  isEqual: @"grass"]) {
        UIImage *grassImage = [UIImage imageNamed:@"Grass_bg.jpg"];
        
        [bgImage setImage:grassImage];
        for (PlayerTokenViewController *token in allViewControllers) {
            token.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        }
    } else if ([name isEqual:@"chalk"]) {
        UIImage *chalkImage = [UIImage imageNamed:@"chalkboard_bg.jpg"];
        [bgImage setImage:chalkImage];
        for (PlayerTokenViewController *token in allViewControllers) {
            token.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        }
    } else if ([name isEqual:@"white"]) {
        [bgImage setImage:nil];
        for (PlayerTokenViewController *token in allViewControllers) {
            //[self.playerPicture setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
            //[self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
            token.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
            token.playerPicture.backgroundColor = [UIColor clearColor];
        }
        
    } else {
        //just as a catchall, set as grass by default
        UIImage *grassImage = [UIImage imageNamed:@"Grass_bg.jpg"];
        
        [bgImage setImage:grassImage];
        for (PlayerTokenViewController *token in allViewControllers) {
            token.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        }
    }
}

-(void)playerTapped:(UILongPressGestureRecognizer *)gestureRecognizer {
    UIView *view = [gestureRecognizer view];
    NSLog(@"Player tapped!");
    
    
    
    for (int i = 0; i < allContainers.count; i ++) {
        UIView *thisView = (UIView*) allContainers[i];
        if (view == thisView) {
            currentSelected = i;
            NSLog(@"CURRENT SELECTED IS:  %i", i);
            break;
        }
    }
    selectedPlayer = allViewControllers[currentSelected];
    NSString *playerPosition = selectedPlayer.position;
    NSString *displayString;
    NSString *titleString;
    if ([playerPosition isEqual:@"Defensive End"] || [playerPosition isEqual:@"Cornerback"] || [playerPosition isEqual:@"Safety"] || [playerPosition isEqual:@"Outside Linebacker"] || [playerPosition isEqual:@"Defensive Tackle"] || [playerPosition isEqual:@"Wide Receiver"] || [playerPosition isEqual:@"Offensive Guard"] || [playerPosition isEqual:@"Running Back"] || [playerPosition isEqual:@"Tight End"]) {
        float xPosition = view.frame.origin.x;
        
        if (xPosition < self.view.frame.size.width / 2) {
            //position should be shown as 'left'
            displayString = [NSString stringWithFormat:@"Left %@", playerPosition];
        } else {
            //position should be shown as 'right'
            displayString = [NSString stringWithFormat:@"Right %@", playerPosition];
        }
        
        if (selectedPlayer.isUtility == true) {
            titleString = [NSString stringWithFormat:@"Utility - %@  (%@)", displayString, selectedPlayer.nameHolder.text];
        } else {
            titleString = [NSString stringWithFormat:@"%@  (%@)", displayString, selectedPlayer.nameHolder.text];
        }
        
    } else {
        if (selectedPlayer.isUtility == true) {
            titleString = [NSString stringWithFormat:@"Utility - %@  (%@)", playerPosition, selectedPlayer.nameHolder.text];
        } else {
            titleString = [NSString stringWithFormat:@"%@  (%@)", playerPosition, selectedPlayer.nameHolder.text];
        }
        
    }
    
    //NSLog(@"Tapped on:  %@ at index %i", playerPosition, currentSelected);
    
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Edit Name",@"Edit Picture", nil];
    [actionSheet showFromRect:[(UIView*)view frame] inView:self.view animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //edit player name was selected
        if ([self.navigationItem.title isEqualToString:@"Create New"]) {
            UIAlertView *renameAlert = [[UIAlertView alloc] initWithTitle:@"Rename Player" message:@"Please rename the current play before editing players." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [renameAlert show];
        } else {
            [self editName];
        }
    } else if (buttonIndex == 1) {
        //add player image was selected
        NSLog(@"Index 1");
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        
        // image picker needs a delegate,
        [imagePickerController setDelegate:self];
        //createNew = true;
        if (createNew == true) {
            NSLog(@"CREATE NEW WAS TRUE");
        } else {
            NSLog(@"CREATE NEW WAS FALSE!");
        }
        isTakingPicture = true;
        // Place image picker on the screen
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:imagePickerController animated:YES completion:^{
                
            }];
        }];
    }
}

//called when the player chooses to edit the player's name from the action sheet
-(void)editName {
    nameField.text = selectedPlayer.playerName;
    darkOverlay.hidden = NO;
    nameField.hidden = NO;
    [darkOverlay setAlpha:0.5];
    [nameField becomeFirstResponder];
    selectedPlayer = allViewControllers[currentSelected];
    
}

- (void)addPhotoObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCameraOverlay) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCameraOverlay) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil ];
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
    
    UIImage *pictureTaken = (UIImage*) [info objectForKey:UIImagePickerControllerOriginalImage];
    if (selectedPlayer == nil) {
       // selectedPlayer = (PlayerTokenViewController*) allViewControllers[currentSelected];
    }
    NSLog(@"Players name that is being edited for new picture is:    %@", selectedPlayer.playerName);
    
    //reduce the size of the captured image, since we only need a thumbnail
    CGSize destinationSize = CGSizeMake(89, 74);
    UIGraphicsBeginImageContext(destinationSize);
    [pictureTaken drawInRect:CGRectMake(0,0,destinationSize.width, destinationSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //apply our thumbnail to the player object, which will eventually save it out to the system
    selectedPlayer.playerPicture.image = thumbnail;
    //[selectedPlayer setImage:thumbnail];
    
    PlayerTokenViewController *token;
    //need to ensure that any other 'instances' of the same player onscreen are updated as well
    
    for (token in allViewControllers) {
        if ([selectedPlayer.playerName isEqual:token.playerName]) {
            NSLog(@"Comparing %@ against %@", selectedPlayer.playerName, token.playerName);
            //matched, so apply the new picture
            token.playerPicture.image = thumbnail;
            token.imageFile = thumbnail;
            
        }
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
    NSError *fetchError = nil;
    NSArray *fetchedPlayers = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    if (fetchedPlayers == nil) {
        NSLog(@"Error fetching players when updating player image!  %@", fetchError);
    } else {
        for (Player *player in fetchedPlayers) {
            if ([player.name isEqual:selectedPlayer.playerName]) {
                NSData *imageData = UIImageJPEGRepresentation(thumbnail, 1.0);
                player.image = imageData;
                NSLog(@"Updated player image");
                break;
            }
        }
        //save out Core Data
        NSError *saveError = nil;
        
        if (![[app managedObjectContext]save:&saveError]) {
            NSLog(@"Error saving core data!  %@", saveError);
        } else {
            NSLog(@"Updated players and saved!");
        }
        
    }
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self dismissViewControllerAnimated:YES completion:^{

        
        //reset selected player for next user interaction
        selectedPlayer = nil;
        imagePickerController = nil;
    }];
}


//need a method to call from the "behind" view controller to let us know when the settings drawer is open
-(void)drawerToggled {
    if (drawerOpen) {
        drawerOpen = false;
    } else {
        drawerOpen = true;
    }
}

//called whenever the user finishes editing the play name, so update the 'front' view controller
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Finished editing text field");
    darkOverlay.hidden = YES;
    nameField.hidden = YES;
}

//this method lets us end editing on the Play name text field when the user taps the 'done' button
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [nameField resignFirstResponder];
    darkOverlay.hidden = YES;
    nameField.hidden = YES;
    return NO;
}

-(BOOL)keyboardWillHide:(NSNotification *)notification {
    //need to manually set x and y positions for all view controllers in case this is a newly created play so viewDidLayout doesn't move things around
    for (int i = 0; i < allViewControllers.count; i ++) {
        PlayerTokenViewController *thisPlayer = allViewControllers[i];
        UIView *playerContainer = allContainers[i];
        thisPlayer.xPosition = playerContainer.frame.origin.x;
        thisPlayer.yPosition = playerContainer.frame.origin.y;
    }
    
    //only want to run this if the settings drawer ISN'T open...meaning they weren't editing the current play's name
    if (!drawerOpen) {
        
        //need to ensure that the name being entered isn't already a player so we don't overwrite someone else
        NSFetchRequest *playerFetch = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
        NSError *fetchError = nil;
        NSArray *allPlayers = [context executeFetchRequest:playerFetch error:&fetchError];
        NSString *inputName = nameField.text;
        if (allPlayers == nil) {
            NSLog(@"Error retrieving players when checking old player name!  %@", fetchError);
        } else {
            for (Player *current in allPlayers) {
                if ([current.name isEqual:inputName]) {
                //another player already has the name that has been put in
                    NSString *errorString = [NSString stringWithFormat:@"Player with name \"%@\" already exists.  Please choose another name.", inputName];
                    UIAlertView *existingPlayerAlert = [[UIAlertView alloc] initWithTitle:@"Player already exists" message:errorString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    
                    [existingPlayerAlert show];
                    return false;
                }
            }
        }
        
        
        
        [nameField resignFirstResponder];
        darkOverlay.hidden = YES;
        nameField.hidden = YES;
        selectedPlayer = allViewControllers[currentSelected];
        NSString *oldName = selectedPlayer.playerName;
        [selectedPlayer setName:nameField.text];
        selectedPlayer.playerName = nameField.text;
        
        //need to overwrite the original name of this player to reflect the new name
        
        if (allPlayers == nil) {
            NSLog(@"Error retrieving players after updating player name!  %@", fetchError);
        } else {
            Player *editedPlayer;
            for (Player *current in allPlayers) {
                if ([current.name isEqual:oldName]) {
                    editedPlayer = current;
                    editedPlayer.name = nameField.text;
                    break;
                }
            }
            //now that we have the correct player, replace the old name with the one the user entered
            
            NSError *saveError;
            if (![[app managedObjectContext]save:&saveError]) {
                NSLog(@"Error overwriting and saving when replacing player's name!  %@", saveError);
            }
            
            //set up an array to hold corresponding properties to be reused for both offense and defense plays (to loop through while checking)
            NSArray *attributesArray = [NSArray arrayWithObjects:@"player0Name", @"player1Name", @"player2Name", @"player3Name", @"player4Name", @"player5Name", @"player6Name", @"player7Name", @"player8Name", @"player9Name", @"player10Name", nil];
            
            //also need to go through any already created plays and ensure we are updating this player's name there too so we don't load in a 'blank' player
            NSFetchRequest *fetchRequest;
            if ([playType isEqual:@"offense"]) {
                //set the fetch request to grab any offense plays, since thats the only place this player would appear
                fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"OffensePlay"];
                NSError *fetchError = nil;
                NSArray *retrievedPlays = [context executeFetchRequest:fetchRequest error:&fetchError];
                
                if (retrievedPlays == nil) {
                    NSLog(@"Error fetching list of plays when updating player name!  %@", fetchError);
                } else {
                    for (OffensePlay *fetchedOffense in retrievedPlays) {
                        
                        for (int i = 0; i < attributesArray.count; i ++) {
                            NSString *playerOldFetched = [fetchedOffense valueForKey:attributesArray[i]];
                            if ([playerOldFetched isEqual:oldName]) {
                                //set the newer name to replace the old
                                [fetchedOffense setValue:nameField.text forKey:attributesArray[i]];
                            }

                            
                        }
                    }
                    //save all plays
                    NSError *offenseSaveError;
                    if (![[app managedObjectContext]save:&saveError]) {
                        NSLog(@"Error overwriting and saving when replacing player's name!  %@", offenseSaveError);
                    }
                }
            } else {
                //set the fetch request to grab any defense plays, since thats the only place this player would appear
                fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DefensePlay"];
                NSError *fetchError = nil;
                NSArray *retrievedPlays = [context executeFetchRequest:fetchRequest error:&fetchError];
                
                if (retrievedPlays == nil) {
                    NSLog(@"Error fetching list of plays when updating player name!  %@", fetchError);
                } else {
                    for (DefensePlay *fetchedDefense in retrievedPlays) {
                        for (int i = 0; i < attributesArray.count; i ++) {
                            NSString *playerOldFetched = [fetchedDefense valueForKey:attributesArray[i]];
                            if ([playerOldFetched isEqual:oldName]) {
                                [fetchedDefense setValue:nameField.text forKey:attributesArray[i]];
                            }
                        }
                    }
                    //save all plays
                    NSError *offenseSaveError;
                    if (![[app managedObjectContext]save:&saveError]) {
                        NSLog(@"Error overwriting and saving when replacing player's name!  %@", offenseSaveError);
                    }
                    
                }
            }
            
            
            
            
            
            //now that we've updated the actual player's name, we need to check for duplicates of the old player instance that might have been onscreen
            [self checkDuplicates:oldName withPlayer:editedPlayer];
        }
    }
    return true;
}

//this method updates players if more than one instance of a player entity is onscreen so we can keep them updated
//after the user updates a player's name
-(void)checkDuplicates:(NSString*)oldName withPlayer:(Player*)editedPlayer {
    BOOL didUpdate = false;
    NSLog(@"check Duplicates runs!");
    //after saving out the play, if there are other instances of the old player onscreen, we need to update them, so reload the entire play
    for (PlayerTokenViewController *thisPlayer in allViewControllers) {
        
        if ([thisPlayer.playerName isEqual:oldName]) {
            //another instance of the "old" player was found onscreen so update it
            thisPlayer.playerName = editedPlayer.name;
            thisPlayer.position = editedPlayer.position;
            thisPlayer.nameHolder.text = editedPlayer.name;
            didUpdate = true;
        }
    }
    //now save the play so there aren't any 'nil' Players loaded later
    [self savePlay:nil];
    swappedName = nil;
}

-(void)swapPlayers:(NSString*)type {
    
    matchedPlayer = [[NSMutableArray alloc] init];
    for (int i = 0; i < allContainers.count; i ++) {
        NSString *positionString = [(PlayerTokenViewController*) allViewControllers[i] position];
        
        if ([positionString isEqual:type]) {
            [matchedPlayer addObject:allContainers[i]];
        }
        for (int i = 0; i < matchedPlayer.count; i++) {
            UIView *matchedView = matchedPlayer[i];
            [matchedView.layer setCornerRadius: 8];
            matchedView.backgroundColor = [UIColor colorWithRed:0.024 green:0.337 blue:0.569 alpha:1];
        }
        //NSLog(@"%lu players matched!", (unsigned long)matchedPlayer.count);
    }
    //NSLog(@"swap players called on type:  %@", type);
    rosterHelper.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    rosterHelper.hidden = NO;
    
    
    secondTap.delegate = self;
    cancelTap.delegate = self;
    
    
    NSMutableArray *allViews = [[NSMutableArray alloc] init];
    for (UIView *subview in allViews) {
        [allViews addObject:subview];
    }
    
    for (int i = 0; i < self.view.subviews.count; i++) {
        UIView *view = self.view.subviews[i];
        
        for (int i = 0; i < allContainers.count; i++) {
            UIView *view = allContainers[i];
            [view removeGestureRecognizer:tapRecognizer];
            
        }
        
        for (int i = 0; i < matchedPlayer.count; i ++) {
            secondTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replacePlayer:)];
            cancelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelection)];
            secondTap.delegate = self;
            cancelTap.delegate = self;
            if (view == matchedPlayer[i]) {
                [view addGestureRecognizer:secondTap];
                i++;
                continue;
            } else {
                [view addGestureRecognizer:cancelTap];
            }
        }
        
        for (int i = 0; i < allContainers.count; i ++) {
            UIView *thisView = allContainers[i];
            for (UIGestureRecognizer *recognizer in thisView.gestureRecognizers) {
                [thisView removeGestureRecognizer:recognizer];
            }
            secondTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replacePlayer:)];
            secondTap.delegate = self;
            [thisView addGestureRecognizer:secondTap];
        }

        
    }
    cancelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelection)];
    [_drawingCanvas addGestureRecognizer:cancelTap];
    [_tempCanvas addGestureRecognizer:cancelTap];
    [darkOverlay addGestureRecognizer:cancelTap];
    [bgImage addGestureRecognizer:cancelTap];
    [self.view addGestureRecognizer:cancelTap];
}

-(void)replacePlayer:(UIGestureRecognizer *)sender{
    NSLog(@"Replace Player fires!");
    UIView *matchedView;
    UIView *tappedView = sender.view;
    int controllerToReplace;
    for (int i = 0; i < allContainers.count; i++) {
        UIView *view = allContainers[i];
        
        if (view == tappedView) {
            matchedView = view;
            break;
        } else {
        }
    }
    
    //now actually swap the player object and view out from the respective arrays
    for (int i = 0; i < allContainers.count; i ++) {
        if (matchedView == allContainers[i]) {
            controllerToReplace = i;
            break;
        }
    }
    //grab instance of player we're replacing
    PlayerTokenViewController *playerReplacing = allViewControllers[controllerToReplace];
    
    [playerToSwap setXPosition:playerReplacing.xPosition];
    [playerToSwap setYPosition:playerReplacing.yPosition];
    
    NSString *swapPosition = playerToSwap.position;
    NSString *replacingPosition = playerReplacing.position;
    NSLog(@"Swapping in:  %@    Swapping out:  %@", swapPosition, replacingPosition);
    
    if (![playerToSwap.playerName isEqualToString:playerReplacing.playerName]) {
        if (![swapPosition isEqualToString:replacingPosition]) {
            positionToSwap = replacingPosition;
            UIAlertView * swapAlert = [[UIAlertView alloc] initWithTitle:@"Positions mismatch" message:@"Do you want the player swapping in to keep their position, or play as a utility player?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Keep Position", @"Utility", nil];
            swapAlert.tag = 99;
            [swapAlert show];
        }
    } else {
        playerToSwap.isUtility = false;
    }
    
    //playerToSwap.view.frame = matchedView.frame;
    playerToSwap.view.frame = matchedView.bounds;
    [playerReplacing willMoveToParentViewController:nil];
    [self addChildViewController:playerToSwap];
    
    [self transitionFromViewController:playerReplacing toViewController:playerToSwap duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished){
        [playerReplacing removeFromParentViewController];
        [playerToSwap didMoveToParentViewController:self];
        
        [allViewControllers replaceObjectAtIndex:controllerToReplace withObject:playerToSwap];
    }];
    
    
    for (UIView *view in allContainers) {
        for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
            [view removeGestureRecognizer:gesture];
        }
    }
    
    //finally turn off 'replace' mode by getting rid of the helper object and reassigning the single tap to edit gesture
    for (int i = 0; i < allContainers.count; i++) {
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.delegate = self;
        tapRecognizer.delaysTouchesBegan = YES;
        longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(playerLongPressed:)];
        longRecognizer.minimumPressDuration = 0.3;
        longRecognizer.delegate = self;
        //fix for iOS7 and above
        longRecognizer.delaysTouchesBegan = YES;
        [allContainers[i] addGestureRecognizer:tapRecognizer];
        [allContainers[i] addGestureRecognizer:longRecognizer];
        
    }
    
    NSArray *allDrawingObjects = [[NSArray alloc] initWithObjects:_redButton,_blueButton, _blackButton, _eraserButton, nil];
    
    for (UIView *view in allDrawingObjects) {
        for (UIGestureRecognizer *recognizer in [view gestureRecognizers]) {
            [view removeGestureRecognizer:recognizer];
        }
    }
    
    //need to manually reset the targets for our drawing buttons
    [_redButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_blueButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_blackButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_eraserButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
    rosterHelper.hidden = YES;
    for (int i = 0; i < matchedPlayer.count; i ++) {
        UIView *matchedView = matchedPlayer[i];
        matchedView.backgroundColor = [UIColor clearColor];
    }
}

-(void)setPlayerToSwap:(PlayerTokenViewController *)player {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    playerToSwap = [storyboard instantiateViewControllerWithIdentifier:@"PlayerToken"];
    //playerToSwap = [[PlayerTokenViewController alloc] init];
    playerToSwap.playerName = player.playerName;
    playerToSwap.imageFile = player.imageFile;
    playerToSwap.position = player.position;
    playerToSwap.viewWidth = 89;
    playerToSwap.viewHeight = 108;
}

-(void)cancelSelection {
    NSLog(@"Cancel selection fires!");
    rosterHelper.hidden = YES;
    for (int i = 0; i < matchedPlayer.count; i++) {
        UIView *view = matchedPlayer[i];
        view.backgroundColor = [UIColor clearColor];
    }
    
    for (UIView *view in allContainers) {
        for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
            [view removeGestureRecognizer:gesture];
        }
    }
    
    //finally turn off 'replace' mode by getting rid of the helper object and reassigning the single tap to edit gesture
    for (int i = 0; i < allContainers.count; i++) {
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.delegate = self;
        tapRecognizer.delaysTouchesBegan = YES;
        longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(playerLongPressed:)];
        longRecognizer.minimumPressDuration = 0.3;
        longRecognizer.delegate = self;
        //fix for iOS7 and above
        longRecognizer.delaysTouchesBegan = YES;
        [allContainers[i] addGestureRecognizer:tapRecognizer];
        [allContainers[i] addGestureRecognizer:longRecognizer];
        
    }
    
    NSArray *allDrawingObjects = [[NSArray alloc] initWithObjects:_redButton,_blueButton, _blackButton, _eraserButton, nil];
    
    for (UIView *view in allDrawingObjects) {
        for (UIGestureRecognizer *recognizer in [view gestureRecognizers]) {
            [view removeGestureRecognizer:recognizer];
        }
    }
    
    //need to manually reset the targets for our drawing buttons
    [_redButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_blueButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_blackButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_eraserButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)applyOpposingFormation:(NSMutableArray *)coords {
    for (int i = 0; i < opposingPlayerArray.count; i ++) {
        NSArray *currentCoords = coords[i];
        UIImageView *opposingPlayer = opposingPlayerArray[i];
        
        float x = [(NSNumber*)[currentCoords objectAtIndex:0] floatValue];
        float y = [(NSNumber*)[currentCoords objectAtIndex:1] floatValue];
        
        opposingCoords = [[NSMutableArray alloc] initWithArray:coords];
        
        opposingPlayer.frame = CGRectMake(x, y, opposingPlayer.frame.size.width, opposingPlayer.frame.size.height);
    }
}

-(void)applyFormation:(NSMutableArray*)coords {

    isSettingUp = true;
    for (int i = 0; i < allViewControllers.count; i ++) {
        NSArray *currentCoords = coords[i];
        PlayerTokenViewController *player = allViewControllers[i];
        UIView *container = allContainers[i];
        
        //grab each set of coordinates and apply to a player (for now, disregard the player positions)
        float x = [(NSNumber *)[currentCoords objectAtIndex:0] floatValue];
        float y = [(NSNumber *)[currentCoords objectAtIndex:1] floatValue];
        player.xPosition = x;
        player.yPosition = y;
        container.frame = CGRectMake(x, y, container.frame.size.width, container.frame.size.height);
    }
    
    [self applyPlayers];
    
}
//method to basically load in/replace players on field with those that match the correct layout of the passed play layout
-(void)applyPlayers {
    BOOL insufficientPlayers = false;
    //use previously retrieved array of 'correct' players according to playtype
    
    //manually reset each of the view controllers to not be a utility position
    for (PlayerTokenViewController *player in allViewControllers) {
        player.isUtility = false;
    }
    
    if ([layoutSelected isEqual:@"offense_t"]) {
        positionsArray = [[NSMutableArray alloc] initWithObjects:@"Tight End", @"Offensive Tackle", @"Offensive Guard", @"Center", @"Offensive Guard", @"Offensive Tackle", @"Tight End", @"Running Back", @"Quarterback", @"Running Back", @"Running Back", nil];
    } else if ([layoutSelected isEqual:@"offense_i"]) {
        positionsArray = [[NSMutableArray alloc] initWithObjects:@"Wide Receiver", @"Offensive Tackle", @"Offensive Guard", @"Center", @"Offensive Guard", @"Offensive Tackle", @"Tight End", @"Running Back", @"Quarterback", @"Wide Receiver", @"Running Back", nil];
    } else if ([layoutSelected isEqual:@"offense_spread"]) {
        positionsArray = [[NSMutableArray alloc] initWithObjects:@"Wide Receiver", @"Offensive Tackle", @"Offensive Guard", @"Center", @"Offensive Guard", @"Offensive Tackle", @"Wide Receiver", @"Wide Receiver", @"Quarterback", @"Wide Receiver", @"Running Back", nil];
    } else if ([layoutSelected isEqual:@"defense_4-3"]) {
        positionsArray = [[NSMutableArray alloc] initWithObjects:@"Cornerback", @"Outside Linebacker", @"Defensive End", @"Defensive Tackle", @"Defensive Tackle", @"Defensive End", @"Cornerback", @"Safety", @"Middle Linebacker", @"Outside Linebacker", @"Safety", nil];
    } else if ([layoutSelected isEqual:@"defense_3-4"]) {
        positionsArray = [[NSMutableArray alloc] initWithObjects:@"Cornerback", @"Outside Linebacker", @"Outside Linebacker", @"Defensive End", @"Defensive Tackle", @"Defensive End", @"Cornerback", @"Safety", @"Outside Linebacker", @"Outside Linebacker", @"Safety", nil];
    } else if ([layoutSelected isEqual:@"defense_46"]) {
        positionsArray = [[NSMutableArray alloc] initWithObjects:@"Cornerback", @"Defensive End", @"Defensive Tackle", @"Defensive Tackle", @"Defensive End", @"Outside Linebacker", @"Cornerback", @"Safety", @"Middle Linebacker", @"Outside Linebacker", @"Safety", nil];
    }
    
    //now assign players from roster according to the positions set in the array, which is now the correct order
    //according to where the view controllers are now placed on the screen
    NSMutableArray *playersUsed = [[NSMutableArray alloc] init];
    NSMutableArray *unfilledControllers = [[NSMutableArray alloc] init];
    for (int i = 0; i < positionsArray.count; i++) {
        NSString *positionToFill = positionsArray[i];
        
        PlayerTokenViewController *token = (PlayerTokenViewController*) allViewControllers[i];
        BOOL wasMatched = false;
        for (Player *player in correctPlayers) {
            
            if ([player.position isEqual:positionToFill]) {
                if (!([playersUsed containsObject:player.name])) {
                    wasMatched = true;
                    
                    token.playerName = player.name;
                    token.nameHolder.text = player.name;
                    token.position = player.position;
                    UIImage *playerImage = [UIImage imageWithData:player.image];
                    token.imageFile = playerImage;
                    token.playerPicture.image = playerImage;
                    [playersUsed addObject:player.name];
                    break;
                } else {
                    continue;
                }
            }
        }
        if (wasMatched == false) {
            NSArray *unMatchedToken = [[NSArray alloc] initWithObjects:token, positionToFill, nil];
            [unfilledControllers addObject:unMatchedToken];
            insufficientPlayers = true;
        }
    }
    
    //finally, go back through and attempt to 'rematch' the unmatched view controller positions
    //this basically allows us to go 'out of order' so we aren't applying a player that would otherwise be used later
    for (int i = 0; i < unfilledControllers.count; i ++) {
        NSArray *currentToFill = unfilledControllers[i];
        PlayerTokenViewController *token = (PlayerTokenViewController*) currentToFill[0];
        NSString *positionToMatch = currentToFill[1];
        BOOL wasMatched = false;
        
        for (Player *player in correctPlayers) {
            if ([player.position isEqual:positionToMatch]) {
                if (!([playersUsed containsObject:player.name])) {
                    wasMatched = true;
                    token.playerName = player.name;
                    token.nameHolder.text = player.name;
                    token.position = player.position;
                    token.isUtility = false;
                    UIImage *playerImage = [UIImage imageWithData:player.image];
                    token.imageFile = playerImage;
                    token.playerPicture.image = playerImage;
                    [playersUsed addObject:player.name];
                    break;
                }
            }
        }
        
        if (wasMatched == false) {
            //basically, at this point it's the end of the line, just dump someone in who hasn't been used yet...
            for (Player *player in correctPlayers) {
                if (!([playersUsed containsObject:player.name])) {
                    token.playerName = player.name;
                    token.nameHolder.text = player.name;
                    
                    token.position = positionToMatch;
                    token.isUtility = true;
                    UIImage *playerImage = [UIImage imageWithData:player.image];
                    token.imageFile = playerImage;
                    token.playerPicture.image = playerImage;
                    [playersUsed addObject:player.name];
                    break;
                }
            }
        }
    }
    
    //need to let user know they didn't have enough players to correctly fill in this play layout
    if (insufficientPlayers) {
        UIAlertView *insufficientAlert = [[UIAlertView alloc] initWithTitle:@"Insufficient Players" message:@"Unfortunately, your roster didn't have enough players of a certain type to layout this default play.  Other players were assigned Utility positions instead." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [insufficientAlert show];
    }
}

-(NSString*)getPlayType {
    NSLog(@"Playtype is:  %@", playType);
    return playType;
}

-(void)autoSave:(NSTimer*)timer {
    NSLog(@"AUTOSAVING PLAY!");
    [self savePlay:nil];
}

-(void)enableAutoSave {
    autoTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(autoSave:) userInfo:nil repeats:YES];
}

-(void)disableAutoSave {
    [autoTimer invalidate];
    autoTimer = nil;
}

@end
