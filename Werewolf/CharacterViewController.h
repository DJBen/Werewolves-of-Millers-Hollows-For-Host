//
//  CharacterViewController.h
//  Werewolf
//
//  Created by Sihao Lu on 3/18/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@class WerewolfGame;
@class MBProgressHUD;
@interface CharacterViewController : UIViewController <iCarouselDataSource, iCarouselDelegate> {
    NSTimer *tapTimer;
    MBProgressHUD *hud;
    NSMutableArray *characterViewed;
}
- (IBAction)viewCharButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet iCarousel *playerCarousel;
- (IBAction)viewCharButtonEndPress:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;
@property (nonatomic, weak) WerewolfGame *game;
@end
