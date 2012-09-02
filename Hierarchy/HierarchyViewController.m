//
//  HierarchyViewController.m
//  Hierarchy
//
//  Created by Kris Fields on 8/25/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import "HierarchyViewController.h"

@interface HierarchyViewController ()
{

}

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSNumber *votes;
@property (strong, nonatomic) NSNumber *strikes;
@property (strong, nonatomic) NSMutableDictionary *playerInfo;
@property (strong, nonatomic) NSMutableArray *playerOrder;
@property (strong, nonatomic) GKTurnBasedMatch *currentMatch;
@end

@implementation HierarchyViewController
@synthesize playersToKill;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    textInputField.delegate = self;
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
    textInputField.enabled = NO;
    textInputField.hidden = YES;
    self.playersToKill.hidden = YES;
    statusLabel.text = @"Welcome.  Press Game Center to get started";
}

- (void)viewDidUnload
{
    textInputField = nil;
    statusLabel = nil;
    playersToKill = nil;
    [self setPlayersToKill:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    [self firstTurn];
    return YES;
}

-(NSMutableArray *)getPlayerOrderOutOfMatchData
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:self.currentMatch.matchData];
    NSMutableArray *unarchivedArray = [unarchiver decodeObjectForKey: @"playerOrder"];
    [unarchiver finishDecoding];
    NSMutableArray *participantOrder = [[NSMutableArray alloc]init];
    for (NSString* playerID in unarchivedArray){
        //get participant from currentMatch and add to participantOrder array
        for (GKTurnBasedParticipant *participant in self.currentMatch.participants){
            if ([participant.playerID isEqualToString:playerID]) {
                [participantOrder addObject:participant];
                break;
            }
        }
    }
    return participantOrder;
}
-(NSMutableArray *)getPlayerIDOrderOutOfMatchData
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:self.currentMatch.matchData];
    NSMutableArray *unarchivedArray = [unarchiver decodeObjectForKey: @"playerOrder"];
    [unarchiver finishDecoding];
    return unarchivedArray;
}
-(NSMutableDictionary *)getPlayerInfoOutOfMatchData:(NSString *)playerID
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:self.currentMatch.matchData];
    NSMutableDictionary *unarchivedDictionary = [unarchiver decodeObjectForKey:playerID];
    [unarchiver finishDecoding];
    return unarchivedDictionary;
}
-(int)getPreviousPlayerIndexOutOfMatchData
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:self.currentMatch.matchData];
    NSNumber *previousPlayerIndex = [unarchiver decodeObjectForKey:@"previousPlayerIndex"];
    [unarchiver finishDecoding];
    return [previousPlayerIndex intValue];
}
-(NSMutableData *)putPlayerInfoIntoMatchData
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.playerOrder forKey:@"playerOrder"];
    NSNumber *previousPlayerIndex = [NSNumber numberWithDouble:[self.currentMatch.participants indexOfObject:self.currentMatch.currentParticipant]];
    [archiver encodeObject:previousPlayerIndex forKey:@"previousPlayerIndex"];
    for (NSString *playerID in self.playerOrder){
        if ([playerID isEqualToString:self.currentMatch.currentParticipant.playerID]) {
            [archiver encodeObject:self.playerInfo forKey:self.currentMatch.currentParticipant.playerID];
        } else {
            NSMutableDictionary *playerInfo = [self getPlayerInfoOutOfMatchData:playerID];
            [archiver encodeObject:playerInfo forKey:playerID];
        }
    }
    [archiver finishEncoding];
    return data;
}
-(GKTurnBasedParticipant *)findNextParticipant
{
    NSUInteger currentIndex = [self.playerOrder indexOfObject:self.currentMatch.currentParticipant.playerID];
    NSString *nextParticipantID;
    GKTurnBasedParticipant *nextParticipant;
    nextParticipant = self.currentMatch.currentParticipant;
    
    NSUInteger nextIndex = (currentIndex + 1) % [self.playerOrder count];
    nextParticipantID = [self.playerOrder objectAtIndex:nextIndex];
    

    //loop through playerIDs in the correct player order.  For each, grab their player ID, then do a for loop to grab the corresponding GKTurnBasedParticipant object.  Then check if that participant hasn't lost and hasn't quit.  If that's the case, they're the next participant.
    for (int i = 0; i < [self.playerOrder count]; i++) {
        nextParticipantID = [self.playerOrder objectAtIndex:((currentIndex + 1 + i) % [self.playerOrder count ])];
        for (GKTurnBasedParticipant *participant in self.currentMatch.participants) {
            if ([participant.playerID isEqualToString:nextParticipantID]) {
                if (participant.matchOutcome != GKTurnBasedMatchOutcomeQuit && participant.matchOutcome != GKTurnBasedMatchOutcomeLost) {
                    nextParticipant = participant;
                    break;
                }
            }
        }
    }
    return nextParticipant;
}
- (GKTurnBasedParticipant *)findNextParticipantFirstRound {
    NSUInteger currentIndex = [self.currentMatch.participants indexOfObject:self.currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    
     for (int i = 0; i < [self.currentMatch.participants count]; i++) {
        nextParticipant = [self.currentMatch.participants objectAtIndex:((currentIndex + 1 + i) % [self.currentMatch.participants count ])];
        if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            break;
        }
    }
    return nextParticipant;
}

