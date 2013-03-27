//
//  CharacterViewController.m
//  Werewolf
//
//  Created by Sihao Lu on 3/18/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "CharacterViewController.h"
#import "WerewolfGame.h"
#import "MBProgressHUD.h"
#import "CharacterSubView.h"
#import "GameViewController.h"

#define CheckCharacterViewed NO

@interface CharacterViewController ()

@end

@implementation CharacterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];   //it hides
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];    // it shows
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _playerCarousel.type = iCarouselTypeCylinder;
    _playerCarousel.decelerationRate = 0.85;
    characterViewed = [[NSMutableArray alloc] init];
    for (int i = 0; i < _playerCarousel.numberOfItems; i++) {
        [characterViewed addObject:@(i)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"CharacterViewSegue"]) {
        GameViewController *nextView = segue.destinationViewController;
        nextView.game = _game;
    }
}

#pragma mark - iCarousel Delegate
- (NSUInteger) numberOfItemsInCarousel:(iCarousel *)carousel {
    return _game.players.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    // create new view if no view is available for recycling
    if (view == nil) {
        view = [[CharacterSubView alloc] initWithFrame:CGRectMake(0, 0, 240.0f, 240.0f)];
    } else {
        
    }
    
    ((CharacterSubView *)view).nameLabel.text = [(WerewolfPlayer *)_game.players[index] name];
    
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
            return value * 0.9;
        case iCarouselOptionFadeMax:
        {
            if (_playerCarousel.type == iCarouselTypeCustom)
            {
                return 0.0f;
            }
            return value;
        }
        case iCarouselOptionCount:
            return 18;
        default:
        {
            return value;
        }
    }
}

#pragma mark - Show Character
- (void) refreshProgress:(NSTimer *)sender {
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
    } else {
        hud.progress += 0.035;
        if (hud.progress >= 1.0) {
            [self showCharacter:[sender.userInfo intValue]];
            [tapTimer invalidate];
            [hud hide:YES];
            hud = nil;
        }
    }
}

- (void) showCharacter:(NSUInteger)index {
    WerewolfPlayer *player = [_game playerAtIndex:index];
    [characterViewed removeObject:@(_playerCarousel.currentItemIndex)];
    [((CharacterSubView *)_playerCarousel.currentItemView) showCharacterLabel:player.characterName animated:YES];
}

- (IBAction)viewCharButtonPressed:(id)sender {
    tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(refreshProgress:) userInfo:@(_playerCarousel.currentItemIndex) repeats:YES];
}

- (IBAction)viewCharButtonEndPress:(id)sender {
    [tapTimer invalidate];
    [hud hide:YES];
    hud = nil;
    [((CharacterSubView *)_playerCarousel.currentItemView) hideCharacterLabelAnimated:YES];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonClicked:(id)sender {
    if (CheckCharacterViewed) {
        if (characterViewed.count > 0) {
            NSMutableString *info = [NSMutableString stringWithFormat:@"%d players (", characterViewed.count];
            int count = 0;
            for (NSNumber *index in characterViewed) {
                if (count > 2) {
                    [info appendString:@"etc. , "];
                    break;
                }
                [info appendString:[_game playerAtIndex:[index intValue]].name];
                [info appendString:@", "];
                count++;
            }
            NSMutableString *finalInfo = [NSMutableString stringWithFormat: @"%@) have not viewed characters.", [info substringToIndex:info.length - 2]];
            if (count == 1) {
                [finalInfo replaceOccurrencesOfString:@"players" withString:@"player" options:0 range:NSMakeRange(0, finalInfo.length)];
                [finalInfo replaceOccurrencesOfString:@"have" withString:@"has" options:0 range:NSMakeRange(0, finalInfo.length)];
                [finalInfo replaceOccurrencesOfString:@"characters" withString:@"character" options:0 range:NSMakeRange(0, finalInfo.length)];
            }
            [[[UIAlertView alloc] initWithTitle:@"Characters Not Viewed" message:finalInfo delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [self performSegueWithIdentifier:@"CharacterViewSegue" sender:sender];
        }
    } else {
        [self performSegueWithIdentifier:@"CharacterViewSegue" sender:sender];
    }
}
@end
