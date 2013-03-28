//
//  SettingsTableViewController.m
//  Werewolf
//
//  Created by Sihao Lu on 3/19/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "WerewolfGame.h"
#import "CharacterViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    // Load last save
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _werewolfStepper.value = [defaults doubleForKey:@"WerewolfCount"];
    _civStepper.value = [defaults doubleForKey:@"CivCount"];
    _huntsmanSwitch.on = [defaults boolForKey:@"huntsmanEnabled"];
    _prosSwitch.on = [defaults boolForKey:@"ProsEnabled"];
    _AmorSwitch.on = [defaults boolForKey:@"AmorEnabled"];
    _elderSwitch.on = [defaults boolForKey:@"ElderEnabled"];
    [_werewolfCountLabel setText:[NSString stringWithFormat:@"%d", (int)_werewolfStepper.value]];
    [_civCountLabel setText:[NSString stringWithFormat:@"%d", (int)_civStepper.value]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [(CharacterViewController *)segue.destinationViewController setGame:_game];
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Custom methods

- (IBAction)werewolfStepper:(id)sender {
    double value = [(UIStepper *)sender value];
    [_werewolfCountLabel setText:[NSString stringWithFormat:@"%d", (int)value]];
}

- (IBAction)civStepper:(id)sender {
    double value = [(UIStepper *)sender value];
    [_civCountLabel setText:[NSString stringWithFormat:@"%d", (int)value]];
}

- (IBAction)nextButtonClicked:(id)sender {
    if ([self assignRandomCharacter]) {
        NSLog(@"%@", _game);
        [self performSegueWithIdentifier:@"SettingsSegue" sender:sender];
    }
}

- (BOOL) assignRandomCharacter {
    NSMutableArray *characters = [[NSMutableArray alloc] init];
    [characters addObject:@(WerewolfCharacterSeer)];
    [characters addObject:@(WerewolfCharacterWitch)];
    
    for (int i = 0; i < [_werewolfCountLabel.text intValue]; i++) {
        [characters addObject:@(WerewolfCharacterWerewolf)];
    }
    for (int i = 0; i < [_civCountLabel.text intValue]; i++) {
        [characters addObject:@(WerewolfCharacterCivilian)];
    }
    
    if ([_AmorSwitch isOn]) [characters addObject:@(WerewolfCharacterAmor)];
    if ([_huntsmanSwitch isOn]) [characters addObject:@(WerewolfCharacterHuntsman)];
    if ([_prosSwitch isOn]) [characters addObject:@(WerewolfCharacterProstitute)];
    if ([_elderSwitch isOn]) [characters addObject:@(WerewolfCharacterElder)];
    
    characterCount = characters.count;
    NSString *info = [NSString stringWithFormat:@"You have %d players, but there are %d characters assigned.", _game.playerCount, characterCount];
    if (characterCount != [_game playerCount]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Assign Character" message:info delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    for (WerewolfPlayer *player in _game.players) {
        int index = arc4random() % characters.count;
        player.character = [characters[index] intValue];
        [characters removeObjectAtIndex:index];
    }
    
    // Save to user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:_werewolfStepper.value forKey:@"WerewolfCount"];
    [defaults setDouble:_civStepper.value forKey:@"CivCount"];
    [defaults setBool:_AmorSwitch.isOn forKey:@"AmorEnabled"];
    [defaults setBool:_huntsmanSwitch.isOn forKey:@"huntsmanEnabled"];
    [defaults setBool:_prosSwitch.isOn forKey:@"ProsEnabled"];
    [defaults setBool:_elderSwitch.isOn forKey:@"ElderEnabled"];
    [defaults synchronize];
    
    return YES;
}
@end
