//
//  WerewolfPlayer.m
//  Werewolf
//
//  Created by Sihao Lu on 3/11/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "WerewolfPlayer.h"

@implementation WerewolfPlayer

- (id) init {
    self = [super init];
    if (self) {
        self.character = WerewolfCharacterUndefined;
        self.alive = YES;
        self.canVote = YES;
    }
    return self;
}

- (id) initWithName:(NSString *)name {
    self = [self init];
    if (self) {
        self.name = name;
    }
    return self;
}

- (NSString *) characterName {
    return [self.class characterNameForCharacter:self.character];
}

+ (NSString *) characterNameForCharacter:(WerewolfCharacter)character {
    switch (character) {
        case WerewolfCharacterUndefined:
            return @"Unknown";
        case WerewolfCharacterWerewolf:
            return @"Werewolf";
        case WerewolfCharacterSeer:
            return @"Seer";
        case WerewolfCharacterProstitute:
            return @"Prostitute";
        case WerewolfCharacterCivilian:
            return @"Civilian";
        case WerewolfCharacterAmor:
            return @"Amor";
        case WerewolfCharacterElder:
            return @"Elder";
        case WerewolfCharacterFool:
            return @"Fool";
        case WerewolfCharacterGuard:
            return @"Guard";
        case WerewolfCharacterHuntsman:
            return @"huntsman";
        case WerewolfCharacterLittleGirl:
            return @"Little Girl";
        case WerewolfCharacterScapegoat:
            return @"Scapegoat";
        case WerewolfCharacterWitch:
            return @"Witch";
        default:
            break;
    }
    return nil;
}

#pragma mark - Equals methods
- (BOOL) isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToWerewolfPlayer:object];
}

- (BOOL) isEqualToWerewolfPlayer:(WerewolfPlayer *)player {
    BOOL isPortraitSame = YES;
    if (self.portrait || player.portrait) {
        isPortraitSame = [UIImagePNGRepresentation(self.portrait) isEqualToData:UIImagePNGRepresentation(player.portrait)];
    }
    if (!self.name && !player.name) {
        return isPortraitSame;
    } else {
        return [self.name isEqualToString:player.name] && isPortraitSame;
    }
}

- (NSUInteger) hash {
    NSUInteger hash = [super hash];
    NSUInteger prime = 31;
    hash += prime * self.name.hash;
    NSUInteger prime2 = 17;
    hash += prime2 * UIImagePNGRepresentation(self.portrait).hash;
    return hash;
}


#pragma mark - Overriding description
- (NSString *) description {
    return [NSString stringWithFormat:@"<WerewolfPlayer: Name - %@, Character - %@, Alive - %@, Can Vote - %@, Damage Source - %@>", self.name, self.characterName, self.alive?@"YES":@"NO", self.canVote?@"YES":@"NO", [self.class characterNameForCharacter:self.damageSource]];
}

#pragma mark - NSCoding Protocol
- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.alive forKey:@"Alive"];
    [aCoder encodeBool:self.canVote forKey:@"CanVote"];
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeInt:self.character forKey:@"Character"];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.character = [aDecoder decodeIntForKey:@"Character"];
        self.alive = [aDecoder decodeBoolForKey:@"Alive"];
        self.canVote = [aDecoder decodeBoolForKey:@"CanVote"];
    }
    return self;
}

@end
