//
//  PlayerSelectionViewController.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 3/25/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *playerTable;
@property (nonatomic, weak) NSString *playType;
@end
