//
//  VictoryViewController.h
//  Werewolf
//
//  Created by Sihao Lu on 3/26/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WerewolfGame.h"

@interface VictoryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *victoryLabel;
@property (nonatomic) WerewolfGameVictory victoryStatus;
@end
