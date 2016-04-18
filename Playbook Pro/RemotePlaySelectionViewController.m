//
//  RemotePlaySelectionViewController.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 4/16/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "RemotePlaySelectionViewController.h"
#import "PlaySelectionViewController.h"
#import <Parse/Parse.h>

@interface RemotePlaySelectionViewController ()

@end

@implementation RemotePlaySelectionViewController
@synthesize playSelection, loadingView, playType;

BOOL hasLoaded;
PlaySelectionViewController *parent;
NSArray *retrievedPlays;
NSMutableArray *pfFileArray;
NSMutableArray *imageArray;
NSMutableArray *canvasArray;
NSMutableDictionary *tempHolder;
NSMutableDictionary *tempCanvasHolder;
NSTimer *checkTimer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    hasLoaded = false;
    playSelection.rowHeight = 120;
    playSelection.backgroundColor = [UIColor clearColor];
    
    PFQuery *remoteQuery;
    //grab the remote plays according to type assigned
    if ([playType isEqual:@"offense"]) {
        remoteQuery =  [PFQuery queryWithClassName:@"OffensePlay"];
    } else {
        remoteQuery =  [PFQuery queryWithClassName:@"DefensePlay"];
    }
    
    //perform query in background and refresh tableview once data is loaded in
    [remoteQuery findObjectsInBackgroundWithBlock:^(NSArray *playsArray, NSError *error){
        //once the array of plays has been retrieved, load in
        if (!error) {
            //set our local array to the one returned
            retrievedPlays = playsArray;
            
            pfFileArray = [[NSMutableArray alloc] init];
            //since our images were saved as PFFiles (essentially links to download the actual images) add to an array and load each in
            for (PFObject *playObject in retrievedPlays) {
                PFFile *imageFile = [playObject objectForKey:@"snapshot"];
                PFFile *canvasFile = [playObject objectForKey:@"drawCanvas"];
                NSArray *holder = [[NSArray alloc] initWithObjects:imageFile, canvasFile, nil];
                
                [pfFileArray addObject:holder];
            }
            NSLog(@"Number of remote plays retrieved:  %lu", (unsigned long)retrievedPlays.count);
            //fire seperate method to load in images in background, and reset table view one done
            [self getThumbs];
        }
    }];
}

-(void)getThumbs {
    //grab all images from each PFFile object so we can update our tableView
    imageArray = [[NSMutableArray alloc] init];
    canvasArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < pfFileArray.count; i ++) {
        [imageArray addObject:[NSNull null]];
        [canvasArray addObject:[NSNull null]];
    }
    
    //set up our dicitonary to temporarily hold the images so we can 'reorder' them once they're done downloading them
    tempHolder = [[NSMutableDictionary alloc] init];
    
    //set up a timer to repeatedly call the check method
    checkTimer = [NSTimer timerWithTimeInterval:0.8f target:self selector:@selector(checkLoadedStatus) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:checkTimer forMode:NSRunLoopCommonModes];
    
    for (int i = 0; i < pfFileArray.count; i ++) {
        NSArray *holder = [pfFileArray objectAtIndex:i];
        PFFile *imageFile = [holder objectAtIndex:0];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
            if (!error) {
                UIImage *playThumb = [UIImage imageWithData:imageData];
                //[imageArray addObject:playThumb];
                NSString *intString = [NSString stringWithFormat:@"%d", i];
                
                //need to convert the UIImage for storage within dictionary
                NSData *imageData = UIImageJPEGRepresentation(playThumb, 1.0);
                
                [tempHolder setValue:imageData forKey:intString];
                NSLog(@"Play thumb loaded!!!");
                //[self checkLoadedStatus];
            } else {
                NSLog(@"Error retrieving thumb of remote play! Error:  %@", error.description);
            }
        }];
        NSLog(@"After the block statement!");
        //[self checkLoadedStatus];
    }
}

-(void)checkLoadedStatus {
    NSLog(@"Check loaded status fires!");
    NSArray *dictionaryCount = [tempHolder allKeys];
    if (dictionaryCount.count == pfFileArray.count) {
        //since we know we have all of the images retrieved, invalidate our timer
        [checkTimer invalidate];
        checkTimer = nil;
        
        //now that we have all of the actual playThumbs, we need to correctly order them again (since they were loaded in asycnhronisly)
        
        for (NSString *key in dictionaryCount) {
            //convert back to an int
            int currentPlace = [key integerValue];
            NSData *imageData = [tempHolder valueForKey:key];
            
            UIImage *playThumb = [UIImage imageWithData:imageData];
            NSLog(@"DEBUG....BEFORE inserting!!!");
            if (imageArray == nil) {
                imageArray = [[NSMutableArray alloc] initWithCapacity:dictionaryCount.count];
            }
            [imageArray replaceObjectAtIndex:currentPlace withObject:playThumb];
            //[imageArray insertObject:playThumb atIndex:currentPlace];
            NSLog(@"DEBUG....AFTER inserting!!!");
        }
        
        //now load in the drawn canvas images
        [self getCanvasImages];
    }
}

