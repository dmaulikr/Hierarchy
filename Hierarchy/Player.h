//
//  Player.h
//  Hierarchy
//
//  Created by Kris Fields on 9/3/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *votes;
@property (strong, nonatomic) NSNumber *strikes;
@property (strong, nonatomic) NSString *playerID;
@property (nonatomic) BOOL isAlive;

+(NSArray *)getPlayerOrder;
-(Player *)initWithName:(NSString *)name;
-(NSMutableDictionary *)getPlayerInfo;

@end
