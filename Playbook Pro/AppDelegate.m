
#import "AppDelegate.h"
#import "LaunchViewController.h"
#import <Parse/Parse.h>
#import "PlayBook.h"
#import "DefensePlay.h"
#import "OffensePlay.h"
#import "Player.h"
#import "SWRevealViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize navigationController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize currentPlaybook;
@synthesize iCloudStore;

LaunchViewController *launchView;
NSPersistentStore *persistentStack;
NSTimer *timer;
int numberToBackup = 0;
NSPersistentStore *cloudStore;
NSPersistentStore *localStore;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //    //set up our navigation controller
    //    LaunchViewController *launchView = [[LaunchViewController alloc] init];
    //
    //    navigationController = [[UINavigationController alloc] initWithRootViewController:launchView];
    //
    //    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //
    //    [self.window addSubview:navigationController.view];
    //
    //    [self.window makeKeyAndVisible];
    
    //timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(alert:) userInfo:nil repeats:YES];
    
    //grab a reference to our initial view controller
    //launchView = (LaunchViewController*) self.window.rootViewController;
    
    //set up Parse stuff
    [Parse enableLocalDatastore];
    
    [Parse setApplicationId:@"DbYuFeeJt9xaR0seUxaA8wfOs9PJ08gaxkinLRv8"
                  clientKey:@"9Katl18q3kqwFAVyzbujzpYLW8ikKdqtegiVOLUQ"];
    
    
//    NSURL *ubiq = [[NSFileManager defaultManager]
//                   URLForUbiquityContainerIdentifier:nil];
//    if (ubiq) {
//        NSLog(@"iCloud access at %@", ubiq);
//        // TODO: Load document...
//    } else {
//        NSLog(@"No iCloud access");
//    }
    
    return YES;
}

- (void)listenForStoreChanges {
    
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    
    [dc addObserver:self selector:@selector(storesWillChange:) name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:_persistentStoreCoordinator];
    
    [dc addObserver:self selector:@selector(storesDidChange:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:_persistentStoreCoordinator];
    
    [dc addObserver:self selector:@selector(persistentStoreDidImportUbiquitiousContentChanges:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:_persistentStoreCoordinator];
}

-(void)storesWillChange:(NSNotification *)n {
    [_managedObjectContext performBlockAndWait:^{
    
        [_managedObjectContext save:nil];
        [_managedObjectContext reset];
    }];

    // Refresh UI
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil userInfo:nil];
    if (launchView ==  nil) {
        launchView = [self getLaunchView];
    }
    
    [_managedObjectContext performBlock:^{
        [launchView reloadTable];
    }];
      NSLog(@"Stores WILL change!");
}

-(void)storesDidChange:(NSNotification *)n {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil userInfo:nil];
    //reload main playbook table view
    if (launchView ==  nil) {
        launchView = [self getLaunchView];
    }

    [_managedObjectContext performBlock:^{
        [launchView reloadTable];
    }];
   
    
    NSLog(@"Stores DID change!");
}

-(void)setLaunchView:(LaunchViewController*)launch {
    launchView = launch;
}

-(LaunchViewController*) getLaunchView {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    launchView = (LaunchViewController*) [mainStoryboard instantiateViewControllerWithIdentifier:@"LaunchController"];
    return launchView;
}

-(void)persistentStoreDidImportUbiquitiousContentChanges:(NSNotification *)n {
    NSLog(@"IMPORTED FROM ICLOUD!");
    if (launchView ==  nil) {
        launchView = [self getLaunchView];
    }
    [_managedObjectContext performBlock:^{
        [_managedObjectContext mergeChangesFromContextDidSaveNotification:n];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
        [launchView reloadTable];
    }];
}

-(void)alert:(NSTimer*)timer {
    UIAlertView *testAlert = [[UIAlertView alloc] initWithTitle:@"Delegate Alert" message:@"Test to see if this alert view is displayed regardless of what part of the application the user is in..." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [testAlert show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//method to migrate the icloud store to a local store in the event the user disables iCloud integration
-(void)migrateiCLoudStoreToLocalStore {
    //[launchView showLoading];
    
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"iCloudEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    NSLog(@"Migrate iCloudToLocalStore ajksdhfljahsdlfjkhasjkdfhasncnlewjclfhsealcfmlkrgh;amlsjhglufhsdaghfsdhm;lfhasdf;ansdf;lahsdknlfausinuvhsdacmwiouh");
   
//    [_managedObjectContext reset];
//    NSError *removeError;
//    for (NSPersistentStore *store in _persistentStoreCoordinator.persistentStores) {
//        BOOL removed = [_persistentStoreCoordinator removePersistentStore:store error:&removeError];
//        
//        if (!removed) {
//            NSLog(@"Unable to remove persistent store:  %@", removeError);
//        }
//    }
    
    
    
    NSURL *storeURL = [_persistentStoreCoordinator.persistentStores.lastObject URL];
    NSURL *localURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Local.sqlite"];
    NSPersistentStore *localStore = [_persistentStoreCoordinator persistentStoreForURL:localURL];
    
    
    
    NSPersistentStore *store = _persistentStoreCoordinator.persistentStores.lastObject;
    //NSPersistentStore *store = [_persistentStoreCoordinator persistentStoreForURL:[NSURL URLWithString: iCloudData]];
    
    
    if (localStore) {
        //return;
//        [_persistentStoreCoordinator lock];
//        [_persistentStoreCoordinator removePersistentStore:localStore error:nil];
//        [_persistentStoreCoordinator unlock];
        
    }
    NSLog(@"Current Store URL (before iCloud to Local migration): %@", [storeURL description]);
    
    NSDictionary *localStoreOptions = nil;
    localStoreOptions = @{ NSPersistentStoreRemoveUbiquitousMetadataOption : @YES,
                           NSMigratePersistentStoresAutomaticallyOption : @YES,
                           NSInferMappingModelAutomaticallyOption : @YES};
    
    if (iCloudStore) {
        NSLog(@"iCloud store exists!");
    
        [_persistentStoreCoordinator lock];
        
         [_persistentStoreCoordinator migratePersistentStore:iCloudStore
                                                                         toURL:localURL
                                                                       options:localStoreOptions
                                                                      withType:NSSQLiteStoreType error:nil];
        
        
        
        
        [_persistentStoreCoordinator unlock];
    }
    //hunt down and destroy duplicates since we could have possible merged
    //[self removeDuplicates];
    
    [self reloadStore:store];
    
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:_persistentStoreCoordinator];
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:_persistentStoreCoordinator];
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:_persistentStoreCoordinator];
    
    [_managedObjectContext save:nil];
    
}

-(void)removeDuplicates {
    //display the 'loading' view during this as it could possibly take awhile
    if (launchView ==  nil) {
        launchView = [self getLaunchView];
    }
    
    //get all playbooks
    NSFetchRequest *bookFetch = [[NSFetchRequest alloc] initWithEntityName:@"PlayBook"];
    NSError *bookError;
    NSArray *allBooks = [_managedObjectContext executeFetchRequest:bookFetch error:&bookError];
    
    if (allBooks != nil && allBooks.count > 0) {
        NSMutableArray *finalBooks = [[NSMutableArray alloc] init];
        //loop through list of books removing duplicates
        for (PlayBook *book in allBooks) {
            NSString *playName = book.name;
            if (![finalBooks containsObject:playName]) {
                [finalBooks addObject:playName];
            }
            [_managedObjectContext deleteObject:book];
        }
        for (NSString *name in finalBooks) {
            //save these out to Core Data
            PlayBook *book = [NSEntityDescription insertNewObjectForEntityForName:@"PlayBook" inManagedObjectContext:_managedObjectContext];
            book.name = name;
            NSError *savedError;
            [_managedObjectContext save:&savedError];
        }
    }
    
    
    //get all offensive plays
    NSFetchRequest *offenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"OffensePlay"];
    NSError *offenseError;
    NSArray *allOffense = [_managedObjectContext executeFetchRequest:offenseFetch error:&offenseError];
    
    if (allOffense != nil && allOffense.count > 0) {
        NSMutableArray *finalOffense = [[NSMutableArray alloc] init];
        //loop through and remove duplicates
        for (OffensePlay *play in allOffense) {
            NSString *playName = play.playName;
            //need to also loop through the final plays to save out to ensure we're only saving each once!
            BOOL alreadyAdded = false;
            for (OffensePlay *savedPlay in finalOffense) {
                NSString *savedName = savedPlay.playName;
                if ([savedName isEqual:playName]) {
                    alreadyAdded = true;
                }
            }
            
            if (alreadyAdded == false) {
                NSLog(@"Already added was false!");
                //current play was not yet saved so copy it's attributes and add
                OffensePlay *newPlay = [NSEntityDescription insertNewObjectForEntityForName:@"OffensePlay" inManagedObjectContext:_managedObjectContext];
                NSDictionary *offenseAttributes = [[NSEntityDescription entityForName:@"OffensePlay" inManagedObjectContext:_managedObjectContext] attributesByName];
                for (NSString *attr in offenseAttributes) {
                    [newPlay setValue:[play valueForKey:attr] forKey:attr];
                }
                [finalOffense addObject:newPlay];
            }
            
            //finally, remove the current play from Core Data
            [_managedObjectContext deleteObject:play];
            
        }
        

        NSError *saveOffenseError;
        [_managedObjectContext save:&saveOffenseError];
    }
    
    
    //get all defensive plays
    NSFetchRequest *defenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"DefensePlay"];
    NSError *defenseError;
    NSArray *allDefense = [_managedObjectContext executeFetchRequest:defenseFetch error:&defenseError];
    
    if (allDefense != nil && allDefense.count > 0) {
        NSMutableArray *finalDefense = [[NSMutableArray alloc] init];
        //loop through and remove duplicates
        for (DefensePlay *play in allDefense) {
            NSString *playName = play.playName;
            //need to also loop through the final plays to save out to ensure we're only saving each once!
            BOOL alreadyAdded = false;
            for (DefensePlay *savedPlay in finalDefense) {
                NSString *savedName = savedPlay.playName;
                if ([savedName isEqual:playName]) {
                    alreadyAdded = true;
                }
            }
            
            if (alreadyAdded == false) {
                NSLog(@"Already added was false!");
                //current play was not yet saved so copy it's attributes and add
                DefensePlay *newPlay = [NSEntityDescription insertNewObjectForEntityForName:@"DefensePlay" inManagedObjectContext:_managedObjectContext];
                NSDictionary *defenseAttributes = [[NSEntityDescription entityForName:@"DefensePlay" inManagedObjectContext:_managedObjectContext] attributesByName];
                for (NSString *attr in defenseAttributes) {
                    [newPlay setValue:[play valueForKey:attr] forKey:attr];
                }
                [finalDefense addObject:newPlay];
            }
            
            //finally, remove the current play from Core Data
            [_managedObjectContext deleteObject:play];
            
            
        }
        

        NSError *saveDefenseError;
        [_managedObjectContext save:&saveDefenseError];
    }
    
    //get all players
    NSFetchRequest *playerFetch = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
    NSError *playerError;
    NSArray *allPlayers = [_managedObjectContext executeFetchRequest:playerFetch error:&playerError];
    if (allPlayers != nil && allPlayers.count > 0) {
        NSMutableArray *finalPlayers = [[NSMutableArray alloc] init];
        //loop through and remove duplicate entries for players
        for (Player *player in allPlayers) {
            NSString *playerName = player.name;
            //loop through and ensure we are only adding the players once each!
            BOOL alreadyAdded = false;
            for (Player *savedPlayer in finalPlayers) {
                NSString *savedPlayerName = savedPlayer.name;
                NSLog(@"Comparing playerName:  %@    Against:  %@", savedPlayerName, playerName);
                if ([savedPlayerName isEqual:playerName]) {
                    alreadyAdded = true;
                    break;
                }
            }
            
            if (alreadyAdded == false) {
                //player was not yet saved so copy it and add
                Player *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:_managedObjectContext];
                NSDictionary *playerAttributes = [[NSEntityDescription entityForName:@"Player" inManagedObjectContext:_managedObjectContext] attributesByName];
                for (NSString *attr in playerAttributes) {
                    [newPlayer setValue:[player valueForKey:attr] forKey:attr];
                }
                [finalPlayers addObject:newPlayer];
            }
            
            //removed old player from Core Data
            [_managedObjectContext deleteObject:player];
        }
        
        NSError *savePlayerError;
        [_managedObjectContext save:&savePlayerError];
    }
    
    
    
    //refresh UI
    if (launchView ==  nil) {
        launchView = [self getLaunchView];
    }
    
    [_managedObjectContext performBlock:^{
        NSLog(@"Done reloading");
        [launchView reloadTable];
    }];
    
}

