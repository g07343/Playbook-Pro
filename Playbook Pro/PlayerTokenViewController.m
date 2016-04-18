//
//  PlayerTokenViewController.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/23/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "PlayerTokenViewController.h"
#import "AppDelegate.h"
#import "Player.h"

@interface PlayerTokenViewController ()

@end

@implementation PlayerTokenViewController

@synthesize playerName, playerPicture, position, imageFile, nameHolder, viewWidth, viewHeight, isUtility;

BOOL isSelected;
NSManagedObjectContext *context;
AppDelegate *app;
Player *thisPlayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isSelected = false;
    isUtility = false;
    [self.playerPicture setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
    [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
    
    [self.view.layer setCornerRadius:8];
    
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    context = app.managedObjectContext;
    
    viewWidth = -1;
    
}

-(void)updateView {
    
    if (imageFile != nil) {
        playerPicture.image = imageFile;
    }
    if (playerName != nil) {
        nameHolder.text = playerName;
    }
    if (position != nil) {
        NSLog(@"Player position is:  %@", position);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)willMoveToParentViewController:(UIViewController *)parent {
    if (imageFile != nil) {
        playerPicture.image = imageFile;
    }
    if (playerName != nil) {
        nameHolder.text = playerName;
    }
    if (position != nil) {
        NSLog(@"Player position is:  %@", position);
    }
    if (viewWidth != -1 && _xPosition != -1) {
        //self.view.frame = CGRectMake(_xPosition, _yPosition, viewWidth, viewHeight);
    }
}

//method to update the name for this particular player object
-(void)setName:(NSString *)name {
    self.nameHolder.text = name;
    thisPlayer.name = name;
    
    //save out Core Data
    NSError *saveError = nil;
    
    if (![[app managedObjectContext]save:&saveError]) {
        NSLog(@"Error saving core data!  %@", saveError);
    } else {
        NSLog(@"Success updating player's name");
    }
    
}

-(void)viewSelected {
        if (isSelected == false) {
            isSelected = true;
            [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    } else {
        isSelected = false;
        [self.view setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
    }
}
//set our player
-(void)setPosition:(NSString *)passedString {
    position = passedString;
}

//set the players image, in case the user decides to take a picture
-(void)setImage:(UIImage *)image {
    
    [playerPicture setImage:image];
    
    imageFile = image;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSLog(@"PlayerName when updating image data is:  %@", playerName);
    //ensure we have a valid reference to the correct Core Data Player entity
    if (thisPlayer == nil) {
        //grab the correct player so we can access it later in the event the user modifies him/her
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
        NSError *secondError = nil;
        NSArray *fetchedPlayers = [context executeFetchRequest:fetchRequest error:&secondError];
        
        if (fetchedPlayers == nil) {
            NSLog(@"Error fetching list of players!  %@", secondError);
        }
        
        for (Player *player in fetchedPlayers) {
            if ([player.name isEqual:playerName]) {
                //found the player this view controller represents, so update the image and manually save Core Data
                thisPlayer = player;
                break;
            }
        }
    }
    
    NSManagedObjectContext *managedContext = thisPlayer.managedObjectContext;
    if (!thisPlayer.image) {
        [managedContext performBlock:^{
        
        
        }];
    }
    
    thisPlayer.image = imageData;
    //[thisPlayer setImage:imageData];
    
    if (thisPlayer.updated == true) {
        NSLog(@"Updated was true");
    } else {
        NSLog(@"Nothing was updated...");
    }
    
    
    //save out Core Data
    NSError *saveError = nil;
    
    if (![[app managedObjectContext]save:&saveError]) {
        NSLog(@"Error saving core data!  %@", saveError);
    }
}

@end
