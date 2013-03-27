//
//  GameViewController.h
//  Werewolf
//
//  Created by Sihao Lu on 3/11/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "WerewolfGame.h"

@interface GameViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, WerewolfGameDelegate, UIAlertViewDelegate> {
    NSMutableArray *chosenPlayers;
    NSMutableArray *tempInfo;
}

@property (weak, nonatomic) WerewolfGame *game;
@property (weak, nonatomic) IBOutlet iCarousel *playerCarousel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextPhaseButton;
@property (weak, nonatomic) IBOutlet UIImageView *gamePhaseImageView;
@property (weak, nonatomic) IBOutlet UILabel *gamePhaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *announcementLabel;
@property (weak, nonatomic) IBOutlet UIButton *choosePlayerButton;

- (IBAction)nextPhaseButtonClicked:(id)sender;
- (IBAction)choosePlayerButtonClicked:(id)sender;

@end
