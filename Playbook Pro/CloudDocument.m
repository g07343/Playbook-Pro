//
//  CloudDocument.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 5/17/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "CloudDocument.h"

@implementation CloudDocument

@synthesize type, drawCanvas, owner, player0Name, player0X, player0Y, player1Name, player1X, player1Y, player2Name, player2X, player2Y, player3Name, player3X, player3Y, player4Name, player4X, player4Y, player5Name, player5X, player5Y, player6Name, player6X, player6Y, player7Name, player7X, player7Y, player8Name, player8X, player8Y, player9Name, player9X, player9Y, player10Name, player10X, player10Y, playName, snapshot, theme, x0x, x0y, x1x, x1y, x2x, x2y, x3x, x3y, x4x, x4y, x5x, x5y, x6x, x6y, x7x, x7y, x8x, x8y, x9x, x9y, x10x, x10y, utilityPlayers, name, position, image, team, dictionary;

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName
                   error:(NSError **)outError
{
    
    if ([contents length] > 0) {
        //self.noteContent = [[NSString alloc]
                            //initWithBytes:[contents bytes]
                            //length:[contents length]
                            //encoding:NSUTF8StringEncoding];
       // self.dictionary = [[NSMutableDictionary alloc] initWith];
    } else {
        // When the note is first created, assign some default content
        //self.noteContent = @"Empty";
    }
    
    return YES;    
}

@end