- (void)reloadStore:(NSPersistentStore *)store {
    //[_managedObjectContext reset];
    //[launchView resetContext];
    
    //NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Backups.sqlite"];
    NSDictionary *localStoreOptions = nil;
    localStoreOptions = @{ NSPersistentStoreRemoveUbiquitousMetadataOption : @YES,
                           NSMigratePersistentStoresAutomaticallyOption : @YES,
                           NSInferMappingModelAutomaticallyOption : @YES};
    
//    if (store) {
//        [_persistentStoreCoordinator lock];
//        [_persistentStoreCoordinator removePersistentStore:store error:nil];
//        [_persistentStoreCoordinator unlock];
//    }
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Local.sqlite"];
//    
//    [_persistentStoreCoordinator lock];
//    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
//                                                  configuration:nil
//                                                            URL:storeURL
//                                                        options:localStoreOptions
//                                                          error:nil];
//    [_persistentStoreCoordinator unlock];
    
    //NSLog(@"Current Store URL (after iCloud to Local migration): %@", [storeURL description]);
    
//    if (launchView ==  nil) {
//        launchView = [self getLaunchView];
//    }
//    
//    [_managedObjectContext performBlock:^{
//        NSLog(@"Done reloading");
//        [launchView reloadTable];
//    }];
    
    
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(void)toggleiCloud {
    BOOL iCloud = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"];
    if (iCloud) {
        //enable iCloud
        NSLog(@"iCloud should be enabled!");
        [self enableiCloud];
    } else {
        //disable iCloud and revert to local store
        NSLog(@"iCloud should be DISabled!");
        [self migrateiCLoudStoreToLocalStore];
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
         _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        
        //_managedObjectContext = [[NSManagedObjectContext alloc] init];
        //[_managedObjectContext setPersistentStoreCoordinator:coordinator];
        
        [_managedObjectContext performBlockAndWait:^{
            [_managedObjectContext setPersistentStoreCoordinator: coordinator];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"]) {
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
            }
        }];
        //_managedObjectContext = moc;
    }
    _managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    return _managedObjectContext;
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    
    NSLog(@"Merging in changes from iCloud...");
    
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    [moc performBlock:^{
        
        [moc mergeChangesFromContextDidSaveNotification:notification];
        
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"SomethingChanged"
                                                                            object:self
                                                                          userInfo:[notification userInfo]];
        
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
        if (launchView ==  nil) {
            launchView = [self getLaunchView];
        }
        [launchView reloadTable];
    }];
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

-(void)enableiCloud {
    
    [_managedObjectContext reset];
//    NSError *removeError;
//    for (NSPersistentStore *store in _persistentStoreCoordinator.persistentStores) {
//        BOOL removed = [_persistentStoreCoordinator removePersistentStore:store error:&removeError];
//        
//        if (!removed) {
//            NSLog(@"Unable to remove persistent store:  %@", removeError);
//        }
//    }
    
    
    NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
    // ** Note: if you adapt this code for your own use, you MUST change this variable:
    NSString *iCloudEnabledAppID = @"96QXY3DVKW.com.matthewlewis.Playbook-Pro";
    
    // ** Note: if you adapt this code for your own use, you should change this variable:
    NSString *dataFileName = @"Backups.sqlite";
    
    //migrate and then remove the local store on the device
    
    
    
    if (localStore) {
        [_persistentStoreCoordinator lock];
        
        //removing this breaks iCloud syncing for some reason!!!
        [_persistentStoreCoordinator removePersistentStore:localStore error:nil];
        
        [_persistentStoreCoordinator unlock];
        
        NSLog(@"Local Store was removed!");
    }
    
    //check if a local store exists, if so add to psc
//    NSURL *localStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Local.sqlite"];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[localStoreURL path]]) {
//        NSMutableDictionary *options = [NSMutableDictionary dictionary];
//        [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
//        [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
//        
//        [psc lock];
//        
//        [psc addPersistentStoreWithType:NSSQLiteStoreType
//                          configuration:nil
//                                    URL:localStoreURL
//                                options:options
//                                  error:nil];
//        [psc unlock];
//        localStore = (NSPersistentStore*) [psc persistentStoreForURL:localStoreURL];
//    }
    
    NSString *iCloudDataDirectoryName = @"Data.nosync";
    NSString *iCloudLogsDirectoryName = @"Logs";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSURL *localStore = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
    NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
    NSURL *iCloudLogsPath = [NSURL fileURLWithPath:[[iCloud path] stringByAppendingPathComponent:iCloudLogsDirectoryName]];
    
    NSLog(@"iCloudEnabledAppID = %@",iCloudEnabledAppID);
    NSLog(@"dataFileName = %@", dataFileName);
    NSLog(@"iCloudDataDirectoryName = %@", iCloudDataDirectoryName);
    NSLog(@"iCloudLogsDirectoryName = %@", iCloudLogsDirectoryName);
    NSLog(@"iCloud = %@", iCloud);
    NSLog(@"iCloudLogsPath = %@", iCloudLogsPath);
    
    if([fileManager fileExistsAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]] == NO) {
        NSError *fileSystemError;
        [fileManager createDirectoryAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&fileSystemError];
        if(fileSystemError != nil) {
            NSLog(@"Error creating database directory %@", fileSystemError);
        }
    }
    
    NSString *iCloudData = [[[iCloud path]
                             stringByAppendingPathComponent:iCloudDataDirectoryName]
                            stringByAppendingPathComponent:dataFileName];
    
    NSLog(@"iCloudData = %@", iCloudData);
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    [options setObject:@"96QXY3DVKW~com~matthewlewis~Playbook-Pro"            forKey:NSPersistentStoreUbiquitousContentNameKey];
    [options setObject:iCloudLogsPath                forKey:NSPersistentStoreUbiquitousContentURLKey];
    
    [psc lock];
    
    [psc addPersistentStoreWithType:NSSQLiteStoreType
                      configuration:nil
                                URL:[NSURL fileURLWithPath:iCloudData]
                            options:options
                              error:nil];
    
    [psc unlock];
    iCloudStore = [psc persistentStoreForURL:[NSURL fileURLWithPath:iCloudData]];
    
    //TESTING!!!!!!!!!!!!  Delete the below if it doesn't work
    if (localStore) {
        //transfer local store to iCloud store
        
    }
    
    
//    if (launchView ==  nil) {
//        launchView = [self getLaunchView];
//    }
    [self listenForStoreChanges];
    //[self removeDuplicates];
    //[launchView reloadTable];
    
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    
    if((_persistentStoreCoordinator != nil)) {
        return _persistentStoreCoordinator;
    }
    BOOL iCloudEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudEnabled"];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *localStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Local.sqlite"];
    
    NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
    if (iCloudEnabled) {
        
        NSLog(@"iCloud enabled!");
        // Set up iCloud in another thread:
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            
            
            if (iCloud) {
                
                [self enableiCloud];
                
            } else {
                NSLog(@"iCloud is NOT working - using a local store");
                NSMutableDictionary *options = [NSMutableDictionary dictionary];
                [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
                [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
                
                [psc lock];
                
                [psc addPersistentStoreWithType:NSSQLiteStoreType
                                  configuration:nil
                                            URL:localStoreURL
                                        options:options
                                          error:nil];
                [psc unlock];
                localStore = (NSPersistentStore*) [psc persistentStoreForURL:localStoreURL];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:self userInfo:nil];
            });
        });
        
    
    }  else {
        NSLog(@"iCloud is NOT working - using a local store");
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
        
        [psc lock];
        
        [psc addPersistentStoreWithType:NSSQLiteStoreType
                          configuration:nil
                                    URL:localStoreURL
                                options:options
                                  error:nil];
        [psc unlock];
        localStore = (NSPersistentStore*) [psc persistentStoreForURL:localStoreURL];
        NSArray *array = [psc persistentStores];
        for (NSPersistentStore *store in array) {
            NSURL *testing = [store URL];
            NSLog(@"Current persistent store url upon adding a local store is:  %@", testing);
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:self userInfo:nil];
    });
    


    
    return _persistentStoreCoordinator;

}

