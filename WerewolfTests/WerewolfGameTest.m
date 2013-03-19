//
//  WerewolfGameTest.m
//  Werewolf
//
//  Created by Sihao Lu on 3/16/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "WerewolfGameTest.h"
#import "WerewolfGame.h"
#import "WerewolfPlayer.h"
#import <OCMock/OCMock.h>

@implementation WerewolfGameTest

WerewolfGame *game;

- (void) setUp {
    [super setUp];
    game = [[WerewolfGame alloc] init];
    STAssertNotNil(game, @"Game object should not be nil");
}

- (void) tearDown {
    game = nil;
    [super tearDown];
}

- (void) testPlayerEquality {
    WerewolfPlayer *player1 = [[WerewolfPlayer alloc] initWithName:@"Nuke"];
    WerewolfPlayer *player2 = [[WerewolfPlayer alloc] initWithName:@"Ghost"];
    WerewolfPlayer *player3 = [[WerewolfPlayer alloc] initWithName:@"Nuke"];
    player3.character = WerewolfCharacterCupid;
    STAssertFalse([player1 isEqual:nil], nil);
    STAssertFalse([player2 isEqual:player1], nil);
    STAssertEqualObjects(player1, player3, @"Player equality failed");
    STAssertEquals(game.playerCount, 0U, @"Game should have no players at start.");
    [game addPlayerWithName:@"Nova"];
    STAssertEquals(game.playerCount, 1U, @"Game should have 1 player.");
    [game addPlayerWithName:@"Nuke"];
    STAssertEquals(game.playerCount, 2U, @"Game should have 2 players.");
    BOOL result = [game addPlayerWithName:@"Nuke"];
    STAssertFalse(result, nil);
    STAssertEquals(game.playerCount, 2U, @"Game should have 2 players.");
}

- (void) testSubscripting {
    WerewolfPlayer *player1 = [[WerewolfPlayer alloc] initWithName:@"Nuke"];
    player1.character = WerewolfCharacterCivilian;
    WerewolfPlayer *player2 = [[WerewolfPlayer alloc] initWithName:@"Ghost"];
    player2.character = WerewolfCharacterWerewolf;
    [game addPlayer:player1];
    [game addPlayer:player2];
    NSArray *playersWithChar =  game[WerewolfCharacterCivilian];
    STAssertEquals(playersWithChar.count, 1U, nil);
    STAssertEqualObjects(player1, playersWithChar[0], nil);
    WerewolfPlayer *player = game[@"Ghost"];
    STAssertEqualObjects(player, player2, nil);
}

