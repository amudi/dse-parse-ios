//
//  AMGTableViewController.h
//  parseApp
//
//  Created by Alan Morales on 1/9/15.
//  Copyright (c) 2015 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface AMGTableViewController : UITableViewController<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic) NSArray *sections;

@end