-(NSManagedObjectContext*)getContext {
    return _managedObjectContext;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//this method is called to allow us to backup plays to Parse 'in the background' and will alert the user when complete,
//regardless of what part of the app they may be in at the time
-(void)backupBooks:(NSArray*)books password:(NSString*)password {
    //make an array to hold all of the PFObjects that will be backed up
    NSMutableArray *pfObjects = [[NSMutableArray alloc] init];
    
    //grab arrays of all playbooks, plays, and players since we'll need them either way
    NSFetchRequest *playbookFetch = [[NSFetchRequest alloc] initWithEntityName:@"PlayBook"];
    NSError *playbookError = nil;
    NSArray *allPlaybooks = [[self getContext] executeFetchRequest:playbookFetch error:&playbookError];
    if (allPlaybooks == nil) {
        NSLog(@"Error fetching all playbooks during backup!  Error was:  %@", playbookError.description);
    }
    
    NSFetchRequest *playerFetch = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
    NSError *playerError = nil;
    NSArray *allPlayers = [[self getContext] executeFetchRequest:playerFetch error:&playerError];
    if (allPlayers == nil) {
        NSLog(@"Error fetching all players during backup!  Error was:  %@", playerError.description);
    }
    
    NSFetchRequest *offenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"OffensePlay"];
    NSError *offenseError = nil;
    NSArray *allOffensePlays = [[self getContext] executeFetchRequest:offenseFetch error:&offenseError];
    if (allOffensePlays == nil) {
        NSLog(@"Error fetching offensive plays during backup!  Error was:  %@", offenseError.description);
    }
    
    NSFetchRequest *defenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"DefensePlay"];
    NSError *defenseError = nil;
    NSArray *allDefensePlays = [[self getContext] executeFetchRequest:defenseFetch error:&defenseError];
    if (allDefensePlays == nil) {
        NSLog(@"Error fetching defensive plays during backup!  Error was:  %@", defenseError.description);
    }
    
    
    
    
    
    if (books != nil && books.count > 0) {
        for (NSString *currentName in books) {
            NSLog(@"Passed book name to backup is:  %@", currentName);
            
            //find the playbook by the current name
            for (int i = 0; i < books.count; i ++) {
                NSString *bookName = books[i];
                PFObject *bookBackup = [PFObject objectWithClassName:password];
                [bookBackup setObject:@"playbook" forKey:@"type"];
                [bookBackup setObject:bookName forKey:@"name"];
                [pfObjects addObject:bookBackup];
            }
            
            
            
            //find all plays associated with the current name
            for (int i = 0; i < books.count; i ++) {
                NSString *bookName = books[i];
                NSMutableArray *matchedOffense = [[NSMutableArray alloc] init];
                NSMutableArray *matchedDefense = [[NSMutableArray alloc] init];
                for (OffensePlay *offensePlay in allOffensePlays) {
                    if ([offensePlay.owner isEqual:bookName]) {
                        [matchedOffense addObject:offensePlay];
                    }
                }
                
                for (DefensePlay *defensePlay in allDefensePlays) {
                    if ([defensePlay.owner isEqual:bookName]) {
                        [matchedDefense addObject:defensePlay];
                    }
                }
                
                
                
                //loop through both arrays of plays and covert to PFObjects
                for (OffensePlay *offensePlay in matchedOffense) {
                    PFObject *offenseObject = [PFObject objectWithClassName:password];
                    [offenseObject setObject:offensePlay.playName forKey:@"playName"];
                    PFFile *canvasFile = [PFFile fileWithData:offensePlay.drawCanvas];
                    [offenseObject setObject:canvasFile forKey:@"drawCanvas"];
                    
                    PFFile *snapshotFile = [PFFile fileWithData:offensePlay.snapshot];
                    [offenseObject setObject:snapshotFile forKey:@"snapshot"];
                    
                    [offenseObject setObject:offensePlay.player0Name forKey:@"player0Name"];
                    [offenseObject setObject:offensePlay.player0X forKey:@"player0X"];
                    [offenseObject setObject:offensePlay.player0Y forKey:@"player0Y"];
                    
                    [offenseObject setObject:offensePlay.player1Name forKey:@"player1Name"];
                    [offenseObject setObject:offensePlay.player1X forKey:@"player1X"];
                    [offenseObject setObject:offensePlay.player1Y forKey:@"player1Y"];
                    
                    [offenseObject setObject:offensePlay.player2Name forKey:@"player2Name"];
                    [offenseObject setObject:offensePlay.player2X forKey:@"player2X"];
                    [offenseObject setObject:offensePlay.player2Y forKey:@"player2Y"];
                    
                    [offenseObject setObject:offensePlay.player3Name forKey:@"player3Name"];
                    [offenseObject setObject:offensePlay.player3X forKey:@"player3X"];
                    [offenseObject setObject:offensePlay.player3Y forKey:@"player3Y"];
                    
                    [offenseObject setObject:offensePlay.player4Name forKey:@"player4Name"];
                    [offenseObject setObject:offensePlay.player4X forKey:@"player4X"];
                    [offenseObject setObject:offensePlay.player4Y forKey:@"player4Y"];
                    
                    [offenseObject setObject:offensePlay.player5Name forKey:@"player5Name"];
                    [offenseObject setObject:offensePlay.player5X forKey:@"player5X"];
                    [offenseObject setObject:offensePlay.player5Y forKey:@"player5Y"];
                    
                    [offenseObject setObject:offensePlay.player6Name forKey:@"player6Name"];
                    [offenseObject setObject:offensePlay.player6X forKey:@"player6X"];
                    [offenseObject setObject:offensePlay.player6Y forKey:@"player6Y"];
                    
                    [offenseObject setObject:offensePlay.player7Name forKey:@"player7Name"];
                    [offenseObject setObject:offensePlay.player7X forKey:@"player7X"];
                    [offenseObject setObject:offensePlay.player7Y forKey:@"player7Y"];
                    
                    [offenseObject setObject:offensePlay.player8Name forKey:@"player8Name"];
                    [offenseObject setObject:offensePlay.player8X forKey:@"player8X"];
                    [offenseObject setObject:offensePlay.player8Y forKey:@"player8Y"];
                    
                    [offenseObject setObject:offensePlay.player9Name forKey:@"player9Name"];
                    [offenseObject setObject:offensePlay.player9X forKey:@"player9X"];
                    [offenseObject setObject:offensePlay.player9Y forKey:@"player9Y"];
                    
                    [offenseObject setObject:offensePlay.player10Name forKey:@"player10Name"];
                    [offenseObject setObject:offensePlay.player10X forKey:@"player10X"];
                    [offenseObject setObject:offensePlay.player10Y forKey:@"player10Y"];
                    NSString *theme = offensePlay.theme;
                    [offenseObject setObject:offensePlay.theme forKey:@"theme"];
                    NSLog(@"%@", theme);
                    [offenseObject setObject:offensePlay.x0x forKey:@"x0x"];
                    [offenseObject setObject:offensePlay.x0y forKey:@"x0y"];
                    
                    [offenseObject setObject:offensePlay.x1x forKey:@"x1x"];
                    [offenseObject setObject:offensePlay.x1y forKey:@"x1y"];
                    
                    [offenseObject setObject:offensePlay.x2x forKey:@"x2x"];
                    [offenseObject setObject:offensePlay.x2y forKey:@"x2y"];
                    
                    [offenseObject setObject:offensePlay.x3x forKey:@"x3x"];
                    [offenseObject setObject:offensePlay.x3y forKey:@"x3y"];
                    
                    [offenseObject setObject:offensePlay.x4x forKey:@"x4x"];
                    [offenseObject setObject:offensePlay.x4y forKey:@"x4y"];
                    
                    [offenseObject setObject:offensePlay.x5x forKey:@"x5x"];
                    [offenseObject setObject:offensePlay.x5y forKey:@"x5y"];
                    
                    [offenseObject setObject:offensePlay.x6x forKey:@"x6x"];
                    [offenseObject setObject:offensePlay.x6y forKey:@"x6y"];
                    
                    [offenseObject setObject:offensePlay.x7x forKey:@"x7x"];
                    [offenseObject setObject:offensePlay.x7y forKey:@"x7y"];
                    
                    [offenseObject setObject:offensePlay.x8x forKey:@"x8x"];
                    [offenseObject setObject:offensePlay.x8y forKey:@"x8y"];
                    
                    [offenseObject setObject:offensePlay.x9x forKey:@"x9x"];
                    [offenseObject setObject:offensePlay.x9y forKey:@"x9y"];
                    
                    [offenseObject setObject:offensePlay.x10x forKey:@"x10x"];
                    [offenseObject setObject:offensePlay.x10y forKey:@"x10y"];
                    
                    [offenseObject setObject:offensePlay.owner forKey:@"owner"];
                    [offenseObject setObject:@"offensePlay" forKey:@"type"];
                    [pfObjects addObject:offenseObject];
                    
                    
                }
                
                for (DefensePlay *defensePlay in matchedDefense) {
                    PFObject *defenseObject = [PFObject objectWithClassName:password];
                    [defenseObject setObject:defensePlay.playName forKey:@"playName"];
                    PFFile *canvasFile = [PFFile fileWithData:defensePlay.drawCanvas];
                    [defenseObject setObject:canvasFile forKey:@"drawCanvas"];
                    
                    PFFile *snapshotFile = [PFFile fileWithData:defensePlay.snapshot];
                    [defenseObject setObject:snapshotFile forKey:@"snapshot"];
                    
                    [defenseObject setObject:defensePlay.player0Name forKey:@"player0Name"];
                    [defenseObject setObject:defensePlay.player0X forKey:@"player0X"];
                    [defenseObject setObject:defensePlay.player0Y forKey:@"player0Y"];
                    
                    [defenseObject setObject:defensePlay.player1Name forKey:@"player1Name"];
                    [defenseObject setObject:defensePlay.player1X forKey:@"player1X"];
                    [defenseObject setObject:defensePlay.player1Y forKey:@"player1Y"];
                    
                    [defenseObject setObject:defensePlay.player2Name forKey:@"player2Name"];
                    [defenseObject setObject:defensePlay.player2X forKey:@"player2X"];
                    [defenseObject setObject:defensePlay.player2Y forKey:@"player2Y"];
                    
                    [defenseObject setObject:defensePlay.player3Name forKey:@"player3Name"];
                    [defenseObject setObject:defensePlay.player3X forKey:@"player3X"];
                    [defenseObject setObject:defensePlay.player3Y forKey:@"player3Y"];
                    
                    [defenseObject setObject:defensePlay.player4Name forKey:@"player4Name"];
                    [defenseObject setObject:defensePlay.player4X forKey:@"player4X"];
                    [defenseObject setObject:defensePlay.player4Y forKey:@"player4Y"];
                    
                    [defenseObject setObject:defensePlay.player5Name forKey:@"player5Name"];
                    [defenseObject setObject:defensePlay.player5X forKey:@"player5X"];
                    [defenseObject setObject:defensePlay.player5Y forKey:@"player5Y"];
                    
                    [defenseObject setObject:defensePlay.player6Name forKey:@"player6Name"];
                    [defenseObject setObject:defensePlay.player6X forKey:@"player6X"];
                    [defenseObject setObject:defensePlay.player6Y forKey:@"player6Y"];
                    
                    [defenseObject setObject:defensePlay.player7Name forKey:@"player7Name"];
                    [defenseObject setObject:defensePlay.player7X forKey:@"player7X"];
                    [defenseObject setObject:defensePlay.player7Y forKey:@"player7Y"];
                    
                    [defenseObject setObject:defensePlay.player8Name forKey:@"player8Name"];
                    [defenseObject setObject:defensePlay.player8X forKey:@"player8X"];
                    [defenseObject setObject:defensePlay.player8Y forKey:@"player8Y"];
                    
                    [defenseObject setObject:defensePlay.player9Name forKey:@"player9Name"];
                    [defenseObject setObject:defensePlay.player9X forKey:@"player9X"];
                    [defenseObject setObject:defensePlay.player9Y forKey:@"player9Y"];
                    
                    [defenseObject setObject:defensePlay.player10Name forKey:@"player10Name"];
                    [defenseObject setObject:defensePlay.player10X forKey:@"player10X"];
                    [defenseObject setObject:defensePlay.player10Y forKey:@"player10Y"];
                    
                    [defenseObject setObject:defensePlay.theme forKey:@"theme"];
                    
                    [defenseObject setObject:defensePlay.x0x forKey:@"x0x"];
                    [defenseObject setObject:defensePlay.x0y forKey:@"x0y"];
                    
                    [defenseObject setObject:defensePlay.x1x forKey:@"x1x"];
                    [defenseObject setObject:defensePlay.x1y forKey:@"x1y"];
                    
                    [defenseObject setObject:defensePlay.x2x forKey:@"x2x"];
                    [defenseObject setObject:defensePlay.x2y forKey:@"x2y"];
                    
                    [defenseObject setObject:defensePlay.x3x forKey:@"x3x"];
                    [defenseObject setObject:defensePlay.x3y forKey:@"x3y"];
                    
                    [defenseObject setObject:defensePlay.x4x forKey:@"x4x"];
                    [defenseObject setObject:defensePlay.x4y forKey:@"x4y"];
                    
                    [defenseObject setObject:defensePlay.x5x forKey:@"x5x"];
                    [defenseObject setObject:defensePlay.x5y forKey:@"x5y"];
                    
                    [defenseObject setObject:defensePlay.x6x forKey:@"x6x"];
                    [defenseObject setObject:defensePlay.x6y forKey:@"x6y"];
                    
                    [defenseObject setObject:defensePlay.x7x forKey:@"x7x"];
                    [defenseObject setObject:defensePlay.x7y forKey:@"x7y"];
                    
                    [defenseObject setObject:defensePlay.x8x forKey:@"x8x"];
                    [defenseObject setObject:defensePlay.x8y forKey:@"x8y"];
                    
                    [defenseObject setObject:defensePlay.x9x forKey:@"x9x"];
                    [defenseObject setObject:defensePlay.x9y forKey:@"x9y"];
                    
                    [defenseObject setObject:defensePlay.x10x forKey:@"x10x"];
                    [defenseObject setObject:defensePlay.x10y forKey:@"x10y"];
                    
                    [defenseObject setObject:defensePlay.owner forKey:@"owner"];
                    [defenseObject setObject:@"defensePlay" forKey:@"type"];
                    [pfObjects addObject:defenseObject];
                    
                    
                }
                
            }
            
            
            
        }
        
        //save out all players
        for (Player *player in allPlayers) {
            PFObject *playerObject = [PFObject objectWithClassName:password];
            [playerObject setObject:player.name forKey:@"name"];
            [playerObject setObject:player.position forKey:@"position"];
            PFFile *snapShotFile = [PFFile fileWithData:player.image];
            [playerObject setObject:snapShotFile forKey:@"image"];
            [playerObject setObject:player.team forKey:@"team"];
            [playerObject setObject:@"player" forKey:@"type"];
            [pfObjects addObject:playerObject];
        }
        
        //  [self saveToParse:pfObjects];
        
    } else {
        
        //save out all playbooks
        for (PlayBook *book in allPlaybooks) {
            PFObject *bookBackup = [PFObject objectWithClassName:password];
            [bookBackup setObject:book.name forKey:@"name"];
            [bookBackup setObject:@"playbook" forKey:@"type"];
            [pfObjects addObject:bookBackup];
        }
        
        //save out all plays
        for (OffensePlay *offensePlay in allOffensePlays) {
            PFObject *offenseObject = [PFObject objectWithClassName:password];
            [offenseObject setObject:offensePlay.playName forKey:@"playName"];
            PFFile *canvasFile = [PFFile fileWithData:offensePlay.drawCanvas];
            [offenseObject setObject:canvasFile forKey:@"drawCanvas"];
            
            PFFile *snapshotFile = [PFFile fileWithData:offensePlay.snapshot];
            [offenseObject setObject:snapshotFile forKey:@"snapshot"];
            
            [offenseObject setObject:offensePlay.player0Name forKey:@"player0Name"];
            [offenseObject setObject:offensePlay.player0X forKey:@"player0X"];
            [offenseObject setObject:offensePlay.player0Y forKey:@"player0Y"];
            
            [offenseObject setObject:offensePlay.player1Name forKey:@"player1Name"];
            [offenseObject setObject:offensePlay.player1X forKey:@"player1X"];
            [offenseObject setObject:offensePlay.player1Y forKey:@"player1Y"];
            
            [offenseObject setObject:offensePlay.player2Name forKey:@"player2Name"];
            [offenseObject setObject:offensePlay.player2X forKey:@"player2X"];
            [offenseObject setObject:offensePlay.player2Y forKey:@"player2Y"];
            
            [offenseObject setObject:offensePlay.player3Name forKey:@"player3Name"];
            [offenseObject setObject:offensePlay.player3X forKey:@"player3X"];
            [offenseObject setObject:offensePlay.player3Y forKey:@"player3Y"];
            
            [offenseObject setObject:offensePlay.player4Name forKey:@"player4Name"];
            [offenseObject setObject:offensePlay.player4X forKey:@"player4X"];
            [offenseObject setObject:offensePlay.player4Y forKey:@"player4Y"];
            
            [offenseObject setObject:offensePlay.player5Name forKey:@"player5Name"];
            [offenseObject setObject:offensePlay.player5X forKey:@"player5X"];
            [offenseObject setObject:offensePlay.player5Y forKey:@"player5Y"];
            
            [offenseObject setObject:offensePlay.player6Name forKey:@"player6Name"];
            [offenseObject setObject:offensePlay.player6X forKey:@"player6X"];
            [offenseObject setObject:offensePlay.player6Y forKey:@"player6Y"];
            
            [offenseObject setObject:offensePlay.player7Name forKey:@"player7Name"];
            [offenseObject setObject:offensePlay.player7X forKey:@"player7X"];
            [offenseObject setObject:offensePlay.player7Y forKey:@"player7Y"];
            
            [offenseObject setObject:offensePlay.player8Name forKey:@"player8Name"];
            [offenseObject setObject:offensePlay.player8X forKey:@"player8X"];
            [offenseObject setObject:offensePlay.player8Y forKey:@"player8Y"];
            
            [offenseObject setObject:offensePlay.player9Name forKey:@"player9Name"];
            [offenseObject setObject:offensePlay.player9X forKey:@"player9X"];
            [offenseObject setObject:offensePlay.player9Y forKey:@"player9Y"];
            
            [offenseObject setObject:offensePlay.player10Name forKey:@"player10Name"];
            [offenseObject setObject:offensePlay.player10X forKey:@"player10X"];
            [offenseObject setObject:offensePlay.player10Y forKey:@"player10Y"];
            NSString *theme = offensePlay.theme;
            [offenseObject setObject:offensePlay.theme forKey:@"theme"];
            NSLog(@"%@", theme);
            [offenseObject setObject:offensePlay.x0x forKey:@"x0x"];
            [offenseObject setObject:offensePlay.x0y forKey:@"x0y"];
            
            [offenseObject setObject:offensePlay.x1x forKey:@"x1x"];
            [offenseObject setObject:offensePlay.x1y forKey:@"x1y"];
            
            [offenseObject setObject:offensePlay.x2x forKey:@"x2x"];
            [offenseObject setObject:offensePlay.x2y forKey:@"x2y"];
            
            [offenseObject setObject:offensePlay.x3x forKey:@"x3x"];
            [offenseObject setObject:offensePlay.x3y forKey:@"x3y"];
            
            [offenseObject setObject:offensePlay.x4x forKey:@"x4x"];
            [offenseObject setObject:offensePlay.x4y forKey:@"x4y"];
            
            [offenseObject setObject:offensePlay.x5x forKey:@"x5x"];
            [offenseObject setObject:offensePlay.x5y forKey:@"x5y"];
            
            [offenseObject setObject:offensePlay.x6x forKey:@"x6x"];
            [offenseObject setObject:offensePlay.x6y forKey:@"x6y"];
            
            [offenseObject setObject:offensePlay.x7x forKey:@"x7x"];
            [offenseObject setObject:offensePlay.x7y forKey:@"x7y"];
            
            [offenseObject setObject:offensePlay.x8x forKey:@"x8x"];
            [offenseObject setObject:offensePlay.x8y forKey:@"x8y"];
            
            [offenseObject setObject:offensePlay.x9x forKey:@"x9x"];
            [offenseObject setObject:offensePlay.x9y forKey:@"x9y"];
            
            [offenseObject setObject:offensePlay.x10x forKey:@"x10x"];
            [offenseObject setObject:offensePlay.x10y forKey:@"x10y"];
            
            [offenseObject setObject:offensePlay.owner forKey:@"owner"];
            [offenseObject setObject:@"offensePlay" forKey:@"type"];
            [pfObjects addObject:offenseObject];
        }
        
        for (DefensePlay *defensePlay in allDefensePlays) {
            PFObject *defenseObject = [PFObject objectWithClassName:password];
            [defenseObject setObject:defensePlay.playName forKey:@"playName"];
            PFFile *canvasFile = [PFFile fileWithData:defensePlay.drawCanvas];
            [defenseObject setObject:canvasFile forKey:@"drawCanvas"];
            
            PFFile *snapshotFile = [PFFile fileWithData:defensePlay.snapshot];
            [defenseObject setObject:snapshotFile forKey:@"snapshot"];
            
            [defenseObject setObject:defensePlay.player0Name forKey:@"player0Name"];
            [defenseObject setObject:defensePlay.player0X forKey:@"player0X"];
            [defenseObject setObject:defensePlay.player0Y forKey:@"player0Y"];
            
            [defenseObject setObject:defensePlay.player1Name forKey:@"player1Name"];
            [defenseObject setObject:defensePlay.player1X forKey:@"player1X"];
            [defenseObject setObject:defensePlay.player1Y forKey:@"player1Y"];
            
            [defenseObject setObject:defensePlay.player2Name forKey:@"player2Name"];
            [defenseObject setObject:defensePlay.player2X forKey:@"player2X"];
            [defenseObject setObject:defensePlay.player2Y forKey:@"player2Y"];
            
            [defenseObject setObject:defensePlay.player3Name forKey:@"player3Name"];
            [defenseObject setObject:defensePlay.player3X forKey:@"player3X"];
            [defenseObject setObject:defensePlay.player3Y forKey:@"player3Y"];
            
            [defenseObject setObject:defensePlay.player4Name forKey:@"player4Name"];
            [defenseObject setObject:defensePlay.player4X forKey:@"player4X"];
            [defenseObject setObject:defensePlay.player4Y forKey:@"player4Y"];
            
            [defenseObject setObject:defensePlay.player5Name forKey:@"player5Name"];
            [defenseObject setObject:defensePlay.player5X forKey:@"player5X"];
            [defenseObject setObject:defensePlay.player5Y forKey:@"player5Y"];
            
            [defenseObject setObject:defensePlay.player6Name forKey:@"player6Name"];
            [defenseObject setObject:defensePlay.player6X forKey:@"player6X"];
            [defenseObject setObject:defensePlay.player6Y forKey:@"player6Y"];
            
            [defenseObject setObject:defensePlay.player7Name forKey:@"player7Name"];
            [defenseObject setObject:defensePlay.player7X forKey:@"player7X"];
            [defenseObject setObject:defensePlay.player7Y forKey:@"player7Y"];
            
            [defenseObject setObject:defensePlay.player8Name forKey:@"player8Name"];
            [defenseObject setObject:defensePlay.player8X forKey:@"player8X"];
            [defenseObject setObject:defensePlay.player8Y forKey:@"player8Y"];
            
            [defenseObject setObject:defensePlay.player9Name forKey:@"player9Name"];
            [defenseObject setObject:defensePlay.player9X forKey:@"player9X"];
            [defenseObject setObject:defensePlay.player9Y forKey:@"player9Y"];
            
            [defenseObject setObject:defensePlay.player10Name forKey:@"player10Name"];
            [defenseObject setObject:defensePlay.player10X forKey:@"player10X"];
            [defenseObject setObject:defensePlay.player10Y forKey:@"player10Y"];
            
            [defenseObject setObject:defensePlay.theme forKey:@"theme"];
            
            [defenseObject setObject:defensePlay.x0x forKey:@"x0x"];
            [defenseObject setObject:defensePlay.x0y forKey:@"x0y"];
            
            [defenseObject setObject:defensePlay.x1x forKey:@"x1x"];
            [defenseObject setObject:defensePlay.x1y forKey:@"x1y"];
            
            [defenseObject setObject:defensePlay.x2x forKey:@"x2x"];
            [defenseObject setObject:defensePlay.x2y forKey:@"x2y"];
            
            [defenseObject setObject:defensePlay.x3x forKey:@"x3x"];
            [defenseObject setObject:defensePlay.x3y forKey:@"x3y"];
            
            [defenseObject setObject:defensePlay.x4x forKey:@"x4x"];
            [defenseObject setObject:defensePlay.x4y forKey:@"x4y"];
            
            [defenseObject setObject:defensePlay.x5x forKey:@"x5x"];
            [defenseObject setObject:defensePlay.x5y forKey:@"x5y"];
            
            [defenseObject setObject:defensePlay.x6x forKey:@"x6x"];
            [defenseObject setObject:defensePlay.x6y forKey:@"x6y"];
            
            [defenseObject setObject:defensePlay.x7x forKey:@"x7x"];
            [defenseObject setObject:defensePlay.x7y forKey:@"x7y"];
            
            [defenseObject setObject:defensePlay.x8x forKey:@"x8x"];
            [defenseObject setObject:defensePlay.x8y forKey:@"x8y"];
            
            [defenseObject setObject:defensePlay.x9x forKey:@"x9x"];
            [defenseObject setObject:defensePlay.x9y forKey:@"x9y"];
            
            [defenseObject setObject:defensePlay.x10x forKey:@"x10x"];
            [defenseObject setObject:defensePlay.x10y forKey:@"x10y"];
            
            [defenseObject setObject:defensePlay.owner forKey:@"owner"];
            [defenseObject setObject:@"defensePlay" forKey:@"type"];
            [pfObjects addObject:defenseObject];
        }
        
        
        
        //save out all players
        for (Player *player in allPlayers) {
            PFObject *playerObject = [PFObject objectWithClassName:password];
            [playerObject setObject:player.name forKey:@"name"];
            [playerObject setObject:player.position forKey:@"position"];
            PFFile *snapShotFile = [PFFile fileWithData:player.image];
            [playerObject setObject:snapShotFile forKey:@"image"];
            [playerObject setObject:player.team forKey:@"team"];
            [playerObject setObject:@"player" forKey:@"type"];
            [pfObjects addObject:playerObject];
        }
        
    }
    
    //set our global int variable to the number of objects that need to be saved to parse
    //numberToBackup = pfObjects.count;
    [self saveToParse:pfObjects];
    
    
}

