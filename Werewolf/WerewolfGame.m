//
//  WerewolfGame.m
//  Werewolf
//
//  Created by Sihao Lu on 3/11/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "WerewolfGame.h"

@implementation WerewolfGame

- (id) init {
    self = [super init];
    if (self) {
        _round = 0;
        _gameStarted = NO;
        _players = [[NSMutableArray alloc] init];
        _phase = WerewolfGamePhaseSettings;
        _shieldPresent = YES;
    }
    return self;
}

- (id) initWithPlayers:(NSArray *)players {
    self = [self init];
    if (self) {
        for (WerewolfPlayer *player in players) {
            [_players addObject:[[WerewolfPlayer alloc] initWithName:player.name]];
        }
    }
    return self;
}

#pragma mark - Game initialization
- (BOOL) addPlayer:(WerewolfPlayer *)player {
    if (self.gameStarted) return NO;
    if ([self.players indexOfObject:player] != NSNotFound) {
        return NO;
    }
    [self.players addObject:player];
    return YES;
}

- (BOOL) addPlayerWithName:(NSString *)name {
    if (self.gameStarted) return NO;
    WerewolfPlayer *player = [[WerewolfPlayer alloc] initWithName:name];
    if ([self.players indexOfObject:player] != NSNotFound) {
        return NO;
    }
    [self.players addObject:player];
    return YES;
}

- (BOOL) addPlayerWithName:(NSString *)name character:(WerewolfCharacter)character {
    WerewolfPlayer *player = [[WerewolfPlayer alloc] initWithName:name];
    player.character = character;
    return [self addPlayer:player];
}

- (void) removePlayer:(WerewolfPlayer *)player {
    [self.players removeObject:player];
}

- (NSArray *) playersAlive {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (WerewolfPlayer *player in self.players) {
        if (player.alive) {
            [result addObject:player];
        }
    }
    return [result copy];
}

- (NSUInteger) playerCount {
    return [self playerCountAlive:NO];
}

- (NSUInteger) playerCountAlive:(BOOL)mustAlive {
    if (!mustAlive) return self.players.count;
    NSUInteger count = 0;
    for (WerewolfPlayer *player in self.players) {
        if (player.isAlive) {
            count++;
        }
    }
    return count;
}

- (NSUInteger) playerWithCharacterCount:(WerewolfCharacter)character mustAlive:(BOOL)mustAlive {
    NSUInteger count = 0;
    for (WerewolfPlayer *player in self.players) {
        if (mustAlive) {
            if (player.isAlive && player.character == character) {
                count++;
            }
        } else {
            if (player.character == character) {
                count++;
            }
        }
    }
    return count;
}

- (WerewolfPlayer *) playerWithCharacter:(WerewolfCharacter)character mustAlive:(BOOL)mustAlive {
    __block WerewolfPlayer *result = nil;
    [self.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([(WerewolfPlayer *)obj character] == character) {
            if ((mustAlive && [(WerewolfPlayer *)obj isAlive]) || !mustAlive) {
                result = obj;
            }
        }
    }];
    return result;
}

- (NSArray *) playersWithCharacter:(WerewolfCharacter)character mustAlive:(BOOL)mustAlive {
    NSMutableArray *playersFound = [[NSMutableArray alloc] init];
    [self.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([(WerewolfPlayer *)obj character] == character) {
            if ((mustAlive && [(WerewolfPlayer *)obj isAlive]) || !mustAlive) {
                [playersFound addObject:obj];
            }
        }
    }];
    return [playersFound copy];
}

- (WerewolfPlayer *) playerWithName:(NSString *)name {
    for (WerewolfPlayer *player in self.players) {
        if ([[player name] isEqualToString:name]) {
            return player;
        }
    }
    return nil;
}

