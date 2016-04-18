//
//  Playbook Pro.h
//  Playbook Pro
//
//  Created by Matthew Lewis on 4/2/15.
//  Copyright (c) 2015 com.fullsail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Player: NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * team;

@end
