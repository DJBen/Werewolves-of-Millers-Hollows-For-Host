//
//  WerewolfPlayer.h
//  Werewolf
//
//  Created by Sihao Lu on 3/11/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WerewolfCharacterUndefined, WerewolfCharacterWerewolf, WerewolfCharacterCivilian, WerewolfCharacterWitch, WerewolfCharacterSeer, WerewolfCharacterHunter, WerewolfCharacterLittleGirl, WerewolfCharacterGuard, WerewolfCharacterCupid, WerewolfCharacterProstitute, WerewolfCharacterScapegoat, WerewolfCharacterFool, WerewolfCharacterElder
} WerewolfCharacter;

typedef struct {
    int WerewolfPlayerTypeCivilian;
    int WerewolfPlayerTypeWerewolf;
    int WerewolfPlayerTypeAbilityUser;
} WerewolfPlayerType;

@interface WerewolfPlayer : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic) WerewolfCharacter character;
@property (nonatomic, strong) UIImage *portrait;
@property (nonatomic, getter = isAlive) BOOL alive;
@property (nonatomic, weak) WerewolfPlayer *lover;
@property (nonatomic) WerewolfCharacter damageSource;
@property (nonatomic) BOOL canVote;

- (id) initWithName:(NSString *)name;
- (BOOL) isEqualToWerewolfPlayer:(WerewolfPlayer *)player;
- (NSString *) characterName;
+ (NSString *) characterNameForCharacter:(WerewolfCharacter)character;
@end
