//
//  PrepViewController.m
//  Werewolf
//
//  Created by Sihao Lu on 3/18/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "PrepViewController.h"
#import "WerewolfGame.h"
#import "SettingsTableViewController.h"

@interface PrepViewController ()

@end

@implementation PrepViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPlayers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self savePlayers];
    [(SettingsTableViewController *)segue.destinationViewController setGame:game];
}

- (IBAction)addPlayerButtonClicked:(id)sender {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Add Player" message:@"Type the player name below:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    message.delegate = self;
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [message show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Add"]) {
        UITextField *name = [alertView textFieldAtIndex:0];
        WerewolfPlayer *player = [[WerewolfPlayer alloc] initWithName:name.text];
        [game addPlayer:player];
        NSLog(@"Player %@ added", player.name);
        [self.tableView reloadData];
    }
}

- (void) savePlayers {
    NSMutableArray *playerData = [[NSMutableArray alloc] init];
    for (WerewolfPlayer *player in game.players) {
        [playerData addObject:[NSKeyedArchiver archivedDataWithRootObject:player]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:playerData forKey:@"Players"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadPlayers {
    __block NSMutableArray *players = [[NSMutableArray alloc] init];
    [[[NSUserDefaults standardUserDefaults] arrayForKey:@"Players"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSData *playerData = obj;
        WerewolfPlayer *player = [NSKeyedUnarchiver unarchiveObjectWithData:playerData];
        [players addObject:player];
    }];
    
    if (players.count > 0) {
        game = [[WerewolfGame alloc] initWithPlayers:players];
    } else {
        game = [[WerewolfGame alloc] init];
    }
    
    [self.tableView reloadData];
}

- (IBAction)unwindFromVictory:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Table View Data Source
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Player Names";
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PlayerNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = [(WerewolfPlayer *)game.players[indexPath.row] name];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [game playerCount];
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
    static NSString *identifier = @"PlayerNameCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.textLabel.text = [(WerewolfPlayer *)game.players[indexPath.row] name];
	return cell;
}

#pragma mark - Table View Delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WerewolfPlayer *playerToDelete = [[WerewolfPlayer alloc] initWithName:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        NSLog(@"Player %@ removed", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
        [game removePlayer:playerToDelete];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    WerewolfPlayer *player = [game playerAtIndex:sourceIndexPath.row];
    [game.players removeObject:player];
    [game.players insertObject:player atIndex:destinationIndexPath.row];
}

@end
