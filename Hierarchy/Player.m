//
//  Player.m
//  Hierarchy
//
//  Created by Kris Fields on 9/3/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import "Player.h"

@implementation Player

+(NSArray *)getPlayerOrder
{
    
}

-(Player *)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        self.strikes = 0;
        self.votes = [NSNumber numberWithInt: 1];
        self.name = name;
    }
    return self;
}
-(id)init
{
    return [self initWithName:nil];
}
-(NSMutableDictionary *)getPlayerInfo
{
    NSMutableDictionary *playerInfo = [NSMutableDictionary dictionaryWithDictionary:@{ @"name" : self.name, @"votes" : self.votes, @"strikes" : self.strikes }];
    return playerInfo;
}
@end
