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
        _huntsmanShootingMode = NO;
        _electSheriffMode = NO;
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

- (WerewolfPlayer *) playerAtIndex:(NSUInteger)index {
    if (index >= self.players.count) {
        return nil;
    }
    return self.players[index];
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
+ (NSString *) phaseNameWithPhase:(WerewolfGamePhase)phase {
    switch (phase) {
        case WerewolfGamePhaseDay:
            return @"Daybreak";
        case WerewolfGamePhaseNight:
            return @"Nightfall";
        case WerewolfGamePhasePros:
            return @"Prostitute's Turn";
        case WerewolfGamePhaseSeer:
            return @"Seer's Turn";
        case WerewolfGamePhaseSetLovers:
            return @"Amor's Turn";
        case WerewolfGamePhaseSettings:
            return @"Game Settings";
        case WerewolfGamePhaseSummary1:
        case WerewolfGamePhaseSummary2:
            return @"Summary";
        case WerewolfGamePhaseVote:
            return @"Time to Vote";
        case WerewolfGamePhaseWerewolf:
            return @"Werewolves' Turn";
        case WerewolfGamePhaseWitch:
            return @"Witch's Turn";
        default:
            break;
    }
    return nil;
}

- (NSString *) phaseName {
    return [self.class phaseNameWithPhase:self.phase];
}

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

- (BOOL) canChoosePlayer:(WerewolfPlayer *)player {
    if (!player || !player.isAlive) {
        return NO;
    }
    switch (self.phase) {
        case WerewolfGamePhaseSetLovers:
            return YES;
        case WerewolfGamePhasePros: {
            WerewolfPlayer *pros = [self playerWithCharacter:WerewolfCharacterProstitute mustAlive:YES];
            if (!pros) return NO;
            if (player.character == WerewolfCharacterProstitute) return NO;
            if ([pros isEqualToWerewolfPlayer:self.playerSlept]) return NO;
            return YES;
        }
        case WerewolfGamePhaseSeer: {
            WerewolfPlayer *seer = [self playerWithCharacter:WerewolfCharacterSeer mustAlive:YES];
            if (!seer) return NO;
            if (player.character == WerewolfCharacterSeer) return NO;
            if ([seer isEqualToWerewolfPlayer:self.playerSlept]) return NO;
            return YES;
        }
        case WerewolfGamePhaseWerewolf: {
            NSArray *weres = self[WerewolfCharacterWerewolf];
            if (!weres || weres.count == 0) return NO;
            if (weres.count == 1 && [(WerewolfPlayer *)weres[0] isEqualToWerewolfPlayer:self.playerSlept]) return NO;
            return YES;
        }
        case WerewolfGamePhaseWitch: {
            WerewolfPlayer *witch = [self playerWithCharacter:WerewolfCharacterWitch mustAlive:YES];
            if (!witch) return NO;
            if ([witch isEqualToWerewolfPlayer:self.playerSlept]) return NO;
            return YES;
        }
        case WerewolfGamePhaseVote:
            return YES;
        case WerewolfGamePhaseSummary1:
        case WerewolfGamePhaseSummary2:
            if (_electSheriffMode || _huntsmanShootingMode) {
                return YES;
            }
            break;
        default:
            break;
    }
    return NO;
}

- (NSRange) numberOfPlayersCanChoose {
    switch (self.phase) {
        case WerewolfGamePhasePros: 
            if (![self playerWithCharacterCount:WerewolfCharacterProstitute mustAlive:YES]) return NSMakeRange(0, 0);
            if ([[self playerWithCharacter:WerewolfCharacterProstitute mustAlive:YES] isEqualToWerewolfPlayer:self.playerSlept]) return NSMakeRange(0, 0);
            return NSMakeRange(0, 1);
        case WerewolfGamePhaseSeer:
            if (![self playerWithCharacterCount:WerewolfCharacterSeer mustAlive:YES]) return NSMakeRange(0, 0);
            if ([[self playerWithCharacter:WerewolfCharacterSeer mustAlive:YES] isEqualToWerewolfPlayer:self.playerSlept]) return NSMakeRange(0, 0);
            return NSMakeRange(1, 1);
        case WerewolfGamePhaseSetLovers:
            return NSMakeRange(2, 2);
        case WerewolfGamePhaseWerewolf:
            if ([self playerWithCharacterCount:WerewolfCharacterWerewolf mustAlive:YES] == 1 && [[self playerWithCharacter:WerewolfCharacterWerewolf mustAlive:YES] isEqualToWerewolfPlayer:self.playerSlept]) return NSMakeRange(0, 0);
            return NSMakeRange(0, 1);
        case WerewolfGamePhaseVote:
            return NSMakeRange(0, 1);
        case WerewolfGamePhaseWitch:
            if (![self playerWithCharacter:WerewolfCharacterWitch mustAlive:YES]) return NSMakeRange(0, 0);
            if ([[self playerWithCharacter:WerewolfCharacterWitch mustAlive:YES] isEqualToWerewolfPlayer:self.playerSlept]) return NSMakeRange(0, 0);
            return NSMakeRange(0, 1);
        case WerewolfGamePhaseSummary1:
        case WerewolfGamePhaseSummary2:
            if (_electSheriffMode) {
                return NSMakeRange(1, 1);
            } else if (_huntsmanShootingMode) {
                return NSMakeRange(0, 1);
            }
        default:
            break;
    }
    return NSMakeRange(0, 0);
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
    if (self.phase == WerewolfGamePhaseSummary2) {
        self.phase = WerewolfGamePhaseNight;
        self.round++;
    } else {
        self.phase++;
    }
    
    NSDictionary *info;
    
    switch (self.phase) {
        case WerewolfGamePhaseSetLovers:
            info = @{@"Prompt" : @"Amor, please set two lovers."};
            self.gameStarted = YES;
            self.round = 1;
            break;
        case WerewolfGamePhaseNight:
            info = @{@"Prompt" : @"Nightfall, please close your eyes."};
            break;
        case WerewolfGamePhasePros: {
            WerewolfPlayer *pros = [self playerWithCharacter:WerewolfCharacterProstitute mustAlive:YES];
            if (pros) {
                info = @{@"Prompt" : @"Prostitute, please choose a player to have fun with.", @"Character" : pros};
            } else {
                info = @{@"Prompt" : @"Prostitute has dead. Pretend to say \"Please choose a player to have fun with.\""};
            }
            break;
        }
        case WerewolfGamePhaseWerewolf:
            if ([self playersWithCharacter:WerewolfCharacterWerewolf mustAlive:YES].count == 1 && [[self playerWithCharacter:WerewolfCharacterWerewolf mustAlive:YES] isEqualToWerewolfPlayer:self.playerSlept]) {
                info = @{@"Prompt" : @"The only werewolf is enjoy his/her night."};
            } else {
                info = @{@"Prompt" : @"Werewolves, please choose a player to assualt.", @"Characters" : [self playersWithCharacter:WerewolfCharacterWerewolf mustAlive:YES]};
            }
            break;
        case WerewolfGamePhaseSeer: {
            WerewolfPlayer *seer = [self playerWithCharacter:WerewolfCharacterSeer mustAlive:YES];
            if (seer) {
                if ([seer isEqualToWerewolfPlayer:self.playerSlept]) {
                    info = @{@"Prompt" : @"Seer is enjoying his/her night."};
                } else {
                    info = @{@"Prompt" : @"Seer, please choose a player to check identity.", @"Character" : seer};
                }
            } else {
                info = @{@"Prompt" : @"Seer has dead. Pretend to say \"please choose a player to check.\""};
            }
            break;
        }
        case WerewolfGamePhaseWitch: {
            WerewolfPlayer *playerAssualted = self.victim;
            WerewolfPlayer *witch = [self playerWithCharacter:WerewolfCharacterWitch mustAlive:NO];
            if (witch.isAlive) {
                NSString *infoString;
                if ([witch isEqualToWerewolfPlayer:self.playerSlept]) {
                    infoString = [NSString stringWithFormat:@"Witch (%@) is enjoy his/her night.", witch.name];
                    info = @{@"Prompt" : infoString, @"Character" : [self playerWithCharacter:WerewolfCharacterWitch mustAlive:YES]};
                    break;
                }
                infoString = [NSString stringWithFormat:@"Witch (%@), player %@ (%@) is assualted, would you like to save him/her? Or poison anyone?", witch.name, playerAssualted.name, playerAssualted.characterName];
                if (playerAssualted) {
                    info = @{@"Prompt" : infoString, @"Character" : [self playerWithCharacter:WerewolfCharacterWitch mustAlive:YES], @"Victim" : playerAssualted};
                } else {
                    infoString = [NSString stringWithFormat:@"Witch (%@), no player is assualted. Would you like to poison anyone?", witch.name];
                    info = @{@"Prompt" : infoString, @"Character" : [self playerWithCharacter:WerewolfCharacterWitch mustAlive:YES]};
                }
            } else {
                NSString *infoString = [NSString stringWithFormat:@"Witch (%@) is dead. Player %@ (%@) is assualted.", witch.name, playerAssualted.name, playerAssualted.characterName];
                if (playerAssualted) {
                    info = @{@"Prompt" : infoString, @"Victim" : playerAssualted};
                } else {
                    infoString = [NSString stringWithFormat:@"Witch (%@) is dead. No player is assualted.", witch.name];
                    info = @{@"Prompt" : infoString};
                }
            }
            break;
        }
        case WerewolfGamePhaseDay:
            info = @{@"Prompt" : @"Daybreak, please open your eyes."};
            break;
        case WerewolfGamePhaseVote: {
            NSString *sheriffString = self.sheriff.name?[NSString stringWithFormat:@"%@ (Sheriff) has 2 votes", self.sheriff.name]:@"";
            NSString *infoString = [NSString stringWithFormat:@"Please vote the suspect to be executed. %@", sheriffString];
            info = @{@"Prompt" : infoString};
            break;
        }
        case WerewolfGamePhaseSummary1:
        case WerewolfGamePhaseSummary2:
            info = @{@"Prompt" : @"Summary ended. Please continue."};
        default:
            break;
    }
    
    [self.delegate gamePhase:self.phase info:info];
    
    switch (self.phase) {
        case WerewolfGamePhaseSummary1:
            if (self.round == 1) {
                _electSheriffMode = YES;
                [self.delegate electSheriff];
            }
            [self summary:self.phase];
            break;
        case WerewolfGamePhaseSummary2:
            [self summary:self.phase];
            break;
        default:
            break;
    }
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

- (void) huntsmanShootPlayer:(WerewolfPlayer *)player {
    self.playerShot = player;
    player.damageSource = WerewolfCharacterHuntsman;
    _huntsmanShootingMode = NO;
    [self summary:self.phase];
}

- (void) electPlayerAsSheriff:(WerewolfPlayer *)player {
    self.sheriff = player;
    _electSheriffMode = NO;
}

- (void) summary:(WerewolfGamePhase)gamePhase {
    // Clean up remaining status first
    // If it is daytime afternoon, then clean up the mess yesterday night
    // If it is daybreak, clean up vote status last afternoon
    if (gamePhase == WerewolfGamePhaseSummary2) {
        self.playerSlept = nil;
        self.playerSaved = nil;
        self.playerPoisoned = nil;
        self.victim = nil;
    } else if (gamePhase == WerewolfGamePhaseSummary1) {
        self.playerVoted = nil;
    }
    
    NSMutableArray *deathRow = [[NSMutableArray alloc] init];
    
    if (self.victim) {
        // Process victim of current round
        if (self.victim.character == WerewolfCharacterElder && self.shieldPresent) {
            // If elder is bitten by werewolf first time
            // Remove his shield
            self.shieldPresent = NO;
            if ([self.playerSaved isEqualToWerewolfPlayer:self.victim]) self.playerSaved = nil;
            self.victim.damageSource = WerewolfCharacterUndefined;
        } else if (self.victim.character == WerewolfCharacterProstitute && self.playerSlept) {
            // Do nothing, prostitute is not home
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
    
    if (self.playerPoisoned) {
        if (!(self.victim.character == WerewolfCharacterProstitute && self.playerSlept)) {
            [deathRow addObject:self.playerPoisoned];
        }
    }
    
    if (self.playerVoted) [deathRow addObject:self.playerVoted];
    
    if (self.playerShot) [deathRow addObject:self.playerShot];
    
    NSMutableArray *newDeathRow = [[NSMutableArray alloc] init];
    
    for (WerewolfPlayer *player in deathRow) {
        if (player.lover && ![player.lover isEqualToWerewolfPlayer:self.playerSaved]) {
            [newDeathRow addObject:player.lover];
            player.lover.damageSource = WerewolfCharacterAmor;
            break;
        }
    }
    
    [deathRow addObjectsFromArray:newDeathRow];
    
    newDeathRow = [[NSMutableArray alloc] init];

    for (WerewolfPlayer *player in deathRow) {
        if ([player isEqualToWerewolfPlayer:self.playerSlept]) {
            [newDeathRow addObject:[self playerWithCharacter:WerewolfCharacterProstitute mustAlive:YES]];
            break;
        }
    }
    
    [deathRow addObjectsFromArray:newDeathRow];
    
    // Process sheriff second last
    if ([deathRow indexOfObject:self.sheriff] != NSNotFound) {
        [deathRow removeObject:self.sheriff];
        [deathRow addObject:self.sheriff];
    }
    
    // Process huntsman last
    WerewolfPlayer *huntsman = [self playerWithCharacter:WerewolfCharacterHuntsman mustAlive:YES];
    if (huntsman && [deathRow indexOfObject:huntsman] != NSNotFound) {
        [deathRow removeObject:huntsman];
        [deathRow addObject:huntsman];
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
    if ([self.playerSlept isEqualToWerewolfPlayer:player]) self.playerSlept = nil;
    
    [self.delegate updateDeaths:player];
    
    if ([self.sheriff isEqualToWerewolfPlayer:player]) {
        _electSheriffMode = YES;
        [self.delegate electSheriff];
    }
    
    if (player.character == WerewolfCharacterHuntsman) {
        _huntsmanShootingMode = YES;
        [self.delegate huntsmanChooseTarget];
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
