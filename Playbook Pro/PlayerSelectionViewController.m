//
//  PlayerSelectionViewController.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/25/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "PlayerSelectionViewController.h"
#import "PlayerSelectTableViewCell.h"
#import "SWRevealViewController.h"
#import "PlayCreationViewController.h"
#import "AppDelegate.h"
#import "Player.h"
#import "OffensePlay.h"
#import "DefensePlay.h"

@interface PlayerSelectionViewController ()

@end

@implementation PlayerSelectionViewController
@synthesize playerTable, playType;

UINavigationController *frontNavigationController;
PlayCreationViewController *playView;
NSMutableArray *positions;
NSString *type;
NSArray *rosterArray;
NSManagedObjectContext *context;
AppDelegate *app;
NSMutableArray *playerRoster;
PlayerSelectTableViewCell *selectedCell;

- (void)viewDidLoad {
    
    //set up our two vars that give us what we need to work with Core Data
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    context = app.managedObjectContext;
    
    rosterArray = [[NSArray alloc] initWithObjects:@"customPlayer1", @"customPlayer2", @"customPlayer3", @"customPlayer4", @"customPlayer5", @"customPlayer6", @"customPlayer7", @"customPlayer8", @"customPlayer9", @"customPlayer10", @"customPlayer11", @"customPlayer12", @"customPlayer13", nil];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    frontNavigationController = (UINavigationController *) self.revealViewController.frontViewController;
    if (frontNavigationController != nil) {
        if ([frontNavigationController.topViewController isKindOfClass:[PlayCreationViewController class]]) {
            playView = (PlayCreationViewController *) frontNavigationController.topViewController;
            [playView disableDrawing];
            [playView hideBackButton];
        }
    }

    
    
    
    
    UINib *customCell = [UINib nibWithNibName:@"PlayerSelectTableViewCell" bundle:nil];
    if (customCell != nil) {
        [playerTable registerNib:customCell forCellReuseIdentifier:@"playerCell"];
    }
    playerTable.rowHeight = 165;
    playerTable.backgroundColor = [UIColor colorWithRed:0.004 green:0.494 blue:0.522 alpha:1];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell"];
    if (cell != nil) {
        cell.backgroundColor = [UIColor clearColor];
        cell.playerImage.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        cell.positionLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        cell.playerName.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        //cell.playerName.text = rosterArray[indexPath.row];
        Player *currentPlayer = playerRoster[indexPath.row];
        cell.playerName.text = currentPlayer.name;
        UIImage *playerImage = [UIImage imageWithData:currentPlayer.image];
        cell.playerImage.image = playerImage;
        [cell.layer setCornerRadius:8];
        [cell.backgroundView.layer setCornerRadius:8];
        
        cell.positionLabel.text = currentPlayer.position;
        
        return cell;        
    }
    
    return nil;
}

