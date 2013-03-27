//
//  GameViewController.m
//  Werewolf
//
//  Created by Sihao Lu on 3/11/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "GameViewController.h"
#import "CharacterSubView.h"
#import "VictoryViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];   //it hides
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];    // it shows
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    chosenPlayers = [[NSMutableArray alloc] initWithCapacity:_game.playerCount];
    _playerCarousel.type = iCarouselTypeCylinder;
    _playerCarousel.decelerationRate = 0.85;
    _game.delegate = self;
    [self loadInfo];
    [_game next];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"VictorySegue"]) {
        [(VictoryViewController *)segue.destinationViewController setVictoryStatus:[sender[@"Victory"] intValue]];
    }
}

- (void) loadInfo {
    WerewolfPlayer *player = [_game playerAtIndex:[_playerCarousel currentItemIndex]];
    NSMutableString *statusString = [[NSMutableString alloc] init];
    if ([_game.sheriff isEqualToWerewolfPlayer:player]) {
        [statusString appendString:@"Sheriff. "];
    }
    if ([[_game victim] isEqualToWerewolfPlayer:player]) {
        [statusString appendString:@"Assualted. "];
    }
    if ([[_game playerPoisoned] isEqualToWerewolfPlayer:player]) {
        [statusString appendString:@"Poisoned. "];
    }
    if ([[_game playerSaved] isEqualToWerewolfPlayer:player]) {
        [statusString appendString:@"Saved. "];
    }
    if ([[_game playerVoted] isEqualToWerewolfPlayer:player]) {
        [statusString appendString:@"Voted. "];
    }
    if ([[_game playerSlept] isEqualToWerewolfPlayer:player]) {
        [statusString appendString:@"Slept. "];
    }
    
    _infoLabel.text = [NSString stringWithFormat:@"%@. %@. %@. %@", player.characterName, player.isAlive?@"Alive":@"Dead", player.canVote?@"Can Vote":@"Cannot Vote.", statusString];
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:player.name];
    [attribString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:19.0]range:NSMakeRange(0, attribString.length)];
    if (player.lover) {
        NSMutableAttributedString *attribString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" (loves %@)", player.lover.name]];
        [attribString2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:14.0]range:NSMakeRange(0, attribString2.length)];
        [attribString appendAttributedString:attribString2];
    }
    _nameLabel.attributedText = attribString;
}

- (void) refresh {
    if (chosenPlayers) [chosenPlayers removeAllObjects];
    [self loadInfo];
    [_playerCarousel reloadData];
    _choosePlayerButton.enabled = [_game canChoosePlayer:[_game playerAtIndex:_playerCarousel.currentItemIndex]];
}

#pragma mark - iCarousel Delegate
- (NSUInteger) numberOfItemsInCarousel:(iCarousel *)carousel {
    return _game.players.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    // create new view if no view is available for recycling
    if (view == nil) {
        view = [[CharacterSubView alloc] initWithFrame:CGRectMake(0, 0, 150.0f, 150.0f)];
    } else {
        
    }
    
    ((CharacterSubView *)view).nameLabel.text = [(WerewolfPlayer *)_game.players[index] name];
    if ([chosenPlayers indexOfObject:[_game playerAtIndex:index]] != NSNotFound) {
        [(CharacterSubView *)view setSelected:YES];
    } else {
        [(CharacterSubView *)view setSelected:NO];
    }
        
    return view;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            return value * 0.9;
        }
        case iCarouselOptionFadeMax:
        {
            if (_playerCarousel.type == iCarouselTypeCustom)
            {
                return 0.0f;
            }
            return value;
        }
        case iCarouselOptionCount:
            return 20;
        default:
        {
            return value;
        }
    }
}

- (void) carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    [self loadInfo];
    _choosePlayerButton.enabled = [_game canChoosePlayer:[_game playerAtIndex:carousel.currentItemIndex]];
}