-(void)saveToParse:(NSMutableArray*)pfObjects {
    
    for (PFObject *object in pfObjects) {
        [object saveInBackgroundWithBlock:^(BOOL succeded, NSError *error){
            if (succeded) {
                int count = (int)[pfObjects count];
                [self checkTotal:count];
            } else {
                NSLog(@"Error saving to Parse!  Error was:  %@", error.description);
            }
        }];
    }
    
}

-(void)checkTotal:(int)total {
    
    numberToBackup ++;
    NSLog(@"Checking total!  Total is:  %i and currently on:  %i", total, numberToBackup);
    if (numberToBackup == total) {
        //backup complete, alert the user
        UIAlertView *completeAlert = [[UIAlertView alloc] initWithTitle:@"Backup Complete" message:@"Your selected Playbooks were successfully saved to the cloud.  They may now be restored from." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [completeAlert show];
        numberToBackup = 0;
    }
}

//this method simply checks if a backup exists on Parse using the supplied password
-(BOOL)checkPassword:(NSString*)password {
    PFQuery *passwordQuery = [PFQuery queryWithClassName:password];
    
    PFObject *object = [passwordQuery getFirstObject];
    
    if (object != nil) {
        return true;
    } else {
        return false;
    }
    
    
    //return false;
}

//restore backup from parse and call method in the launch view controller when completed
-(void)restoreFromBackup:(NSString*)password controller:(LaunchViewController*)launchController {
    
    PFQuery *restoreQuery = [PFQuery queryWithClassName:password];
    
    [restoreQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self restoreFromArray:objects withController:launchController];
        } else {
            NSLog(@"Error retrieving contents of backup!  Error was:  %@", error.description);
        }
    }];
    
}

