//
//  CloudDocument.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 5/17/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudDocument : UIDocument

//string to determine what 'type' of document this is
@property (strong) NSString * type;

@property (nonatomic, strong)NSMutableDictionary *dictionary;

//stuff for offense or defense play
@property (nonatomic, strong) NSData * drawCanvas;
@property (nonatomic, strong) NSString * owner;
@property (nonatomic, strong) NSString * player0Name;
@property (nonatomic, strong) NSNumber * player0X;
@property (nonatomic, strong) NSNumber * player0Y;
@property (nonatomic, strong) NSString * player1Name;
@property (nonatomic, strong) NSNumber * player1X;
@property (nonatomic, strong) NSNumber * player1Y;
@property (nonatomic, strong) NSString * player2Name;
@property (nonatomic, strong) NSNumber * player2X;
@property (nonatomic, strong) NSNumber * player2Y;
@property (nonatomic, strong) NSString * player3Name;
@property (nonatomic, strong) NSNumber * player3X;
@property (nonatomic, strong) NSNumber * player3Y;
@property (nonatomic, strong) NSString * player4Name;
@property (nonatomic, strong) NSNumber * player4X;
@property (nonatomic, strong) NSNumber * player4Y;
@property (nonatomic, strong) NSString * player5Name;
@property (nonatomic, strong) NSNumber * player5X;
@property (nonatomic, strong) NSNumber * player5Y;
@property (nonatomic, strong) NSString * player6Name;
@property (nonatomic, strong) NSNumber * player6X;
@property (nonatomic, strong) NSNumber * player6Y;
@property (nonatomic, strong) NSString * player7Name;
@property (nonatomic, strong) NSNumber * player7X;
@property (nonatomic, strong) NSNumber * player7Y;
@property (nonatomic, strong) NSString * player8Name;
@property (nonatomic, strong) NSNumber * player8X;
@property (nonatomic, strong) NSNumber * player8Y;
@property (nonatomic, strong) NSString * player9Name;
@property (nonatomic, strong) NSNumber * player9X;
@property (nonatomic, strong) NSNumber * player9Y;
@property (nonatomic, strong) NSString * player10Name;
@property (nonatomic, strong) NSNumber * player10X;
@property (nonatomic, strong) NSNumber * player10Y;
@property (nonatomic, strong) NSString * playName;
@property (nonatomic, strong) NSData * snapshot;
@property (nonatomic, strong) NSString * theme;
@property (nonatomic, strong) NSNumber * x0x;
@property (nonatomic, strong) NSNumber * x0y;
@property (nonatomic, strong) NSNumber * x1x;
@property (nonatomic, strong) NSNumber * x1y;
@property (nonatomic, strong) NSNumber * x2x;
@property (nonatomic, strong) NSNumber * x2y;
@property (nonatomic, strong) NSNumber * x3x;
@property (nonatomic, strong) NSNumber * x3y;
@property (nonatomic, strong) NSNumber * x4x;
@property (nonatomic, strong) NSNumber * x4y;
@property (nonatomic, strong) NSNumber * x5x;
@property (nonatomic, strong) NSNumber * x5y;
@property (nonatomic, strong) NSNumber * x6x;
@property (nonatomic, strong) NSNumber * x6y;
@property (nonatomic, strong) NSNumber * x7x;
@property (nonatomic, strong) NSNumber * x7y;
@property (nonatomic, strong) NSNumber * x8x;
@property (nonatomic, strong) NSNumber * x8y;
@property (nonatomic, strong) NSNumber * x9x;
@property (nonatomic, strong) NSNumber * x9y;
@property (nonatomic, strong) NSNumber * x10x;
@property (nonatomic, strong) NSNumber * x10y;
@property (nonatomic, strong) NSData * utilityPlayers;

//stuff for a playbook
@property (nonatomic, strong) NSString * name;

//stuff for a player
///@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * position;
@property (nonatomic, strong) NSData * image;
@property (nonatomic, strong) NSString * team;

@end
