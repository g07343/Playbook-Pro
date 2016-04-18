//
//  PlayLoader.m
//  Playbook Pro
//
//  Created by Matthew Lewis on 4/15/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import "PlayLoader.h"

@implementation PlayLoader

//this class basically just returns coordinates corresponding to the name of the play passed to it, so that it
//can then call a method within PlayCreationViewController to rearrange the players onscreen to match the play layout

//Unfotunately, for now, we are only assining positions onscreen to whichever position, as trying to filter positions to correctly
//match the actual play's positions will take too much time, and will need to be implemented in the future


NSMutableArray *playCoords;




-(NSMutableArray*)setUp:(NSString*)playName editor:(PlayCreationViewController*)creator {
    NSLog(@"passed name is:  %@", playName);
    playCoords = [[NSMutableArray alloc] init];
    NSArray *xValues;
    NSArray *yValues;
    //since we can't use a switch statement to quickly eval the NSString passed, use lots of if/else statents (for now...)
    if ([playName isEqual:@"offense_t"]) {
        xValues = @[ @162.0f, @267.0f, @371.0f, @475.0f, @580.0f, @683.0f, @789.0f, @372.0f, @475.0f, @581.0f, @475.0f ];
        yValues = @[ @366.0f, @366.0f, @366.0f, @366.0f, @366.0f, @366.0f, @366.0f, @604.0f, @485.0f, @604.0f, @604.0f ];
    } else if ([playName isEqual:@"offense_i"]) {
        xValues = @[ @1.0f, @258.0f, @368.0f, @476.0f, @583.0f, @693.0f, @801.0f, @476.0f, @477.0f, @934.0f, @477.0f ];
        yValues = @[ @334.0f, @334.0f, @334.0f, @334.0f, @334.0f, @334.0f, @334.0f, @662.0f, @444.0f, @463.0f, @553.0f ];
    } else if ([playName isEqual:@"offense_spread"]) {
        xValues = @[ @1.0f, @258.0f, @368.0f, @477.0f, @583.0f, @693.0f, @813.0f, @127.0f, @477.0f, @934.0f, @477.0f ];
        yValues = @[ @334.0f, @334.0f, @334.0f, @334.0f, @334.0f, @334.0f, @443.0f, @443.0f, @443.0f, @334.0f, @553.0f ];
    } else if ([playName isEqual:@"defense_4-3"]) {
        xValues = @[ @1.0f, @181.0f, @290.0f, @394.0f, @499.0f, @604.0f, @934.0f, @117.0f, @448.0f, @716.0f, @542.0f ];
        yValues = @[ @364.0f, @435.0f, @365.0f, @365.0f, @365.0f, @365.0f, @365.0f, @620.0f, @481.0f, @438.0f, @660.0f ];
        
    } else if ([playName isEqual:@"defense_3-4"]) {
        xValues = @[ @1.0f, @181.0f, @391.0f, @312.0f, @473.0f, @626.0f, @934.0f, @117.0f, @553.0f, @751.0f, @542.0f ];
        yValues = @[ @364.0f, @435.0f, @495.0f, @364.0f, @364.0f, @364.0f, @364.0f, @620.0f, @495.0f, @435.0f, @660.0f ];
        
        
    } else if ([playName isEqual:@"defense_46"]) {
        xValues = @[ @1.0f, @186.0f, @290.0f, @394.0f, @499.0f, @601.0f, @933.0f, @205.0f, @413.0f, @703.0f, @404.0f ];
        yValues = @[ @363.0f, @363.0f, @363.0f, @363.0f, @363.0f, @461.0f, @363.0f, @480.0f, @480.0f, @461.0f, @659.0f ];
        
    } else if ([playName isEqual:@"opposing_4-3"]) {
        xValues = @[ @227.0f, @5.0f, @453.0f, @332.0f, @132.0f, @444.0f, @450.0f, @775.0f, @555.0f, @908.0f, @710.0f ];
        yValues = @[ @261.0f, @262.0f, @38.0f, @260.0f, @175.0f, @260.0f, @163.0f, @61.0f, @259.0f, @264.0f, @182.0f ];
        
        
    } else if ([playName isEqual:@"opposing_3-4"]) {
        xValues = @[ @210.0f, @47.0f, @350.0f, @332.0f, @342.0f, @444.0f, @450.0f, @669.0f, @555.0f, @908.0f, @676.0f ];
        yValues = @[ @210.0f, @256.0f, @59.0f, @260.0f, @164.0f, @260.0f, @163.0f, @90.0f, @259.0f, @264.0f, @210.0f ];
        
        
    } else if ([playName isEqual:@"opposing_46"]) {
        xValues = @[ @293.0f, @5.0f, @453.0f, @394.0f, @186.0f, @504.0f, @543.0f, @698.0f, @603.0f, @908.0f, @706.0f ];
        yValues = @[ @177.0f, @262.0f, @38.0f, @263.0f, @175.0f, @260.0f, @149.0f, @146.0f, @259.0f, @264.0f, @261.0f ];
        
        
    } else if ([playName isEqual:@"opposing_t"]) {
        xValues = @[ @339.0f, @144.0f, @336.0f, @441.0f, @241.0f, @538.0f, @436.0f, @438.0f, @634.0f, @540.0f, @739.0f ];
        yValues = @[ @262.0f, @263.0f, @99.0f, @262.0f, @263.0f, @261.0f, @180.0f, @102.0f, @261.0f, @102.0f, @259.0f ];
        
        
    } else if ([playName isEqual:@"opposing_i"]) {
        xValues = @[ @292.0f, @78.0f, @493.0f, @394.0f, @188.0f, @504.0f, @492.0f, @494.0f, @603.0f, @908.0f, @706.0f ];
        yValues = @[ @262.0f, @179.0f, @30.0f, @263.0f, @259.0f, @260.0f, @181.0f, @102.0f, @259.0f, @264.0f, @261.0f ];
        
        
    } else if ([playName isEqual:@"opposing_spread"]) {
        xValues = @[ @352.0f, @7.0f, @137.0f, @450.0f, @251.0f, @556.0f, @446.0f, @446.0f, @658.0f, @747.0f, @895.0f ];
        yValues = @[ @261.0f, @265.0f, @156.0f, @258.0f, @260.0f, @259.0f, @173.0f, @44.0f, @261.0f, @158.0f, @264.0f ];
    }

    //now that the proper values have been assigned to both single coordinate arrays, combine them and add dynamically to mutable
    for (int i = 0; i < xValues.count; i ++) {
        NSArray *tempArray = [[NSArray alloc] initWithObjects:xValues[i], yValues[i], nil];
        [playCoords addObject: tempArray];
    }
    
    return playCoords;
}

@end