- (void)createPlayerOrderFirstRound {
    if ([self getPlayerIDOrderOutOfMatchData]) {
        self.playerOrder = [self getPlayerIDOrderOutOfMatchData];
    }

    [self.playerOrder addObject:self.currentMatch.currentParticipant.playerID];
}

//gets user's name and that's it.  get nsdata object from match, add new dictionary to it for current user, including name key.  hide textField after name is received.
- (void)firstTurn {
    if ([textInputField.text isEqualToString:@""] || [textInputField.text length] > 25) {
        statusLabel.text = @"No, Seriously... Enter Your  Fucking Name.";
        return;
    }
    self.name = textInputField.text;
    self.playerInfo = [NSMutableDictionary dictionaryWithDictionary:@{ @"name" : self.name, @"votes" : self.votes, @"strikes" : self.strikes }];
    [self createPlayerOrderFirstRound];
    
    NSMutableData *data = [self putPlayerInfoIntoMatchData];
    
    GKTurnBasedParticipant *nextParticipant = [self findNextParticipantFirstRound];
    NSLog(@"MATCH ID = %@", self.currentMatch.matchID);
    NSLog(@"current participant = %@", self.currentMatch.currentParticipant);
    NSLog(@"next participant:%@", nextParticipant);
    NSLog(@"player order by ID = %@", self.playerOrder);
    [self.currentMatch endTurnWithNextParticipant:nextParticipant matchData:data completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            statusLabel.text = @"No, Seriously... Enter Your  Fucking Name.";
        } else {
            self.playersToKill.hidden = NO;
            self.playersToKill.alpha = 0.2;
            [self.playersToKill reloadData];
            statusLabel.text = [NSString stringWithFormat:@"Welcome %@.  Game Will Begin Momentarily.", self.name ];
            textInputField.enabled = NO;
            textInputField.hidden = YES;
            [self.playersToKill reloadData];
        }
    }];
}

- (IBAction)presentGCTurnViewController:(id)sender {
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:16 viewController:self];
}

#pragma mark - GCTurnBasedMatchHelperDelegate

//NEVER going to be called.  Will be deleted soon...hide table.  show textfield and submit button.
-(void)enterNewGame:(GKTurnBasedMatch *)match {

}

//enable table, set voteWasCast to NO.
-(void)takeTurn:(GKTurnBasedMatch *)match {
    [self newRound];
    [self.playersToKill reloadData];
}

//display table.  disable clicking on table cells.  Match where it is not user's turn!
-(void)layoutMatch:(GKTurnBasedMatch *)match {

}


-(void)sendNotice:(NSString *)notice forMatch:
(GKTurnBasedMatch *)match {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:
                       @"Another game needs your attention! Click Game Center button..." message:notice
                                                delegate:self cancelButtonTitle:@"Sweet!"
                                       otherButtonTitles:nil];
    [av show];
}
//Check if all but 1 player has lost or quit.
-(void)checkForEnding:(NSData *)matchData {

}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    [self layoutMatch:match];
}
//Set number of votes and strikes.  Hide table.  Display textInputField but disable?  Set first turn to yes.
-(void)firstRound
{
    textInputField.enabled = YES;
    textInputField.hidden = NO;
    statusLabel.text = @"Please enter your name.";
    self.playerOrder = [[NSMutableArray alloc]init];
    self.playerInfo = [[NSMutableDictionary alloc]init];
    self.votes = [NSNumber numberWithInt:1];
    self.strikes = [NSNumber numberWithInt:0];
    self.currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];

}
//First, see if new round has started.  Do so by comparing index of currentParticpant in sortedPlayers vs index of previous Player in sortedPlayers.  Then re-sort based on number of votes.  And update round number.
-(BOOL)isItANewRound
{
    if ([self.playerOrder indexOfObject:self.currentMatch.currentParticipant.playerID] < [self getPreviousPlayerIndexOutOfMatchData]) {
        return YES;
    }
    return NO;
}
-(void)newRound
{
    self.playerOrder = [self getPlayerIDOrderOutOfMatchData];
    self.currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch]; //not sure if i need this line... why is currentParticipant.playerID null at this point??  ah...current participant is the other player, and his turn hasn't 100% ended yet... maybe that makes sense...but shouldn't he have a playerID immediately upon first turn?  we use it and don't get yelled at... don't we?
    if ([self isItANewRound]) {
        NSLog(@"It's a new round!");
    }
    else {
        NSLog(@"It's not a new round");
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.playerOrder count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    NSString *playerID = [self.playerOrder objectAtIndex:[indexPath row]];
    NSMutableDictionary *playerInfo = [self getPlayerInfoOutOfMatchData:playerID];
    cell.textLabel.text = [playerInfo objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Votes to Cast: %@, Votes Against: %@", [playerInfo objectForKey:@"votes"], [playerInfo objectForKey:@"strikes"]];
    return cell;
}




//mark cell as selected.  disable cells.  for player selected, update strikes.  check if player is dead?  update status label.  update self.sortedPlayers and the singleton instance of match.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

        
}
@end