-(void)getCanvasImages {
    //reset our temporary dictionary to reuse
    tempCanvasHolder = [[NSMutableDictionary alloc] init];
    
    //once again, use our timer to check for the final batch of images to complete loading
    checkTimer = [NSTimer timerWithTimeInterval:0.8f target:self selector:@selector(checkFinalLoadStatus) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:checkTimer forMode:NSRunLoopCommonModes];
    
    for (int i = 0; i < pfFileArray.count; i ++) {
        NSArray *holder = [pfFileArray objectAtIndex:i];
        PFFile *canvasFile = [holder objectAtIndex:1];
        //grab the drawing canvas images too
        [canvasFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
            if (!error) {
                UIImage *canvasImage = [UIImage imageWithData:imageData];
                //[canvasArray addObject:canvasImage];
                
                NSString *intString = [NSString stringWithFormat:@"%d", i];
                
                //need to convert the UIImage for storage within dictionary
                //NSData *imageData = UIImageJPEGRepresentation(canvasImage, 1.0);
                NSData *imageData = UIImagePNGRepresentation(canvasImage);
                
                [tempCanvasHolder setValue:imageData forKey:intString];
                
                NSLog(@"Play canvas loaded!!!");
                //[self checkFinalLoadStatus];
            } else {
                NSLog(@"Error retrieving canvas of remote play! Error:  %@", error.description);
            }
        }];
        
    }
}

-(void)checkFinalLoadStatus {
    NSArray *dictionaryCount = [tempCanvasHolder allKeys];
    if (dictionaryCount.count == pfFileArray.count) {
        //all items retrieved, so cancel and invalidate timer
        [checkTimer invalidate];
        checkTimer = nil;
        
        //reorder the images correctly using the 'stringified' keys
        for (NSString *key in dictionaryCount) {
            int currentPlace = [key integerValue];
            NSData *imageData = [tempCanvasHolder valueForKey:key];
            UIImage *canvasImage = [UIImage imageWithData:imageData];
            NSLog(@"DEBUG...INSERT CANVAS>>>BEFORE");
            [canvasArray replaceObjectAtIndex:currentPlace withObject:canvasImage];
            //[canvasArray insertObject:canvasImage atIndex:currentPlace];
            NSLog(@"DEBUG...INSERT CANVAS>>>AFTER");
        }
        
        hasLoaded = true;
        [playSelection reloadData];
    } else {
        NSLog(@"Final counts didn't match...");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (hasLoaded == false) {
        return 0;
    } else {
        //get rid of our loading view now that data has been pulled in
        loadingView.hidden = YES;
        return retrievedPlays.count;
    }
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"playCell"];
    }
    
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(340, 5, 163, 110)];
    imageView.layer.cornerRadius = 8;
    imageView.layer.masksToBounds = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:14 weight:1.0];
    cell.textLabel.frame = CGRectMake(10, 35, 200, 50);
    cell.textLabel.numberOfLines = 2;
    [cell.contentView addSubview:imageView];
    
    if (hasLoaded == true) {
        //grab and assign retrieved play titles
        PFObject *playObject = retrievedPlays[indexPath.row];
        NSString *nameString = [playObject objectForKey:@"playName"];
        cell.textLabel.text = nameString;
        
        //grab and assign retrieved play thumbs
        UIImage *playThumb = imageArray[indexPath.row];
        imageView.image = playThumb;
        
    } else {
        //dummy data for testing
        imageView.image = [UIImage imageNamed:@"3_4_tile.png"];
        cell.textLabel.text = @"Test Label";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; {
    NSMutableArray *playValues = [[NSMutableArray alloc] init];
    PFObject *selectedObject = [retrievedPlays objectAtIndex:indexPath.row];
    NSString *name = [selectedObject objectForKey:@"playName"];
    //add all information for this play to the mutable array and pass back to the play selection controller for loading
    [playValues addObject:name];
    [playValues addObject:canvasArray[indexPath.row]];
    
    //grab coords of each saved player position by iterating
    for (int i = 1; i < 12; i ++) {
        NSString *convertedInt = [NSString stringWithFormat:@"%i", i];
        
        //hand off converted int so we can dynamically retrieve each of the 11 position arrays
        NSString *attributeString = [NSString stringWithFormat:@"player%@Pos", convertedInt];
        
        NSArray *positionArray = [selectedObject objectForKey:attributeString];
        [playValues addObject:positionArray];
    }
    
    [parent loadRemote:playValues];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//set larger custom size for section headers for both table views
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}

////set our header titles for both tableviews
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Plays Available";
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSLog(@"view for header runs!");
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Plays Available - Tap here to cancel";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor colorWithRed:0.004 green:0.494 blue:0.522 alpha:1];
    
    //allow user to tap defense footer to see positions still needed
    titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
    [titleLabel addGestureRecognizer:tapGesture];
    return  titleLabel;
    
}

-(void)headerTapped:(UIGestureRecognizer*)recognizer {
    NSLog(@"header tapped!");
    [parent doneSelecting];
}

-(void)setParent:(PlaySelectionViewController*)parentViewController {
    parent = parentViewController;
}

@end
