//
//  ImageRetriever.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 8/28/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "ImageRetriever.h"

@implementation ImageRetriever

@synthesize numberCanvas, numberThumbs, remoteController;

NSMutableArray *thumbsArray;
int thumbCounter;

-(void)getImage:(PFFile*)file :(int)index {
    if (thumbsArray == nil) {
        thumbsArray = [[NSMutableArray alloc] initWithCapacity:numberThumbs];
        thumbCounter = 0;
    }
    
    
}

@end
