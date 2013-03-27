//
//  VictoryViewController.m
//  Werewolf
//
//  Created by Sihao Lu on 3/26/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "VictoryViewController.h"

@interface VictoryViewController ()

@end

@implementation VictoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    switch (self.victoryStatus) {
        case WerewolfGameVictoryHuman:
            self.victoryLabel.text = @"Human are Victorious!";
            break;
        case WerewolfGameVictoryLover:
            self.victoryLabel.text = @"Lovers are Victorious!";
            break;
        case WerewolfGameVictoryWerewolf:
            self.victoryLabel.text = @"Werewolves are Victorious!";
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