#pragma mark - Game
- (BOOL) hasCharacter:(WerewolfCharacter)character {
    for (WerewolfPlayer *player in self.players) {
        if ([player character] == character) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isCharacterAlive:(WerewolfCharacter)character {
    for (WerewolfPlayer *player in self.players) {
        if ([player character] == character && player.isAlive) {
            return YES;
        }
    }
    return NO;
}

- (void) setLover:(WerewolfPlayer *)player withLover:(WerewolfPlayer *)anotherPlayer {
    if (!anotherPlayer && player && player.lover) {
        player.lover.lover = nil;
        player.lover = nil;
        return;
    }
    player.lover = anotherPlayer;
    anotherPlayer.lover = player;
}

- (WerewolfPlayer *) lover {
    for (WerewolfPlayer *player in self.players) {
        if (player.lover) {
            return player;
        }
    }
    return nil;
}

- (BOOL) canTargetPlayer:(WerewolfPlayer *)recipent byPlayer:(WerewolfPlayer *)actor {
    if (!recipent || actor.character == WerewolfCharacterUndefined || actor.character == WerewolfCharacterCivilian || actor.character == WerewolfCharacterElder || actor.character == WerewolfCharacterLittleGirl || actor.character == WerewolfCharacterScapegoat) {
        return NO;
    }
    if (!recipent.isAlive) return NO;
    if ([recipent isEqualToWerewolfPlayer:actor]) {
        if (actor.character == WerewolfCharacterProstitute || actor.character == WerewolfCharacterSeer) {
            return NO;
        }
    }
    return YES;
}

- (void) checkVictory {
    if (![self isCharacterAlive:WerewolfCharacterWerewolf]) {
        // If no werewolf present
        // Human victory
        [self.delegate victory:WerewolfGameVictoryHuman];
    } else {
        if ([self playerCountAlive:YES] == 2 && [self playersAlive][0]) {
            // If there are only 2 players alive
            // One is lover
            // Lover victory
            [self.delegate victory:WerewolfGameVictoryLover];
        } else if ([self playerCountAlive:YES] == [self playerWithCharacterCount:WerewolfCharacterWerewolf mustAlive:YES]) {
            // If the number of players alive
            // equals the number of werewolves alive
            // aka. all players alive are werewolves
            // Werewolf victory
            [self.delegate victory:WerewolfGameVictoryWerewolf];
        }
    }
}

- (void) next {
    if (self.phase == WerewolfGamePhaseSummary) {
        self.phase = WerewolfGamePhaseNight;
        self.round++;
    } else {
        self.phase++;
    }
    
    NSDictionary *info;
    
    switch (self.phase) {
        case WerewolfGamePhaseSetLovers:
            info = @{@"Prompt" : @"Cupid, please set two lovers."};
            self.gameStarted = YES;
            self.round = 1;
            break;
        case WerewolfGamePhaseNight:
            info = @{@"Prompt" : @"Nightfall, please close your eyes."};
            break;
        case WerewolfGamePhasePros:
            info = @{@"Prompt" : @"Prostitute, please choose a player to have fun with.", @"Character" : [self playerWithCharacter:WerewolfCharacterProstitute mustAlive:YES]};
            break;
        case WerewolfGamePhaseWerewolf:
            info = @{@"Prompt" : @"Werewolves, please choose a player to assualt.", @"Characters" : [self playersWithCharacter:WerewolfCharacterWerewolf mustAlive:YES]};
            break;
        case WerewolfGamePhaseSeer:
            info = @{@"Prompt" : @"Seer, please choose a player to check identity.", @"Character" : [self playerWithCharacter:WerewolfCharacterSeer mustAlive:YES]};
            break;
        case WerewolfGamePhaseWitch: {
            WerewolfPlayer *playerAssualted = self.victim;
            NSString *infoString = [NSString stringWithFormat:@"Witch, player %@ (%@) is assualted, would you like to save him/her? Or would you like to poison anyone?", playerAssualted.name, playerAssualted.characterName];
            info = @{@"Prompt" : infoString, @"Character" : [self playerWithCharacter:WerewolfCharacterWitch mustAlive:YES], @"Victim" : playerAssualted};
            break;
        }
        case WerewolfGamePhaseDay:
            [self summary];
            if (self.round == 1) {
                [self.delegate electSheriff];
            }
            info = @{@"Prompt" : @"Daybreak, please open your eyes."};
            break;
        case WerewolfGamePhaseVote: {
            NSString *infoString = [NSString stringWithFormat:@"Please vote the suspect to be executed. %@ (Sheriff) has 2 votes", self.sheriff.name];
            info = @{@"Prompt" : infoString};
            break;
        }
        case WerewolfGamePhaseSummary:
            [self summary];
            break;
        default:
            break;
    }
    
    [self.delegate gamePhase:self.phase info:info];
}

- (void) werewolfKillPlayer:(WerewolfPlayer *)player {
    self.victim = player;
    player.damageSource = WerewolfCharacterWerewolf;
}

- (void) witchUsePotionToPlayer:(WerewolfPlayer *)player isGoodPotion:(BOOL)goodPotion {
    if (goodPotion) {
        if (self.potionUsed) return;
        self.playerSaved = player;
        self.potionUsed = YES;
    } else {
        if (self.poisonUsed) return;
        self.playerPoisoned = player;
        player.damageSource = WerewolfCharacterWitch;
        self.poisonUsed = YES;
    }
}

- (void) prostituteSleepWithPlayer:(WerewolfPlayer *)player {
    self.playerSlept = player;
    [[self playerWithCharacter:WerewolfCharacterProstitute mustAlive:YES] setDamageSource:WerewolfCharacterProstitute];
}

- (void) votePlayer:(WerewolfPlayer *)player {
    self.playerVoted = player;
    player.damageSource = WerewolfCharacterCivilian;
}

- (void) hunterShootPlayer:(WerewolfPlayer *)player {
    self.playerShot = player;
    player.damageSource = WerewolfCharacterHunter;
    [self executePlayer:player];
}

- (void) summary {
    NSMutableArray *deathRow = [[NSMutableArray alloc] init];
    
    if (self.victim) {
        // Process victim of current round
        if (self.victim.character == WerewolfCharacterElder && self.shieldPresent) {
            // If elder is bitten by werewolf first time
            // Remove his shield
            self.shieldPresent = NO;
            if ([self.playerSaved isEqualToWerewolfPlayer:self.victim]) self.playerSaved = nil;
            self.victim.damageSource = WerewolfCharacterUndefined;
        } else {
            if ([self.playerSaved isEqualToWerewolfPlayer:self.victim]) {
                self.playerSaved = nil;
                self.victim.damageSource = WerewolfCharacterUndefined;
                // If this player is saved by witch
                // Then does not die
            } else {
                // Die
                [deathRow addObject:self.victim];
            }
        }
        self.victim = nil;
    }
    
    if (self.playerPoisoned) [deathRow addObject:self.playerPoisoned];
    
    if (self.playerVoted) [deathRow addObject:self.playerVoted];
    
    // Process hunter second last
    WerewolfPlayer *hunter = [self playerWithCharacter:WerewolfCharacterHunter mustAlive:YES];
    if (hunter && [deathRow indexOfObject:hunter] != NSNotFound) {
        [deathRow removeObject:hunter];
        [deathRow addObject:hunter];
    }
    
    // Process sheriff last
    if ([deathRow indexOfObject:self.sheriff] != NSNotFound) {
        [deathRow removeObject:self.sheriff];
        [deathRow addObject:self.sheriff];
    }
    
    for (WerewolfPlayer *player in deathRow) {
        [self executePlayer:player];
    }
    
}

- (void) executePlayer:(WerewolfPlayer *)player {
    if (!player.alive || !player) return;
    
    player.alive = NO;
    if ([self.victim isEqualToWerewolfPlayer:player]) self.victim = nil;
    if ([self.playerPoisoned isEqualToWerewolfPlayer:player]) self.playerPoisoned = nil;
    if ([self.playerSaved isEqualToWerewolfPlayer:player]) self.playerSaved = nil;
    if ([self.playerVoted isEqualToWerewolfPlayer:player]) self.playerVoted = nil;
    if ([self.playerShot isEqualToWerewolfPlayer:player]) self.playerShot = nil;
    
    if (player.lover) {
        player.lover.damageSource = WerewolfCharacterCupid;
        [self executePlayer:player.lover];
    }
    
    if ([self.playerSlept isEqualToWerewolfPlayer:player]) {
        self.playerSlept = nil;
        [self executePlayer:[self playerWithCharacter:WerewolfCharacterProstitute mustAlive:YES]];
    }
    
    if (player.character == WerewolfCharacterProstitute) {
        [self executePlayer:[self playerSlept]];
    }
    
    if (player.character == WerewolfCharacterHunter) {
        [self.delegate hunterChooseTarget];
    }
    
    [self.delegate updateStatus];
    
    if ([self.sheriff isEqualToWerewolfPlayer:player]) {
        [self.delegate electSheriff];
    }
    
    [self checkVictory];
}

#pragma mark - Support for subscripting
- (id) objectAtIndexedSubscript:(NSUInteger)index {
    return [self playersWithCharacter:index mustAlive:NO];
}

- (id) objectForKeyedSubscript:(id)key {
    return [self playerWithName:key];
}

#pragma mark - Overriding Description
- (NSString *) description {
    return [NSString stringWithFormat:@"<WerewolfGame: Started - %@, Round - %d, Players - %@>", self.gameStarted?@"YES":@"NO", self.round, self.players];
}

@end
