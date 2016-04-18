//
//  AppDelegate.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/16/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaunchViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

{
    UINavigationController *navigationController;
}
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *currentPlaybook;
@property (nonatomic, readonly) NSPersistentStore *iCloudStore;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(NSManagedObjectContext*)getContext;
-(void)backupBooks:(NSArray*)books password:(NSString*)password;
-(BOOL)checkPassword:(NSString*)password;
-(void)restoreFromBackup:(NSString*)password controller:(LaunchViewController*)launchController;
-(void)toggleNavbar:(BOOL)boolean;
-(void)toggleiCloud;
-(void)setLaunchView:(LaunchViewController*)launch;
@end

