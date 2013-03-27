//
//  SettingsTableViewController.h
//  Werewolf
//
//  Created by Sihao Lu on 3/19/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WerewolfGame;
@interface SettingsTableViewController : UITableViewController {
    NSUInteger characterCount;
}

@property (nonatomic, weak) WerewolfGame *game;
@property (weak, nonatomic) IBOutlet UILabel *werewolfCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *civCountLabel;
@property (weak, nonatomic) IBOutlet UISwitch *elderSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *prosSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hunterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cupidSwitch;
@property (weak, nonatomic) IBOutlet UIStepper *werewolfStepper;
@property (weak, nonatomic) IBOutlet UIStepper *civStepper;

- (IBAction)werewolfStepper:(id)sender;
- (IBAction)civStepper:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;

@end
