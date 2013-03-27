//
//  WerewolfGame.h
//  Werewolf
//
//  Created by Sihao Lu on 3/11/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WerewolfPlayer.h"

typedef enum {
    WerewolfGameVictoryWerewolf,
    WerewolfGameVictoryHuman,
    WerewolfGameVictoryLover
} WerewolfGameVictory;

typedef enum {
    WerewolfGamePhaseSettings = -2,
    WerewolfGamePhaseSetLovers = -1,
    WerewolfGamePhaseNight = 0,
    WerewolfGamePhasePros,
    WerewolfGamePhaseWerewolf,
    WerewolfGamePhaseSeer,
    WerewolfGamePhaseWitch,
    WerewolfGamePhaseDay,
    WerewolfGamePhaseSummary1,
    WerewolfGamePhaseVote,
    WerewolfGamePhaseSummary2
} WerewolfGamePhase;

@protocol WerewolfGameDelegate <NSObject>
- (void) victory:(WerewolfGameVictory)victory;
- (void) gamePhase:(WerewolfGamePhase)phase info:(NSDictionary *)info;
- (void) electSheriff;
- (void) hunterChooseTarget;
- (void) updateDeaths:(WerewolfPlayer *)deadPlayer;
@end

@interface WerewolfGame : NSObject 

// Delegate
@property (nonatomic, weak) id <WerewolfGameDelegate> delegate;

// Indicate whether game has started.
@property (nonatomic, getter = isGameStarted) BOOL gameStarted;

// Array containing all player objects.
@property (nonatomic, strong, readonly) NSMutableArray *players;

// Game round count
@property (nonatomic) NSUInteger round;

// Game phase
@property (nonatomic) WerewolfGamePhase phase;

// Sheriff player in the game.
// Sheriff is an addition identity besides players' own characters.
@property (nonatomic, weak) WerewolfPlayer *sheriff;

// Werewolve's target(s).
// When attacking a player accompanied with a prostitute, there will be multiple victims.
@property (nonatomic, strong) WerewolfPlayer *victim;

// Prostitute's customer
@property (nonatomic, weak) WerewolfPlayer *playerSlept;

// Player saved by witch and poisoned by witch.
@property (nonatomic, strong) WerewolfPlayer *playerSaved, *playerPoisoned;

// Player voted to be exectuted
@property (nonatomic, weak) WerewolfPlayer *playerVoted;

// Player targeted by hunter
@property (nonatomic, weak) WerewolfPlayer *playerShot;

// Indicate whether witch's potion (that saves player) is used.
@property (nonatomic, getter = isPotionUsed) BOOL potionUsed;

// Indicate whether witch's poison (that kills player) is used.
@property (nonatomic, getter = isPoisonUsed) BOOL poisonUsed;

// Indicate whether elder's shield is present.
// Elder has "two lives", he can take two werewolf attacks before death.
// However, he can be easily poisoned to death by witch.
@property (nonatomic, getter = isShieldPresent) BOOL shieldPresent;

@property (nonatomic) BOOL hunterShootingMode;
@property (nonatomic) BOOL electSheriffMode;

/**
 * @param players - array containing all player objects
 * @return game object
 */

- (id) initWithPlayers:(NSArray *)players;

/**
 * @param phase - the game phase
 * @return the name description of input game phase
 */

+ (NSString *) phaseNameWithPhase:(WerewolfGamePhase)phase;

/**
 * @return name of current game phase
 */

- (NSString *) phaseName;

/**
 * @param player - the player to add
 * @return if adding successful - duplicate will result a failure 
 */

- (BOOL) addPlayer:(WerewolfPlayer *)player;

/**
 * @param name - name of player
 * @return if adding successful - duplicate will result a failure
 * Unable to add after game starts
 */

- (BOOL) addPlayerWithName:(NSString *)name;

/**
 * @param name - name of player
 * @param character - character of this player
 * @return if adding successful - duplicate will result a failure
 * Unable to add after game starts
 */

- (BOOL) addPlayerWithName:(NSString *)name character:(WerewolfCharacter)character;

/**
 * @param player - the player to be removed
 */

- (void) removePlayer:(WerewolfPlayer *)player;

/**
 * @param index - the index of player
 * @return player at index
 */

- (WerewolfPlayer *) playerAtIndex:(NSUInteger)index;

/**
 * @param character - character to find
 * @param mustAlive - need to be alive
 * @return the player object, nil if not found
 */

- (WerewolfPlayer *) playerWithCharacter:(WerewolfCharacter)character mustAlive:(BOOL)mustAlive;


/**
 * @return array of players with a certain character. 
 * @param character - the character of player(s)
 */
 
- (NSArray *) playersWithCharacter:(WerewolfCharacter)character mustAlive:(BOOL)mustAlive;

/**
 * @param name - the player name to look up
 * @return the player object found
 */

- (WerewolfPlayer *) playerWithName:(NSString *)name;

/**
 * Set two players as lovers.
 * @param player - the player
 * @param anotherPlayer - another player
 */

- (void) setLover:(WerewolfPlayer *)player withLover:(WerewolfPlayer *)anotherPlayer;

/**
 * @return any lover, nil if no lover is set.
 */

- (WerewolfPlayer *) lover;

/** 
 * @param character - the character to check
 * @return if character is alive.
 */

- (BOOL) isCharacterAlive:(WerewolfCharacter)character;

/**
 * @param character - the character to check
 * @return if game has this character.
 */

- (BOOL) hasCharacter:(WerewolfCharacter)character;

/**
 * @return array containing living player objects.
 */

- (NSArray *) playersAlive;

/**
 * @return number of all players (no matter dead or alive)
 */

- (NSUInteger) playerCount;

/**
 * @param mustAlive - if yes then only living players count, if no then count all players meet conditions
 * @return the number of players.
 */

- (NSUInteger) playerCountAlive:(BOOL)mustAlive;

/**
 * @param character - the character to check
 * @param mustAlive - if yes then only living players count, if no then count all players meet conditions
 * @return the number of players alive of this character
 */

- (NSUInteger) playerWithCharacterCount:(WerewolfCharacter)character mustAlive:(BOOL)mustAlive;

/** 
 * Check if victory. 
 */

- (void) checkVictory;

/** 
 * Go to next phase.
 */

- (void) next;

- (void) werewolfKillPlayer:(WerewolfPlayer *)player;

- (void) witchUsePotionToPlayer:(WerewolfPlayer *)player isGoodPotion:(BOOL)goodPotion;

- (void) prostituteSleepWithPlayer:(WerewolfPlayer *)player;

- (void) hunterShootPlayer:(WerewolfPlayer *)player;

- (void) electPlayerAsSheriff:(WerewolfPlayer *)player;

- (void) votePlayer:(WerewolfPlayer *)player;

/**
 * Check if current player(s) in his/her/their turn can target a chosen player.
 * @return If player is dead or is character him/herself (e.g prostitute), then cannot, else can
 * @param player - the player to receive action
 */

- (BOOL) canChoosePlayer:(WerewolfPlayer *)player;

/**
 * Show how many players can be chosen at current phase
 @return the range contains [a, b] , a - minimum number to choose, b - max number to choose
 */

- (NSRange) numberOfPlayersCanChoose;

/**
 * @param index - the *character* of players to look up
 * @return an array including player objects
 */

- (id) objectAtIndexedSubscript:(NSUInteger)index;

/**
 * @param key - the player name to look up
 * @return an array including player objects
 */

- (id) objectForKeyedSubscript:(id)key;

@end
