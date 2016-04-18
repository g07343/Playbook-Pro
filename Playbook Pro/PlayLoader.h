//
//  PlayLoader.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 4/15/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayCreationViewController.h"
@interface PlayLoader : NSObject

-(NSMutableArray*)setUp:(NSString*)playName editor:(PlayCreationViewController*)creator;

@end
