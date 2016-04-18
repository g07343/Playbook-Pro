//
//  DefensePlay.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 4/30/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DefensePlay : NSManagedObject

@property (nonatomic, retain) NSData * drawCanvas;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * player0Name;
@property (nonatomic, retain) NSNumber * player0X;
@property (nonatomic, retain) NSNumber * player0Y;
@property (nonatomic, retain) NSString * player1Name;
@property (nonatomic, retain) NSNumber * player1X;
@property (nonatomic, retain) NSNumber * player1Y;
@property (nonatomic, retain) NSString * player2Name;
@property (nonatomic, retain) NSNumber * player2X;
@property (nonatomic, retain) NSNumber * player2Y;
@property (nonatomic, retain) NSString * player3Name;
@property (nonatomic, retain) NSNumber * player3X;
@property (nonatomic, retain) NSNumber * player3Y;
@property (nonatomic, retain) NSString * player4Name;
@property (nonatomic, retain) NSNumber * player4X;
@property (nonatomic, retain) NSNumber * player4Y;
@property (nonatomic, retain) NSString * player5Name;
@property (nonatomic, retain) NSNumber * player5X;
@property (nonatomic, retain) NSNumber * player5Y;
@property (nonatomic, retain) NSString * player6Name;
@property (nonatomic, retain) NSNumber * player6X;
@property (nonatomic, retain) NSNumber * player6Y;
@property (nonatomic, retain) NSString * player7Name;
@property (nonatomic, retain) NSNumber * player7X;
@property (nonatomic, retain) NSNumber * player7Y;
@property (nonatomic, retain) NSString * player8Name;
@property (nonatomic, retain) NSNumber * player8X;
@property (nonatomic, retain) NSNumber * player8Y;
@property (nonatomic, retain) NSString * player9Name;
@property (nonatomic, retain) NSNumber * player9X;
@property (nonatomic, retain) NSNumber * player9Y;
@property (nonatomic, retain) NSString * player10Name;
@property (nonatomic, retain) NSNumber * player10X;
@property (nonatomic, retain) NSNumber * player10Y;
@property (nonatomic, retain) NSString * playName;
@property (nonatomic, retain) NSData * snapshot;
@property (nonatomic, retain) NSString * theme;
@property (nonatomic, retain) NSNumber * x0x;
@property (nonatomic, retain) NSNumber * x0y;
@property (nonatomic, retain) NSNumber * x1x;
@property (nonatomic, retain) NSNumber * x1y;
@property (nonatomic, retain) NSNumber * x2x;
@property (nonatomic, retain) NSNumber * x2y;
@property (nonatomic, retain) NSNumber * x3x;
@property (nonatomic, retain) NSNumber * x3y;
@property (nonatomic, retain) NSNumber * x4x;
@property (nonatomic, retain) NSNumber * x4y;
@property (nonatomic, retain) NSNumber * x5x;
@property (nonatomic, retain) NSNumber * x5y;
@property (nonatomic, retain) NSNumber * x6x;
@property (nonatomic, retain) NSNumber * x6y;
@property (nonatomic, retain) NSNumber * x7x;
@property (nonatomic, retain) NSNumber * x7y;
@property (nonatomic, retain) NSNumber * x8x;
@property (nonatomic, retain) NSNumber * x8y;
@property (nonatomic, retain) NSNumber * x9x;
@property (nonatomic, retain) NSNumber * x9y;
@property (nonatomic, retain) NSNumber * x10x;
@property (nonatomic, retain) NSNumber * x10y;
@property (nonatomic, retain) NSData * utilityPlayers;

@end
