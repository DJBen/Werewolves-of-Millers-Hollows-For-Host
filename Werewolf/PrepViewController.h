//
//  PrepViewController.h
//  Werewolf
//
//  Created by Sihao Lu on 3/18/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATSDragToReorderTableViewController.h"

@class WerewolfGame;
@interface PrepViewController : ATSDragToReorderTableViewController <UIAlertViewDelegate> {
    WerewolfGame *game;
    __weak IBOutlet UIBarButtonItem *addButton;
}

- (IBAction)addPlayerButtonClicked:(id)sender;
- (IBAction)unwindFromVictory:(UIStoryboardSegue *)segue;

@end