- (IBAction)nextPhaseButtonClicked:(id)sender {
    if ([_game numberOfPlayersCanChoose].location <= chosenPlayers.count && [_game numberOfPlayersCanChoose].length >= chosenPlayers.count) {
        switch ([_game phase]) {
            case WerewolfGamePhaseSetLovers:
                [_game setLover:chosenPlayers[0] withLover:chosenPlayers[1]];
                break;
            case WerewolfGamePhasePros:
                if (chosenPlayers.count) [_game prostituteSleepWithPlayer:chosenPlayers[0]];
                break;
            case WerewolfGamePhaseWerewolf:
                if (chosenPlayers.count) [_game werewolfKillPlayer:chosenPlayers[0]];
                break;
            case WerewolfGamePhaseWitch: {
                if (chosenPlayers.count) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Potion" message:@"Please select potion to use: potion or poison?" delegate:self cancelButtonTitle:@"Poison" otherButtonTitles:@"Potion", nil];
                    alert.tag = 1023;
                    [alert show];
                    return;
                }
                break;
            }
            case WerewolfGamePhaseSeer: {
                if (chosenPlayers.count) {
                    WerewolfPlayer *player = chosenPlayers[0];
                    NSString *result = [NSString stringWithFormat:@"Player %@ (%@) is %@.", player.name, player.characterName, (player.character != WerewolfCharacterWerewolf)?@"good":@"bad"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seer" message:result delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                break;
            }
            case WerewolfGamePhaseVote:
                if (chosenPlayers.count) [_game votePlayer:chosenPlayers[0]];
                break;
            default:
                break;
        }
        
        [_game next];
        
    } else {
        NSString *rangeString = [NSString stringWithFormat:@"%d ~ %d", [_game numberOfPlayersCanChoose].location, [_game numberOfPlayersCanChoose].length];
        if ([_game numberOfPlayersCanChoose].location == [_game numberOfPlayersCanChoose].length) {
            rangeString = [NSString stringWithFormat:@"%d", [_game numberOfPlayersCanChoose].location];
        }
        [[[UIAlertView alloc] initWithTitle:@"Choose Player" message:[NSString stringWithFormat:@"Please choose %@ players. Currently have chosen %d.", rangeString, chosenPlayers.count] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
}

- (IBAction)choosePlayerButtonClicked:(id)sender {
    WerewolfPlayer *player = [_game playerAtIndex:[_playerCarousel currentItemIndex]];
    if ([chosenPlayers indexOfObject:player] == NSNotFound) {
        [chosenPlayers addObject:player];
    } else {
        [chosenPlayers removeObject:player];
    }
    [_playerCarousel reloadData];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1023) {
        if (buttonIndex == 1) {
            NSLog(@"Good");
            if (chosenPlayers.count) [_game witchUsePotionToPlayer:chosenPlayers[0] isGoodPotion:YES];
        } else {
            if (chosenPlayers.count) [_game witchUsePotionToPlayer:chosenPlayers[0] isGoodPotion:NO];
        }
        [_game next];
    }
}

#pragma mark - Werewolf Delegate
- (void) victory:(WerewolfGameVictory)victory {
    [self performSegueWithIdentifier:@"VictorySegue" sender:@{@"ViewController" : self, @"Victory" :@(victory)}];
}

- (void) gamePhase:(WerewolfGamePhase)phase info:(NSDictionary *)info {
    NSLog(@"Game phase: %d, %@", phase, [_game phaseName]);
    [self refresh];
    _announcementLabel.text = info[@"Prompt"];
    _gamePhaseLabel.text = _game.phaseName;
}

- (void) updateDeaths:(WerewolfPlayer *)deadPlayer {
    NSLog(@"Update death: %@", deadPlayer);
    [self refresh];
    [[[UIAlertView alloc] initWithTitle:@"Player is Dead" message:[NSString stringWithFormat:@"Player %@ is dead.", deadPlayer.name] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void) hunterChooseTarget {
    NSLog(@"Hunter choose target evoked");
    if (!tempInfo) tempInfo = [[NSMutableArray alloc] init];
    [tempInfo addObject:@{@"Prompt" : _announcementLabel.text, @"Phase" : _gamePhaseLabel.text, @"ButtonTarget" : [_nextPhaseButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside][0]}];
    _announcementLabel.text = @"Hunter, please choose your target";
    _gamePhaseLabel.text = @"Hunter's Turn";
    [_nextPhaseButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [_nextPhaseButton addTarget:self action:@selector(hunterChooseTargetNextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"%@", tempInfo);
    [self refresh];
}

- (void) hunterChooseTargetNextButtonClicked:(id)sender {
    NSLog(@"Hunter mode clicked, %@", tempInfo);
    if ([_game numberOfPlayersCanChoose].location <= chosenPlayers.count && [_game numberOfPlayersCanChoose].length >= chosenPlayers.count) {
        
        [_game hunterShootPlayer:chosenPlayers[0]];
        
        // Recover information;
        _announcementLabel.text = [tempInfo lastObject][@"Prompt"];
        _gamePhaseLabel.text = [tempInfo lastObject][@"Phase"];
        [_nextPhaseButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [_nextPhaseButton addTarget:self action:NSSelectorFromString([tempInfo lastObject][@"ButtonTarget"]) forControlEvents:UIControlEventTouchUpInside];
        [tempInfo removeLastObject];
        
        [self refresh];
        NSLog(@"%@", tempInfo);
    } else {
        NSString *rangeString = [NSString stringWithFormat:@"%d ~ %d", [_game numberOfPlayersCanChoose].location, [_game numberOfPlayersCanChoose].length];
        if ([_game numberOfPlayersCanChoose].location == [_game numberOfPlayersCanChoose].length) {
            rangeString = [NSString stringWithFormat:@"%d", [_game numberOfPlayersCanChoose].location];
        }
        [[[UIAlertView alloc] initWithTitle:@"Choose Player" message:[NSString stringWithFormat:@"Please choose %@ players. Currently have chosen %d.", rangeString, chosenPlayers.count] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void) electSheriff {
    NSLog(@"Elect sheriff evoked, current phase = %@", _game.phaseName);
    if (!tempInfo) tempInfo = [[NSMutableArray alloc] init];
    [tempInfo addObject:@{@"Prompt" : _announcementLabel.text, @"Phase" : _gamePhaseLabel.text, @"ButtonTarget" : [_nextPhaseButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside][0]}];
    _announcementLabel.text = @"Sheriff is dead, please elect sheriff.";
    _gamePhaseLabel.text = @"Elect Sheriff";
    [_nextPhaseButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [_nextPhaseButton addTarget:self action:@selector(electSheriffButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self refresh];
    NSLog(@"%@", tempInfo);
}

- (void) electSheriffButtonClicked:(id)sender {
    NSLog(@"Elect sheriff clicked, %@", tempInfo);
    if ([_game numberOfPlayersCanChoose].location <= chosenPlayers.count && [_game numberOfPlayersCanChoose].length >= chosenPlayers.count) {
        [_game electPlayerAsSheriff:chosenPlayers[0]];
        
        // Recover information
        _announcementLabel.text = [tempInfo lastObject][@"Prompt"];
        _gamePhaseLabel.text = [tempInfo lastObject][@"Phase"];
        [_nextPhaseButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [_nextPhaseButton addTarget:self action:NSSelectorFromString([tempInfo lastObject][@"ButtonTarget"]) forControlEvents:UIControlEventTouchUpInside];
        [tempInfo removeLastObject];
        
        [self refresh];
        NSLog(@"%@", tempInfo);
    } else {
        NSString *rangeString = [NSString stringWithFormat:@"%d ~ %d", [_game numberOfPlayersCanChoose].location, [_game numberOfPlayersCanChoose].length];
        if ([_game numberOfPlayersCanChoose].location == [_game numberOfPlayersCanChoose].length) {
            rangeString = [NSString stringWithFormat:@"%d", [_game numberOfPlayersCanChoose].location];
        }
        [[[UIAlertView alloc] initWithTitle:@"Choose Player" message:[NSString stringWithFormat:@"Please choose %@ players. Currently have chosen %d.", rangeString, chosenPlayers.count] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
}


@end
