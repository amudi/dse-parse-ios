//
//  AMGTableViewController.m
//  parseApp
//
//  Created by Alan Morales on 1/9/15.
//  Copyright (c) 2015 Facebook Inc. All rights reserved.
//

#import "AMGTableViewController.h"
#import "AMGParseSample.h"
#import "AMGParseSection.h"
#import "AMGParseSampleSource.h"
#import "AMSLocalDataStorePlaygroundViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface AMGTableViewController ()
@end

@implementation AMGTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    [self setTitle:@"DSE Parse Tests"];
    [self setSections:[[AMGParseSampleSource sharedSource] sections]];
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [self init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AMGParseSection *sectionWrapper = [self.sections objectAtIndex:section];
    return [sectionWrapper.samples count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    AMGParseSection *sectionWrapper = self.sections[section];
    return sectionWrapper.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    AMGParseSection *sectionWrapper = self.sections[indexPath.section];
    AMGParseSample *sampleWrapper = [sectionWrapper.samples objectAtIndex:indexPath.row];
    
    cell.textLabel.text = sampleWrapper.sampleName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AMGParseSection *sectionWrapper = self.sections[indexPath.section];
    AMGParseSample *sampleWrapper = [sectionWrapper.samples objectAtIndex:indexPath.row];
    
    // Executing sample
    NSUInteger accumulatedLength = [self calculateLength:indexPath.section - 1 withIndexPath:indexPath];
    
    switch (accumulatedLength) {
            
        //Login with Parse's VC
        case VC_LOGIN:
            if (![PFUser currentUser]) {
                PFLogInViewController *loginViewController = [[PFLogInViewController alloc] init];
                [loginViewController setDelegate:self];
                
                PFSignUpViewController * signupViewController = [[PFSignUpViewController alloc] init];
                [signupViewController setDelegate:self];
                
                [loginViewController setSignUpController:signupViewController];
                
                [self presentViewController:loginViewController animated:YES completion:NULL];
            }
            break;
        case LDS_CUSTOM_ADD_DELETE_EVENTUALLY: {
            AMSLocalDataStorePlaygroundViewController *vc = [[AMSLocalDataStorePlaygroundViewController alloc] initWithNibName:@"AMSLocalDataStorePlaygroundViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        default:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [sampleWrapper execute:accumulatedLength];
            break;
    }
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    NSLog(@"Completed sign up!");
    NSLog(@"%@", [PFUser currentUser]);
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up!");
    NSLog(@"%@", [PFUser currentUser]);
}

// Transforming into a simple index from 0 to N samples
- (NSUInteger)calculateLength:(NSInteger)currentIndex withIndexPath:(NSIndexPath *)indexPath{
    if (currentIndex < 0) {
        return indexPath.row;
    }
    
    AMGParseSection *tempSection = self.sections[currentIndex];
    return [self calculateLength:currentIndex - 1 withIndexPath:indexPath] + [tempSection.samples count];
}

@end
