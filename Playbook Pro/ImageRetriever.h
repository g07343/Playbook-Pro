//
//  ImageRetriever.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 8/28/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "RemotePlaySelectionViewController.h"

@interface ImageRetriever : NSObject

@property (nonatomic) int numberThumbs;
@property (nonatomic) int numberCanvas;
@property RemotePlaySelectionViewController *remoteController;

-(void)getImage:(PFFile*)file :(int)index;

@end
