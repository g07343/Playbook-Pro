//
//  RemotePlaySelectionViewController.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 4/16/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaySelectionViewController.h"

@interface RemotePlaySelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *playSelection;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) NSString *playType;

-(void)setParent:(PlaySelectionViewController*)parentViewController;
@end