-(void)restoreFromArray:(NSArray*)objects withController:(LaunchViewController*)launchController {
    NSLog(@"restore from array called!");
    NSMutableArray *playbooks = [[NSMutableArray alloc] init];
    NSMutableArray *offensePlays = [[NSMutableArray alloc] init];
    NSMutableArray *defensePlays = [[NSMutableArray alloc] init];
    NSMutableArray *players = [[NSMutableArray alloc] init];
    
    //loop through retrieved parse objects and sort to the appropriate arrays
    for (PFObject *object in objects) {
        NSString *type = [object objectForKey:@"type"];
        
        if ([type isEqual:@"player"]) {
            [players addObject:object];
        } else if ([type isEqual:@"playbook"]) {
            [playbooks addObject:object];
        } else if ([type isEqual:@"offensePlay"]) {
            [offensePlays addObject:object];
        } else if ([type isEqual:@"defensePlay"]) {
            [defensePlays addObject:object];
        }
    }
    
    //check if the playbook already exists, if not, save it
    NSFetchRequest *bookFetch = [[NSFetchRequest alloc] initWithEntityName:@"PlayBook"];
    NSError *bookError = nil;
    NSArray *bookArray = [self.managedObjectContext executeFetchRequest:bookFetch error:&bookError];
    if (bookArray == nil) {
        NSLog(@"Error retrieving list of playbooks during restore!  Error was:  %@", bookError.description);
    } else {
        NSLog(@"Book array is not nil...");
    }
    
    
    NSFetchRequest *playerFetch = [[NSFetchRequest alloc] initWithEntityName:@"Player"];
    NSError *playerError = nil;
    NSArray *playerArray = [[self getContext] executeFetchRequest:playerFetch error:&playerError];
    if (playerArray == nil) {
        NSLog(@"Error retrieving list of players during restore!  Error was:  %@", playerError.description);
    }
    
    NSFetchRequest *offenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"OffensePlay"];
    NSError *offenseError = nil;
    NSArray *offenseArray = [[self getContext] executeFetchRequest:offenseFetch error:&offenseError];
    if (offenseArray == nil) {
        NSLog(@"Error retrieving list of offense plays during restore!  Error was:  %@", offenseError.description);
    }
    
    NSFetchRequest *defenseFetch = [[NSFetchRequest alloc] initWithEntityName:@"DefensePlay"];
    NSError *defenseError = nil;
    NSArray *defenseArray = [[self getContext] executeFetchRequest:defenseFetch error:&defenseError];
    if (defenseArray == nil) {
        NSLog(@"Error retrieving list of defense plays during restore!  Error was:  %@", defenseError.description);
    }
    
    
    //now that returned objects are sorted, load them in and check if they already exist
    for (PFObject *playbookObject in playbooks) {
        NSString *bookName = [playbookObject objectForKey:@"name"];
        
        if (bookArray == nil || bookArray.count < 1) {
            //no previous playbooks found, so simply save out the new ones
            PlayBook *playbook = (PlayBook*) [NSEntityDescription insertNewObjectForEntityForName:@"PlayBook" inManagedObjectContext:[self managedObjectContext]];
            playbook.name = bookName;
            NSError *error = nil;
            [[self getContext] save:&error];
            
        } else {
            //loop through existing playbooks, if none match the retrieved ones from parse, save out a new instance
            BOOL alreadyExists = false;
            for (PlayBook *existingBook in bookArray) {
                
                if ([existingBook.name isEqual:bookName]) {
                    alreadyExists = true;
                    break;
                }
                
            }
            if (alreadyExists == false) {
                PlayBook *playbook = (PlayBook*) [NSEntityDescription insertNewObjectForEntityForName:@"PlayBook" inManagedObjectContext:[self managedObjectContext]];
                
                //playbook.name = bookName;
                [playbook setValue:bookName forKey:@"name"];
                NSError *error = nil;
                if (![[self getContext] save:&error]) {
                    NSLog(@"Error saving a new playbook from remote!");
                };
            }
        }
    }
    
    //loop through retrieved players and add/modify where needed
    for (PFObject *playerObject in players) {
        NSString *playerName = [playerObject objectForKey:@"name"];
        
        if (playerArray == nil || playerArray.count < 1) {
            Player *player = (Player*) [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:[self managedObjectContext]];
            player.name = playerName;
            player.position = [playerObject objectForKey:@"position"];
            player.team = [playerObject objectForKey:@"team"];
            PFFile *playerImageFile = [playerObject objectForKey:@"image"];
            NSData *imageData = [playerImageFile getData];
            //UIImage *playerImage = [UIImage imageWithData:imageData];
            player.image = imageData;
            NSError *error = nil;
            [[self getContext] save:&error];
        } else {
            //loop through all existing players and if a match is found, set its attributes to what was retrieved
            Player *matchedPlayer;
            for (Player *player in playerArray) {
                if ([player.name isEqual:playerName]) {
                    matchedPlayer = player;
                    break;
                }
            }
            
            if (matchedPlayer != nil) {
                //matched the retrieved player to a locally saved one, so overwrite the local's attributes
                matchedPlayer.position = [playerObject objectForKey:@"position"];
                matchedPlayer.team = [playerObject objectForKey:@"team"];
                PFFile *playerImageFile = [playerObject objectForKey:@"image"];
                NSData *imageData = [playerImageFile getData];
                //UIImage *playerImage = [UIImage imageWithData:imageData];
                matchedPlayer.image = imageData;
                NSError *error = nil;
                [[self getContext] save:&error];
            } else {
                Player *player = (Player*) [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:[self managedObjectContext]];
                player.name = playerName;
                player.position = [playerObject objectForKey:@"position"];
                player.team = [playerObject objectForKey:@"team"];
                PFFile *playerImageFile = [playerObject objectForKey:@"image"];
                NSData *imageData = [playerImageFile getData];
                //UIImage *playerImage = [UIImage imageWithData:imageData];
                player.image = imageData;
                NSError *error = nil;
                [[self getContext] save:&error];
            }
            
        }
        
    }
    
    //loop through retrieved offensive plays and create new or modify previous versions as appropriate
    for (PFObject *offenseObject in offensePlays) {
        NSString *playTitle = [offenseObject objectForKey:@"playName"];
        NSString *owner = [offenseObject objectForKey:@"owner"];
        
        if (offenseArray == nil || offenseArray.count < 1) {
            //no already saved offensive plays, so simply save out the retrieved one
            OffensePlay *offensePlay = (OffensePlay*) [NSEntityDescription insertNewObjectForEntityForName:@"OffensePlay" inManagedObjectContext:[self managedObjectContext]];
            offensePlay.playName = playTitle;
            PFFile *playThumbFile = [offenseObject objectForKey:@"snapshot"];
            NSData *imageData = [playThumbFile getData];
            offensePlay.snapshot = imageData;
            PFFile *canvasFile = [offenseObject objectForKey:@"drawCanvas"];
            NSData *canvasData = [canvasFile getData];
            offensePlay.drawCanvas = canvasData;
            offensePlay.owner = [offenseObject objectForKey:@"owner"];
            offensePlay.player0Name = [offenseObject objectForKey:@"player0Name"];
            offensePlay.player0X = [offenseObject objectForKey:@"player0X"];
            offensePlay.player0Y = [offenseObject objectForKey:@"player0Y"];
            
            offensePlay.player1Name = [offenseObject objectForKey:@"player1Name"];
            offensePlay.player1X = [offenseObject objectForKey:@"player1X"];
            offensePlay.player1Y = [offenseObject objectForKey:@"player1Y"];
            
            offensePlay.player2Name = [offenseObject objectForKey:@"player2Name"];
            offensePlay.player2X = [offenseObject objectForKey:@"player2X"];
            offensePlay.player2Y = [offenseObject objectForKey:@"player2Y"];
            
            offensePlay.player3Name = [offenseObject objectForKey:@"player3Name"];
            offensePlay.player3X = [offenseObject objectForKey:@"player3X"];
            offensePlay.player3Y = [offenseObject objectForKey:@"player3Y"];
            
            offensePlay.player4Name = [offenseObject objectForKey:@"player4Name"];
            offensePlay.player4X = [offenseObject objectForKey:@"player4X"];
            offensePlay.player4Y = [offenseObject objectForKey:@"player4Y"];
            
            offensePlay.player5Name = [offenseObject objectForKey:@"player5Name"];
            offensePlay.player5X = [offenseObject objectForKey:@"player5X"];
            offensePlay.player5Y = [offenseObject objectForKey:@"player5Y"];
            
            offensePlay.player6Name = [offenseObject objectForKey:@"player6Name"];
            offensePlay.player6X = [offenseObject objectForKey:@"player6X"];
            offensePlay.player6Y = [offenseObject objectForKey:@"player6Y"];
            
            offensePlay.player7Name = [offenseObject objectForKey:@"player7Name"];
            offensePlay.player7X = [offenseObject objectForKey:@"player7X"];
            offensePlay.player7Y = [offenseObject objectForKey:@"player7Y"];
            
            offensePlay.player8Name = [offenseObject objectForKey:@"player8Name"];
            offensePlay.player8X = [offenseObject objectForKey:@"player8X"];
            offensePlay.player8Y = [offenseObject objectForKey:@"player8Y"];
            
            offensePlay.player9Name = [offenseObject objectForKey:@"player9Name"];
            offensePlay.player9X = [offenseObject objectForKey:@"player9X"];
            offensePlay.player9Y = [offenseObject objectForKey:@"player9Y"];
            
            offensePlay.player10Name = [offenseObject objectForKey:@"player10Name"];
            offensePlay.player10X = [offenseObject objectForKey:@"player10X"];
            offensePlay.player10Y = [offenseObject objectForKey:@"player10Y"];
            
            offensePlay.theme = [offenseObject objectForKey:@"theme"];
            
            offensePlay.x0x = [offenseObject objectForKey:@"x0x"];
            offensePlay.x0y = [offenseObject objectForKey:@"x0y"];
            
            offensePlay.x1x = [offenseObject objectForKey:@"x1x"];
            offensePlay.x1y = [offenseObject objectForKey:@"x1y"];
            
            offensePlay.x2x = [offenseObject objectForKey:@"x2x"];
            offensePlay.x2y = [offenseObject objectForKey:@"x2y"];
            
            offensePlay.x3x = [offenseObject objectForKey:@"x3x"];
            offensePlay.x3y = [offenseObject objectForKey:@"x3y"];
            
            offensePlay.x4x = [offenseObject objectForKey:@"x4x"];
            offensePlay.x4y = [offenseObject objectForKey:@"x4y"];
            
            offensePlay.x5x = [offenseObject objectForKey:@"x5x"];
            offensePlay.x5y = [offenseObject objectForKey:@"x5y"];
            
            offensePlay.x6x = [offenseObject objectForKey:@"x6x"];
            offensePlay.x6y = [offenseObject objectForKey:@"x6y"];
            
            offensePlay.x7x = [offenseObject objectForKey:@"x7x"];
            offensePlay.x7y = [offenseObject objectForKey:@"x7y"];
            
            offensePlay.x8x = [offenseObject objectForKey:@"x8x"];
            offensePlay.x8y = [offenseObject objectForKey:@"x8y"];
            
            offensePlay.x9x = [offenseObject objectForKey:@"x9x"];
            offensePlay.x9y = [offenseObject objectForKey:@"x9y"];
            
            offensePlay.x10x = [offenseObject objectForKey:@"x10x"];
            offensePlay.x10y = [offenseObject objectForKey:@"x10y"];
            
            NSError *error = nil;
            [[self getContext] save:&error];
        } else {
            
            OffensePlay *matchedOffense;
            for (OffensePlay *offensePlay in offenseArray) {
                if ([offensePlay.playName isEqual:playTitle]) {
                    //also need to ensure it matches the correct 'owner'
                    if ([offensePlay.owner isEqualToString:owner]) {
                        matchedOffense = offensePlay;
                        break;
                    }
                }
            }
            
            if (matchedOffense != nil) {
                //locally saved play was matched, so update its data
                
                matchedOffense.playName = playTitle;
                PFFile *playThumbFile = [offenseObject objectForKey:@"snapshot"];
                NSData *imageData = [playThumbFile getData];
                matchedOffense.snapshot = imageData;
                PFFile *canvasFile = [offenseObject objectForKey:@"drawCanvas"];
                NSData *canvasData = [canvasFile getData];
                matchedOffense.drawCanvas = canvasData;
                matchedOffense.owner = [offenseObject objectForKey:@"owner"];
                matchedOffense.player0Name = [offenseObject objectForKey:@"player0Name"];
                matchedOffense.player0X = [offenseObject objectForKey:@"player0X"];
                matchedOffense.player0Y = [offenseObject objectForKey:@"player0Y"];
                
                matchedOffense.player1Name = [offenseObject objectForKey:@"player1Name"];
                matchedOffense.player1X = [offenseObject objectForKey:@"player1X"];
                matchedOffense.player1Y = [offenseObject objectForKey:@"player1Y"];
                
                matchedOffense.player2Name = [offenseObject objectForKey:@"player2Name"];
                matchedOffense.player2X = [offenseObject objectForKey:@"player2X"];
                matchedOffense.player2Y = [offenseObject objectForKey:@"player2Y"];
                
                matchedOffense.player3Name = [offenseObject objectForKey:@"player3Name"];
                matchedOffense.player3X = [offenseObject objectForKey:@"player3X"];
                matchedOffense.player3Y = [offenseObject objectForKey:@"player3Y"];
                
                matchedOffense.player4Name = [offenseObject objectForKey:@"player4Name"];
                matchedOffense.player4X = [offenseObject objectForKey:@"player4X"];
                matchedOffense.player4Y = [offenseObject objectForKey:@"player4Y"];
                
                matchedOffense.player5Name = [offenseObject objectForKey:@"player5Name"];
                matchedOffense.player5X = [offenseObject objectForKey:@"player5X"];
                matchedOffense.player5Y = [offenseObject objectForKey:@"player5Y"];
                
                matchedOffense.player6Name = [offenseObject objectForKey:@"player6Name"];
                matchedOffense.player6X = [offenseObject objectForKey:@"player6X"];
                matchedOffense.player6Y = [offenseObject objectForKey:@"player6Y"];
                
                matchedOffense.player7Name = [offenseObject objectForKey:@"player7Name"];
                matchedOffense.player7X = [offenseObject objectForKey:@"player7X"];
                matchedOffense.player7Y = [offenseObject objectForKey:@"player7Y"];
                
                matchedOffense.player8Name = [offenseObject objectForKey:@"player8Name"];
                matchedOffense.player8X = [offenseObject objectForKey:@"player8X"];
                matchedOffense.player8Y = [offenseObject objectForKey:@"player8Y"];
                
                matchedOffense.player9Name = [offenseObject objectForKey:@"player9Name"];
                matchedOffense.player9X = [offenseObject objectForKey:@"player9X"];
                matchedOffense.player9Y = [offenseObject objectForKey:@"player9Y"];
                
                matchedOffense.player10Name = [offenseObject objectForKey:@"player10Name"];
                matchedOffense.player10X = [offenseObject objectForKey:@"player10X"];
                matchedOffense.player10Y = [offenseObject objectForKey:@"player10Y"];
                
                matchedOffense.theme = [offenseObject objectForKey:@"theme"];
                
                matchedOffense.x0x = [offenseObject objectForKey:@"x0x"];
                matchedOffense.x0y = [offenseObject objectForKey:@"x0y"];
                
                matchedOffense.x1x = [offenseObject objectForKey:@"x1x"];
                matchedOffense.x1y = [offenseObject objectForKey:@"x1y"];
                
                matchedOffense.x2x = [offenseObject objectForKey:@"x2x"];
                matchedOffense.x2y = [offenseObject objectForKey:@"x2y"];
                
                matchedOffense.x3x = [offenseObject objectForKey:@"x3x"];
                matchedOffense.x3y = [offenseObject objectForKey:@"x3y"];
                
                matchedOffense.x4x = [offenseObject objectForKey:@"x4x"];
                matchedOffense.x4y = [offenseObject objectForKey:@"x4y"];
                
                matchedOffense.x5x = [offenseObject objectForKey:@"x5x"];
                matchedOffense.x5y = [offenseObject objectForKey:@"x5y"];
                
                matchedOffense.x6x = [offenseObject objectForKey:@"x6x"];
                matchedOffense.x6y = [offenseObject objectForKey:@"x6y"];
                
                matchedOffense.x7x = [offenseObject objectForKey:@"x7x"];
                matchedOffense.x7y = [offenseObject objectForKey:@"x7y"];
                
                matchedOffense.x8x = [offenseObject objectForKey:@"x8x"];
                matchedOffense.x8y = [offenseObject objectForKey:@"x8y"];
                
                matchedOffense.x9x = [offenseObject objectForKey:@"x9x"];
                matchedOffense.x9y = [offenseObject objectForKey:@"x9y"];
                
                matchedOffense.x10x = [offenseObject objectForKey:@"x10x"];
                matchedOffense.x10y = [offenseObject objectForKey:@"x10y"];
                
                NSError *error = nil;
                [[self getContext] save:&error];
                
            } else {
                //no match was found locally so create a new instance and save to core data
                
                OffensePlay *offensePlay = (OffensePlay*) [NSEntityDescription insertNewObjectForEntityForName:@"OffensePlay" inManagedObjectContext:[self managedObjectContext]];
                offensePlay.playName = playTitle;
                PFFile *playThumbFile = [offenseObject objectForKey:@"snapshot"];
                NSData *imageData = [playThumbFile getData];
                offensePlay.snapshot = imageData;
                PFFile *canvasFile = [offenseObject objectForKey:@"drawCanvas"];
                NSData *canvasData = [canvasFile getData];
                offensePlay.drawCanvas = canvasData;
                offensePlay.owner = [offenseObject objectForKey:@"owner"];
                offensePlay.player0Name = [offenseObject objectForKey:@"player0Name"];
                offensePlay.player0X = [offenseObject objectForKey:@"player0X"];
                offensePlay.player0Y = [offenseObject objectForKey:@"player0Y"];
                
                offensePlay.player1Name = [offenseObject objectForKey:@"player1Name"];
                offensePlay.player1X = [offenseObject objectForKey:@"player1X"];
                offensePlay.player1Y = [offenseObject objectForKey:@"player1Y"];
                
                offensePlay.player2Name = [offenseObject objectForKey:@"player2Name"];
                offensePlay.player2X = [offenseObject objectForKey:@"player2X"];
                offensePlay.player2Y = [offenseObject objectForKey:@"player2Y"];
                
                offensePlay.player3Name = [offenseObject objectForKey:@"player3Name"];
                offensePlay.player3X = [offenseObject objectForKey:@"player3X"];
                offensePlay.player3Y = [offenseObject objectForKey:@"player3Y"];
                
                offensePlay.player4Name = [offenseObject objectForKey:@"player4Name"];
                offensePlay.player4X = [offenseObject objectForKey:@"player4X"];
                offensePlay.player4Y = [offenseObject objectForKey:@"player4Y"];
                
                offensePlay.player5Name = [offenseObject objectForKey:@"player5Name"];
                offensePlay.player5X = [offenseObject objectForKey:@"player5X"];
                offensePlay.player5Y = [offenseObject objectForKey:@"player5Y"];
                
                offensePlay.player6Name = [offenseObject objectForKey:@"player6Name"];
                offensePlay.player6X = [offenseObject objectForKey:@"player6X"];
                offensePlay.player6Y = [offenseObject objectForKey:@"player6Y"];
                
                offensePlay.player7Name = [offenseObject objectForKey:@"player7Name"];
                offensePlay.player7X = [offenseObject objectForKey:@"player7X"];
                offensePlay.player7Y = [offenseObject objectForKey:@"player7Y"];
                
                offensePlay.player8Name = [offenseObject objectForKey:@"player8Name"];
                offensePlay.player8X = [offenseObject objectForKey:@"player8X"];
                offensePlay.player8Y = [offenseObject objectForKey:@"player8Y"];
                
                offensePlay.player9Name = [offenseObject objectForKey:@"player9Name"];
                offensePlay.player9X = [offenseObject objectForKey:@"player9X"];
                offensePlay.player9Y = [offenseObject objectForKey:@"player9Y"];
                
                offensePlay.player10Name = [offenseObject objectForKey:@"player10Name"];
                offensePlay.player10X = [offenseObject objectForKey:@"player10X"];
                offensePlay.player10Y = [offenseObject objectForKey:@"player10Y"];
                
                offensePlay.theme = [offenseObject objectForKey:@"theme"];
                
                offensePlay.x0x = [offenseObject objectForKey:@"x0x"];
                offensePlay.x0y = [offenseObject objectForKey:@"x0y"];
                
                offensePlay.x1x = [offenseObject objectForKey:@"x1x"];
                offensePlay.x1y = [offenseObject objectForKey:@"x1y"];
                
                offensePlay.x2x = [offenseObject objectForKey:@"x2x"];
                offensePlay.x2y = [offenseObject objectForKey:@"x2y"];
                
                offensePlay.x3x = [offenseObject objectForKey:@"x3x"];
                offensePlay.x3y = [offenseObject objectForKey:@"x3y"];
                
                offensePlay.x4x = [offenseObject objectForKey:@"x4x"];
                offensePlay.x4y = [offenseObject objectForKey:@"x4y"];
                
                offensePlay.x5x = [offenseObject objectForKey:@"x5x"];
                offensePlay.x5y = [offenseObject objectForKey:@"x5y"];
                
                offensePlay.x6x = [offenseObject objectForKey:@"x6x"];
                offensePlay.x6y = [offenseObject objectForKey:@"x6y"];
                
                offensePlay.x7x = [offenseObject objectForKey:@"x7x"];
                offensePlay.x7y = [offenseObject objectForKey:@"x7y"];
                
                offensePlay.x8x = [offenseObject objectForKey:@"x8x"];
                offensePlay.x8y = [offenseObject objectForKey:@"x8y"];
                
                offensePlay.x9x = [offenseObject objectForKey:@"x9x"];
                offensePlay.x9y = [offenseObject objectForKey:@"x9y"];
                
                offensePlay.x10x = [offenseObject objectForKey:@"x10x"];
                offensePlay.x10y = [offenseObject objectForKey:@"x10y"];
                
                NSError *error = nil;
                [[self getContext] save:&error];
            }
            
        }
    }
    
    
    
    
    
    //loop through retrieved defensive plays and create new or modify previous versions as appropriate
    for (PFObject *defenseObject in defensePlays) {
        NSString *playTitle = [defenseObject objectForKey:@"playName"];
        NSString *owner = [defenseObject objectForKey:@"owner"];
        
        if (defenseArray == nil || defenseArray.count < 1) {
            //no already saved offensive plays, so simply save out the retrieved one
            DefensePlay *defensePlay = (DefensePlay*) [NSEntityDescription insertNewObjectForEntityForName:@"DefensePlay" inManagedObjectContext:[self managedObjectContext]];
            defensePlay.playName = playTitle;
            PFFile *playThumbFile = [defenseObject objectForKey:@"snapshot"];
            NSData *imageData = [playThumbFile getData];
            defensePlay.snapshot = imageData;
            PFFile *canvasFile = [defenseObject objectForKey:@"drawCanvas"];
            NSData *canvasData = [canvasFile getData];
            defensePlay.drawCanvas = canvasData;
            defensePlay.owner = [defenseObject objectForKey:@"owner"];
            defensePlay.player0Name = [defenseObject objectForKey:@"player0Name"];
            defensePlay.player0X = [defenseObject objectForKey:@"player0X"];
            defensePlay.player0Y = [defenseObject objectForKey:@"player0Y"];
            
            defensePlay.player1Name = [defenseObject objectForKey:@"player1Name"];
            defensePlay.player1X = [defenseObject objectForKey:@"player1X"];
            defensePlay.player1Y = [defenseObject objectForKey:@"player1Y"];
            
            defensePlay.player2Name = [defenseObject objectForKey:@"player2Name"];
            defensePlay.player2X = [defenseObject objectForKey:@"player2X"];
            defensePlay.player2Y = [defenseObject objectForKey:@"player2Y"];
            
            defensePlay.player3Name = [defenseObject objectForKey:@"player3Name"];
            defensePlay.player3X = [defenseObject objectForKey:@"player3X"];
            defensePlay.player3Y = [defenseObject objectForKey:@"player3Y"];
            
            defensePlay.player4Name = [defenseObject objectForKey:@"player4Name"];
            defensePlay.player4X = [defenseObject objectForKey:@"player4X"];
            defensePlay.player4Y = [defenseObject objectForKey:@"player4Y"];
            
            defensePlay.player5Name = [defenseObject objectForKey:@"player5Name"];
            defensePlay.player5X = [defenseObject objectForKey:@"player5X"];
            defensePlay.player5Y = [defenseObject objectForKey:@"player5Y"];
            
            defensePlay.player6Name = [defenseObject objectForKey:@"player6Name"];
            defensePlay.player6X = [defenseObject objectForKey:@"player6X"];
            defensePlay.player6Y = [defenseObject objectForKey:@"player6Y"];
            
            defensePlay.player7Name = [defenseObject objectForKey:@"player7Name"];
            defensePlay.player7X = [defenseObject objectForKey:@"player7X"];
            defensePlay.player7Y = [defenseObject objectForKey:@"player7Y"];
            
            defensePlay.player8Name = [defenseObject objectForKey:@"player8Name"];
            defensePlay.player8X = [defenseObject objectForKey:@"player8X"];
            defensePlay.player8Y = [defenseObject objectForKey:@"player8Y"];
            
            defensePlay.player9Name = [defenseObject objectForKey:@"player9Name"];
            defensePlay.player9X = [defenseObject objectForKey:@"player9X"];
            defensePlay.player9Y = [defenseObject objectForKey:@"player9Y"];
            
            defensePlay.player10Name = [defenseObject objectForKey:@"player10Name"];
            defensePlay.player10X = [defenseObject objectForKey:@"player10X"];
            defensePlay.player10Y = [defenseObject objectForKey:@"player10Y"];
            
            defensePlay.theme = [defenseObject objectForKey:@"theme"];
            
            defensePlay.x0x = [defenseObject objectForKey:@"x0x"];
            defensePlay.x0y = [defenseObject objectForKey:@"x0y"];
            
            defensePlay.x1x = [defenseObject objectForKey:@"x1x"];
            defensePlay.x1y = [defenseObject objectForKey:@"x1y"];
            
            defensePlay.x2x = [defenseObject objectForKey:@"x2x"];
            defensePlay.x2y = [defenseObject objectForKey:@"x2y"];
            
            defensePlay.x3x = [defenseObject objectForKey:@"x3x"];
            defensePlay.x3y = [defenseObject objectForKey:@"x3y"];
            
            defensePlay.x4x = [defenseObject objectForKey:@"x4x"];
            defensePlay.x4y = [defenseObject objectForKey:@"x4y"];
            
            defensePlay.x5x = [defenseObject objectForKey:@"x5x"];
            defensePlay.x5y = [defenseObject objectForKey:@"x5y"];
            
            defensePlay.x6x = [defenseObject objectForKey:@"x6x"];
            defensePlay.x6y = [defenseObject objectForKey:@"x6y"];
            
            defensePlay.x7x = [defenseObject objectForKey:@"x7x"];
            defensePlay.x7y = [defenseObject objectForKey:@"x7y"];
            
            defensePlay.x8x = [defenseObject objectForKey:@"x8x"];
            defensePlay.x8y = [defenseObject objectForKey:@"x8y"];
            
            defensePlay.x9x = [defenseObject objectForKey:@"x9x"];
            defensePlay.x9y = [defenseObject objectForKey:@"x9y"];
            
            defensePlay.x10x = [defenseObject objectForKey:@"x10x"];
            defensePlay.x10y = [defenseObject objectForKey:@"x10y"];
            
            NSError *error = nil;
            [[self getContext] save:&error];
        } else {
            
            DefensePlay *matchedDefense;
            for (DefensePlay *defensePlay in defenseArray) {
                if ([defensePlay.playName isEqual:playTitle]) {
                    //also need to ensure it matches the correct 'owner'
                    if ([defensePlay.owner isEqualToString:owner]) {
                        matchedDefense = defensePlay;
                        break;
                    }
                }
            }
            
            if (matchedDefense != nil) {
                //locally saved play was matched, so update its data
                
                matchedDefense.playName = playTitle;
                PFFile *playThumbFile = [defenseObject objectForKey:@"snapshot"];
                NSData *imageData = [playThumbFile getData];
                matchedDefense.snapshot = imageData;
                PFFile *canvasFile = [defenseObject objectForKey:@"drawCanvas"];
                NSData *canvasData = [canvasFile getData];
                matchedDefense.drawCanvas = canvasData;
                matchedDefense.owner = [defenseObject objectForKey:@"owner"];
                matchedDefense.player0Name = [defenseObject objectForKey:@"player0Name"];
                matchedDefense.player0X = [defenseObject objectForKey:@"player0X"];
                matchedDefense.player0Y = [defenseObject objectForKey:@"player0Y"];
                
                matchedDefense.player1Name = [defenseObject objectForKey:@"player1Name"];
                matchedDefense.player1X = [defenseObject objectForKey:@"player1X"];
                matchedDefense.player1Y = [defenseObject objectForKey:@"player1Y"];
                
                matchedDefense.player2Name = [defenseObject objectForKey:@"player2Name"];
                matchedDefense.player2X = [defenseObject objectForKey:@"player2X"];
                matchedDefense.player2Y = [defenseObject objectForKey:@"player2Y"];
                
                matchedDefense.player3Name = [defenseObject objectForKey:@"player3Name"];
                matchedDefense.player3X = [defenseObject objectForKey:@"player3X"];
                matchedDefense.player3Y = [defenseObject objectForKey:@"player3Y"];
                
                matchedDefense.player4Name = [defenseObject objectForKey:@"player4Name"];
                matchedDefense.player4X = [defenseObject objectForKey:@"player4X"];
                matchedDefense.player4Y = [defenseObject objectForKey:@"player4Y"];
                
                matchedDefense.player5Name = [defenseObject objectForKey:@"player5Name"];
                matchedDefense.player5X = [defenseObject objectForKey:@"player5X"];
                matchedDefense.player5Y = [defenseObject objectForKey:@"player5Y"];
                
                matchedDefense.player6Name = [defenseObject objectForKey:@"player6Name"];
                matchedDefense.player6X = [defenseObject objectForKey:@"player6X"];
                matchedDefense.player6Y = [defenseObject objectForKey:@"player6Y"];
                
                matchedDefense.player7Name = [defenseObject objectForKey:@"player7Name"];
                matchedDefense.player7X = [defenseObject objectForKey:@"player7X"];
                matchedDefense.player7Y = [defenseObject objectForKey:@"player7Y"];
                
                matchedDefense.player8Name = [defenseObject objectForKey:@"player8Name"];
                matchedDefense.player8X = [defenseObject objectForKey:@"player8X"];
                matchedDefense.player8Y = [defenseObject objectForKey:@"player8Y"];
                
                matchedDefense.player9Name = [defenseObject objectForKey:@"player9Name"];
                matchedDefense.player9X = [defenseObject objectForKey:@"player9X"];
                matchedDefense.player9Y = [defenseObject objectForKey:@"player9Y"];
                
                matchedDefense.player10Name = [defenseObject objectForKey:@"player10Name"];
                matchedDefense.player10X = [defenseObject objectForKey:@"player10X"];
                matchedDefense.player10Y = [defenseObject objectForKey:@"player10Y"];
                
                matchedDefense.theme = [defenseObject objectForKey:@"theme"];
                
                matchedDefense.x0x = [defenseObject objectForKey:@"x0x"];
                matchedDefense.x0y = [defenseObject objectForKey:@"x0y"];
                
                matchedDefense.x1x = [defenseObject objectForKey:@"x1x"];
                matchedDefense.x1y = [defenseObject objectForKey:@"x1y"];
                
                matchedDefense.x2x = [defenseObject objectForKey:@"x2x"];
                matchedDefense.x2y = [defenseObject objectForKey:@"x2y"];
                
                matchedDefense.x3x = [defenseObject objectForKey:@"x3x"];
                matchedDefense.x3y = [defenseObject objectForKey:@"x3y"];
                
                matchedDefense.x4x = [defenseObject objectForKey:@"x4x"];
                matchedDefense.x4y = [defenseObject objectForKey:@"x4y"];
                
                matchedDefense.x5x = [defenseObject objectForKey:@"x5x"];
                matchedDefense.x5y = [defenseObject objectForKey:@"x5y"];
                
                matchedDefense.x6x = [defenseObject objectForKey:@"x6x"];
                matchedDefense.x6y = [defenseObject objectForKey:@"x6y"];
                
                matchedDefense.x7x = [defenseObject objectForKey:@"x7x"];
                matchedDefense.x7y = [defenseObject objectForKey:@"x7y"];
                
                matchedDefense.x8x = [defenseObject objectForKey:@"x8x"];
                matchedDefense.x8y = [defenseObject objectForKey:@"x8y"];
                
                matchedDefense.x9x = [defenseObject objectForKey:@"x9x"];
                matchedDefense.x9y = [defenseObject objectForKey:@"x9y"];
                
                matchedDefense.x10x = [defenseObject objectForKey:@"x10x"];
                matchedDefense.x10y = [defenseObject objectForKey:@"x10y"];
                
                NSError *error = nil;
                [[self getContext] save:&error];
                
            } else {
                //no match was found locally so create a new instance and save to core data
                
                DefensePlay *defensePlay = (DefensePlay*) [NSEntityDescription insertNewObjectForEntityForName:@"DefensePlay" inManagedObjectContext:[self managedObjectContext]];
                defensePlay.playName = playTitle;
                PFFile *playThumbFile = [defenseObject objectForKey:@"snapshot"];
                NSData *imageData = [playThumbFile getData];
                defensePlay.snapshot = imageData;
                PFFile *canvasFile = [defenseObject objectForKey:@"drawCanvas"];
                NSData *canvasData = [canvasFile getData];
                defensePlay.drawCanvas = canvasData;
                defensePlay.owner = [defenseObject objectForKey:@"owner"];
                defensePlay.player0Name = [defenseObject objectForKey:@"player0Name"];
                defensePlay.player0X = [defenseObject objectForKey:@"player0X"];
                defensePlay.player0Y = [defenseObject objectForKey:@"player0Y"];
                
                defensePlay.player1Name = [defenseObject objectForKey:@"player1Name"];
                defensePlay.player1X = [defenseObject objectForKey:@"player1X"];
                defensePlay.player1Y = [defenseObject objectForKey:@"player1Y"];
                
                defensePlay.player2Name = [defenseObject objectForKey:@"player2Name"];
                defensePlay.player2X = [defenseObject objectForKey:@"player2X"];
                defensePlay.player2Y = [defenseObject objectForKey:@"player2Y"];
                
                defensePlay.player3Name = [defenseObject objectForKey:@"player3Name"];
                defensePlay.player3X = [defenseObject objectForKey:@"player3X"];
                defensePlay.player3Y = [defenseObject objectForKey:@"player3Y"];
                
                defensePlay.player4Name = [defenseObject objectForKey:@"player4Name"];
                defensePlay.player4X = [defenseObject objectForKey:@"player4X"];
                defensePlay.player4Y = [defenseObject objectForKey:@"player4Y"];
                
                defensePlay.player5Name = [defenseObject objectForKey:@"player5Name"];
                defensePlay.player5X = [defenseObject objectForKey:@"player5X"];
                defensePlay.player5Y = [defenseObject objectForKey:@"player5Y"];
                
                defensePlay.player6Name = [defenseObject objectForKey:@"player6Name"];
                defensePlay.player6X = [defenseObject objectForKey:@"player6X"];
                defensePlay.player6Y = [defenseObject objectForKey:@"player6Y"];
                
                defensePlay.player7Name = [defenseObject objectForKey:@"player7Name"];
                defensePlay.player7X = [defenseObject objectForKey:@"player7X"];
                defensePlay.player7Y = [defenseObject objectForKey:@"player7Y"];
                
                defensePlay.player8Name = [defenseObject objectForKey:@"player8Name"];
                defensePlay.player8X = [defenseObject objectForKey:@"player8X"];
                defensePlay.player8Y = [defenseObject objectForKey:@"player8Y"];
                
                defensePlay.player9Name = [defenseObject objectForKey:@"player9Name"];
                defensePlay.player9X = [defenseObject objectForKey:@"player9X"];
                defensePlay.player9Y = [defenseObject objectForKey:@"player9Y"];
                
                defensePlay.player10Name = [defenseObject objectForKey:@"player10Name"];
                defensePlay.player10X = [defenseObject objectForKey:@"player10X"];
                defensePlay.player10Y = [defenseObject objectForKey:@"player10Y"];
                
                defensePlay.theme = [defenseObject objectForKey:@"theme"];
                
                defensePlay.x0x = [defenseObject objectForKey:@"x0x"];
                defensePlay.x0y = [defenseObject objectForKey:@"x0y"];
                
                defensePlay.x1x = [defenseObject objectForKey:@"x1x"];
                defensePlay.x1y = [defenseObject objectForKey:@"x1y"];
                
                defensePlay.x2x = [defenseObject objectForKey:@"x2x"];
                defensePlay.x2y = [defenseObject objectForKey:@"x2y"];
                
                defensePlay.x3x = [defenseObject objectForKey:@"x3x"];
                defensePlay.x3y = [defenseObject objectForKey:@"x3y"];
                
                defensePlay.x4x = [defenseObject objectForKey:@"x4x"];
                defensePlay.x4y = [defenseObject objectForKey:@"x4y"];
                
                defensePlay.x5x = [defenseObject objectForKey:@"x5x"];
                defensePlay.x5y = [defenseObject objectForKey:@"x5y"];
                
                defensePlay.x6x = [defenseObject objectForKey:@"x6x"];
                defensePlay.x6y = [defenseObject objectForKey:@"x6y"];
                
                defensePlay.x7x = [defenseObject objectForKey:@"x7x"];
                defensePlay.x7y = [defenseObject objectForKey:@"x7y"];
                
                defensePlay.x8x = [defenseObject objectForKey:@"x8x"];
                defensePlay.x8y = [defenseObject objectForKey:@"x8y"];
                
                defensePlay.x9x = [defenseObject objectForKey:@"x9x"];
                defensePlay.x9y = [defenseObject objectForKey:@"x9y"];
                
                defensePlay.x10x = [defenseObject objectForKey:@"x10x"];
                defensePlay.x10y = [defenseObject objectForKey:@"x10y"];
                
                NSError *error = nil;
                [[self getContext] save:&error];
            }
            
        }
    }
    //whew...now that all data has been 'restored' alert user in LaunchViewController
    [launchController restoreComplete];
    
}

-(void)toggleNavbar:(BOOL)boolean {

    if (boolean) {
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

@end