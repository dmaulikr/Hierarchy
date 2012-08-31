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
    [self sendTurn];
    return YES;
}

-(NSMutableArray *)getPlayerOrderOutOfMatchData
{
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:currentMatch.matchData];
    NSMutableArray *unarchivedArray = [unarchiver decodeObjectForKey: @"playerOrder"];
    [unarchiver finishDecoding];
    return unarchivedArray;
}
-(NSMutableDictionary *)getPlayerInfoOutOfMatchData:(NSString *)playerID
{
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:currentMatch.matchData];
    NSMutableDictionary *unarchivedDictionary = [unarchiver decodeObjectForKey:playerID];
    [unarchiver finishDecoding];
    return unarchivedDictionary;
}
-(NSMutableData *)putPlayerInfoIntoMatchData
{
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    GCTurnBasedMatchHelper *currentMatchInfo = [GCTurnBasedMatchHelper sharedInstance];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:currentMatchInfo.playerOrder forKey:@"playerOrder"];
    [archiver encodeObject:self.playerInfo forKey:currentMatch.currentParticipant.playerID];
    [archiver finishEncoding];
    return data;
}
-(GKTurnBasedParticipant *)findNextParticipant
{
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    GCTurnBasedMatchHelper *currentMatchInfo = [GCTurnBasedMatchHelper sharedInstance];
    NSUInteger currentIndex = [currentMatchInfo.playerOrder indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    
    NSUInteger nextIndex = (currentIndex + 1) % [currentMatchInfo.playerOrder count];
    nextParticipant = [currentMatchInfo.playerOrder objectAtIndex:nextIndex];
    

    for (int i = 0; i < [currentMatchInfo.playerOrder count]; i++) {
        nextParticipant = [currentMatchInfo.playerOrder objectAtIndex:((currentIndex + 1 + i) % [currentMatchInfo.playerOrder count ])];
        if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            //            NSLog(@"isnt' quit %@", nextParticipant);
            break;
        } else {
            //            NSLog(@"nex part %@", nextParticipant);
        }
    }
    return nextParticipant;
}
//gets user's name and that's it.  get nsdata object from match, add new dictionary to it for current user, including name key.  hide textField after name is received.
- (void)sendTurn {
    if ([textInputField.text isEqualToString:@""] || [textInputField.text length] > 25) {
        statusLabel.text = @"No, Seriously... Enter Your  Fucking Name.";
        return;
    }
    self.name = textInputField.text;
    self.playerInfo = [NSMutableDictionary dictionaryWithDictionary:@{ @"name" : self.name, @"votes" : self.votes, @"strikes" : self.strikes }];
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    GCTurnBasedMatchHelper *currentMatchInfo = [GCTurnBasedMatchHelper sharedInstance];
    currentMatchInfo.playerOrder = [NSMutableArray arrayWithArray:currentMatch.participants];
    
    NSMutableData *data = [self putPlayerInfoIntoMatchData];
    
    GKTurnBasedParticipant *nextParticipant = [self findNextParticipant];
    NSLog(@"MATCH ID = %@", currentMatch.matchID);
    NSLog(@"player order = %@", currentMatchInfo.playerOrder);
    NSLog(@"current participant:%@", currentMatch.currentParticipant);
    NSLog(@"next participant:%@", nextParticipant);
    [currentMatch endTurnWithNextParticipant:nextParticipant matchData:data completionHandler:^(NSError *error) {
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
    GCTurnBasedMatchHelper *currentMatchInfo = [GCTurnBasedMatchHelper sharedInstance];
    currentMatchInfo.playerOrder = [[NSMutableArray alloc]init];
    self.playerInfo = [[NSMutableDictionary alloc]init];
    self.votes = [NSNumber numberWithInt:1];
    self.strikes = [NSNumber numberWithInt:0];

}
//First, see if new round has started.  Do so by comparing index of currentParticpant in sortedPlayers vs index of previous Player in sortedPlayers.  Then re-sort based on number of votes.  And update round number.
-(void)newRound
{
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    GCTurnBasedMatchHelper *currentMatchInfo = [GCTurnBasedMatchHelper sharedInstance];
    return [currentMatchInfo.playerOrder count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
//    GCTurnBasedMatchHelper *currentMatchInfo = [GCTurnBasedMatchHelper sharedInstance];
    GKTurnBasedParticipant *currentPlayer = [[self getPlayerOrderOutOfMatchData] objectAtIndex:[indexPath row]];
    NSString *currentPlayerID = currentPlayer.playerID;
    NSMutableDictionary *playerInfo = [self getPlayerInfoOutOfMatchData:currentPlayerID];
    cell.textLabel.text = [playerInfo objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Votes to Cast: %@, Votes Against: %@", [playerInfo objectForKey:@"votes"], [playerInfo objectForKey:@"strikes"]];
    return cell;
}




//mark cell as selected.  disable cells.  for player selected, update strikes.  check if player is dead?  update status label.  update self.sortedPlayers and the singleton instance of match.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

        
}
@end