-(void)viewWillAppear:(BOOL)animated {
    frontNavigationController = (UINavigationController *) self.revealViewController.frontViewController;
    if (frontNavigationController != nil) {
        if ([frontNavigationController.topViewController isKindOfClass:[PlayCreationViewController class]]) {
            playView = (PlayCreationViewController *) frontNavigationController.topViewController;
            [playView disableDrawing];
            [playView hideBackButton];
            [playView cancelSelection];
        }
    }
    
    type = [playView getPlayType];
    NSLog(@"Type is:  %@", type);
    if ([type  isEqual: @"offense"]) {
        NSLog(@"Type is offense");
        positions = [[NSMutableArray alloc] initWithObjects:@"Center",@"Offensive Guard",@"Offensive Guard",@"Offensive Tackle",@"Offensive Tackle",@"Tight End", @"Wide Receiver", @"Wide Receiver", @"Running Back",@"Running Back",@"Quarterback",@"Punter", nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *secondError = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&secondError];
        if (fetchedObjects == nil) {
            NSLog(@"Problem retrieving objects!  %@", secondError);
        }
        //set up an array to hold only players who belong to the appropriate roster
        playerRoster = [[NSMutableArray alloc] init];
        
        //add only players that match the current playType (offense or defense) to the array
        for (Player *retrievedPlayer in fetchedObjects) {
            if ([retrievedPlayer.team isEqual:type] || [retrievedPlayer.team isEqual:@"special"]) {
                
                [playerRoster addObject:retrievedPlayer];
            }
        }
    } else if ([type isEqual:@"defense"]) {
        NSLog(@"Type is defense");
        positions = [[NSMutableArray alloc] initWithObjects:@"Defensive Tackle",@"Defensive Tackle",@"Defensive End",@"Defensive End",@"Middle Linebacker",@"Outside Linebacker",@"Outside Linebacker",@"Cornerback",@"Cornerback",@"Safety",@"Safety", nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *secondError = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&secondError];
        if (fetchedObjects == nil) {
            NSLog(@"Problem retrieving objects!  %@", secondError);
        }
        //set up an array to hold only players who belong to the appropriate roster
        playerRoster = [[NSMutableArray alloc] init];
        
        //add only players that match the current playType (offense or defense) to the array
        for (Player *retrievedPlayer in fetchedObjects) {
            if ([retrievedPlayer.team isEqual:type] || [retrievedPlayer.team isEqual:@"special"]) {
                
                [playerRoster addObject:retrievedPlayer];
            }
        }
        
    }
    [playerTable reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [playView resetBackButton];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return static number for now until we implement the roster system later (so the user can actually add in real players)
    return playerRoster.count;
}

//set larger custom size for section header so it matches the nav bar height in the creation view
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0, 0, 90, 44);
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 2;
    if ([type  isEqual: @"offense"]) {
        titleLabel.text = @"Offense Roster";
    } else {
        titleLabel.text = @"Defense Roster";
    }
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:titleLabel];
    headerView.backgroundColor = [UIColor colorWithRed:0.063 green:0.486 blue:0.518 alpha:0.7];
    return headerView;
}

//need to detect if the user chooses to override placing the player onscreen more than once
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *positionString = selectedCell.positionLabel.text;
        [playView swapPlayers:positionString];
        [self.revealViewController rightRevealToggleAnimated:YES];
        
        
        PlayerTokenViewController *selectedPlayer = [[PlayerTokenViewController alloc] init];
        
        //for now (POC) manually assign values to a new player token instance until be actually load in dynamic ones
        
        //NSLog(@"Selected position to swap:  %@", positionString);
        
        selectedPlayer.playerName = selectedCell.playerName.text;
        //[selectedPlayer setImage:cell.playerImage.image];
        selectedPlayer.imageFile = selectedCell.playerImage.image;
        //[selectedPlayer setPosition:cell.positionLabel.text];
        selectedPlayer.position = selectedCell.positionLabel.text;
        //playView.playerToSwap = selectedPlayer;
        [playView setPlayerToSwap:selectedPlayer];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected cell:  %lo", (long)indexPath.row);
    selectedCell = (PlayerSelectTableViewCell*) [playerTable cellForRowAtIndexPath:indexPath];
    NSString *selectedPosition = selectedCell.positionLabel.text;
    
    NSString *selectedName = selectedCell.playerName.text;
    
    NSLog(@"Position selected was:  %@", selectedPosition);
    frontNavigationController = (UINavigationController *) self.revealViewController.frontViewController;
    if (frontNavigationController != nil) {
        if ([frontNavigationController.topViewController isKindOfClass:[PlayCreationViewController class]]) {
            playView = (PlayCreationViewController *) frontNavigationController.topViewController;
            [playView disableDrawing];
            [playView hideBackButton];
        }
    }
    //ensure that the user doesn't already have this player "in" the play (on the main screen already)
    NSArray *onScreenPlayers = playView.allViewControllers;
    for (PlayerTokenViewController *playerToken in onScreenPlayers) {
        if ([playerToken.playerName isEqual:selectedName]) {
            NSString *alertString = [NSString stringWithFormat:@"%@ is already used in the current play.", selectedName];
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Player Already Assigned" message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Override", nil];
            
            [saveAlert show];
            
            return;
        }
    }
    
    NSString *positionString = selectedCell.positionLabel.text;
    [playView swapPlayers:positionString];
    [self.revealViewController rightRevealToggleAnimated:YES];
    
    PlayerTokenViewController *selectedPlayer = [[PlayerTokenViewController alloc] init];
    selectedPlayer.playerName = selectedName;
    selectedPlayer.imageFile = selectedCell.playerImage.image;
    selectedPlayer.position = selectedCell.positionLabel.text;
    [playView setPlayerToSwap:selectedPlayer];
}

@end