- (void) testSimulateGame {
    id mockGamePhaseCallback = [OCMockObject mockForProtocol:@protocol(WerewolfGameProtocol)];
    game.delegate = mockGamePhaseCallback;
    [game addPlayerWithName:@"Ben" character:WerewolfCharacterWerewolf];
    [game addPlayerWithName:@"Ina" character:WerewolfCharacterSeer];
    [game addPlayerWithName:@"ck~" character:WerewolfCharacterWitch];
    [game addPlayerWithName:@"Jenny" character:WerewolfCharacterCupid];
    [game addPlayerWithName:@"YK" character:WerewolfCharacterCivilian];
    [game addPlayerWithName:@"Diao Jilao" character:WerewolfCharacterWerewolf];
    [game addPlayerWithName:@"SMJ" character:WerewolfCharacterProstitute];
    [game addPlayerWithName:@"Lulu" character:WerewolfCharacterHunter];
    [game addPlayerWithName:@"Xin Song" character:WerewolfCharacterWerewolf];
    STAssertEquals(game.round, 0U, nil);
    STAssertEquals(game.playerCount, 9U, @"Math too bad");
    STAssertEquals(game.isGameStarted, NO, @"What");
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseSetLovers info:[OCMArg any]];
    [game next];
    STAssertEquals(game.isGameStarted, YES, @"WTF");
    STAssertEquals(game.round, 1U, nil);
    [mockGamePhaseCallback verify];
    WerewolfPlayer *playerCk = [game playerWithName:@"ck~"];
    WerewolfPlayer *playerXS = [game playerWithName:@"Xin Song"];
    STAssertNotNil(playerCk, @"ck is out! WTF!");
    STAssertNotNil(playerXS, @"Xin Song is out! WTF!");
    [game setLover:playerCk withLover:playerXS];
    STAssertTrue([playerCk isEqualToWerewolfPlayer:game.lover] || [playerXS isEqualToWerewolfPlayer:game.lover], nil);
    STAssertEquals(playerCk, playerXS.lover, nil);
    STAssertEquals(playerXS, playerCk.lover, nil);
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseNight info:[OCMArg checkWithBlock:^BOOL(id obj) {
        if (![obj isKindOfClass:[NSDictionary class]]) return NO;
        NSString *prompt = ((NSDictionary *)obj)[@"Prompt"];
        STAssertNotNil(prompt, @"!!!");
        STAssertTrue(prompt.length > 0, @"WTF");
        NSLog(@"%@", prompt);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    STAssertEquals(game.isGameStarted, YES, @"Game not started??");
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhasePros info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        STAssertNotNil(info[@"Character"], nil);
        STAssertEquals(info[@"Character"], [game playerWithCharacter:WerewolfCharacterProstitute mustAlive:YES], nil);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    [game prostituteSleepWithPlayer:game[@"Diao Jilao"]];
    STAssertEquals(game.playerSlept, game[@"Diao Jilao"], nil);
    
    __block NSArray *characters;
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseWerewolf info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        characters = info[@"Characters"];
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    STAssertNotNil(characters, nil);
    STAssertEquals(characters.count, 3U, nil);
    [game werewolfKillPlayer:game[@"ck~"]];
    STAssertEquals(game.victim, game[@"ck~"], nil);
    
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseSeer info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        STAssertNotNil(info[@"Character"], nil);
        STAssertEquals(info[@"Character"], [game playerWithCharacter:WerewolfCharacterSeer mustAlive:YES], nil);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseWitch info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        STAssertNotNil(info[@"Character"], nil);
        STAssertEquals(info[@"Character"], [game playerWithCharacter:WerewolfCharacterWitch mustAlive:YES], nil);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    [game witchUsePotionToPlayer:game[@"ck~"] isGoodPotion:YES];
    STAssertEquals(game.playerSaved, game[@"ck~"], nil);
    
    [[mockGamePhaseCallback expect] electSheriff];
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseDay info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    game.sheriff = game[@"Jenny"];
    STAssertNotNil(game.sheriff, nil);
    STAssertEquals([game playerCountAlive:YES], 9U, @"%d" ,[game playerCountAlive:YES]);
    
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseVote info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    
    [game votePlayer:game[@"Ben"]];
    STAssertEquals(game.playerVoted, game[@"Ben"], nil);
    
    // Ben will die, so update status once
    [[mockGamePhaseCallback expect] updateStatus];
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseSummary info:[OCMArg any]];
    [game next];
    [mockGamePhaseCallback verify];
    STAssertFalse([(WerewolfPlayer *)game[@"Ben"] isAlive], @"Ben should be dead");
    NSLog(@"%@", game);
    STAssertEquals([game playerCountAlive:YES], 8U, @"Ben should be dead");
    
    /*
     * What happened in this test?
     * Ina - Seer, ck - witch, Jenny - Cupid, YK - Civ, SMJ - Pros, Lulu - Hunter,
     * Ben, Xin Song and Diao Jilao - Werewolves
     * Lovers - Xin Song and ck
     *
     * Diao JiLao - sleep with pros
     * Werewolves - kill ck
     * Seer - N/A here
     * Witch - saved ck herself
     * Daybreak - No one should die
     */
    
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseNight info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    STAssertEquals(game.round, 2U, nil);
    
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhasePros info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    [game prostituteSleepWithPlayer:game[@"Xin Song"]];
    
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseWerewolf info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        NSArray *werewolves = info[@"Characters"];
        STAssertEquals(werewolves.count, 2U, nil);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    [game werewolfKillPlayer:game[@"ck~"]]; // ck so unlucky :(
    
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseSeer info:[OCMArg any]];
    [game next];
    [mockGamePhaseCallback verify];
    
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseWitch info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        NSArray *witch = info[@"Character"];
        STAssertEquals(witch, game[@"ck~"], nil);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    [game witchUsePotionToPlayer:game[@"YK"] isGoodPotion:NO];
    STAssertEquals(game.isPoisonUsed, YES, nil);
    STAssertEquals(game.isPoisonUsed, YES, nil);

    // Four people will fall, so update status 4 times
    [[mockGamePhaseCallback expect] updateStatus];
    [[mockGamePhaseCallback expect] updateStatus];
    [[mockGamePhaseCallback expect] updateStatus];
    [[mockGamePhaseCallback expect] updateStatus];
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseDay info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    NSLog(@"%@", game);
    
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseVote info:[OCMArg checkWithBlock:^BOOL(NSDictionary *info) {
        STAssertNotNil(info[@"Prompt"], @"!!!");
        STAssertTrue(info[@"Prompt"] > 0, @"WTF");
        NSLog(@"%@", info[@"Prompt"]);
        return YES;
    }]];
    [game next];
    [mockGamePhaseCallback verify];
    
    [game votePlayer:game[@"Lulu"]];

    [[mockGamePhaseCallback expect] hunterChooseTarget];
    [[mockGamePhaseCallback expect] updateStatus];
    [[mockGamePhaseCallback expect] gamePhase:WerewolfGamePhaseSummary info:[OCMArg any]];
    [game next];
    [mockGamePhaseCallback verify];
    
    [[mockGamePhaseCallback expect] updateStatus];
    [[mockGamePhaseCallback expect] victory:WerewolfGameVictoryHuman];
    [game hunterShootPlayer:game[@"Diao Jilao"]];
    [mockGamePhaseCallback verify];
    
    NSLog(@"%@", game);
}
@end
