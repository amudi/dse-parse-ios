//
//  AMSLocalDataStorePlaygroundViewController.m
//  dse-parse-ios
//
//  Created by Amudi Sebastian on 26/2/15.
//  Copyright (c) 2015 Facebook Inc. All rights reserved.
//

#import "AMSLocalDataStorePlaygroundViewController.h"
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>

@interface AMSLocalDataStorePlaygroundViewController ()

@property (nonatomic, weak) IBOutlet UIButton *addOneButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteOneButton;
@property (nonatomic, weak) IBOutlet UIButton *getLocalButton;
@property (nonatomic, weak) IBOutlet UIButton *getRemoteButton;
@property (nonatomic, weak) IBOutlet UITextField *addOneField;
@property (nonatomic, weak) IBOutlet UILabel *localCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *remoteCountLabel;
@property (nonatomic, strong) NSMutableArray *contents;

@end

@implementation AMSLocalDataStorePlaygroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self queryShareFromParse];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)addOneItem:(id)sender {
    PFObject *pfObjectForst = [PFObject objectWithClassName:@"Test"];
    pfObjectForst[@"ColA"]=self.addOneField.text;
    [pfObjectForst saveEventually];
    [pfObjectForst pinWithName:@"Results"];
    [self.contents addObject:pfObjectForst];
}

- (IBAction)getLocalItems:(id)sender {
    NSLog(@"--[%s:%d]",__PRETTY_FUNCTION__,__LINE__);
    PFQuery *query = [PFQuery queryWithClassName:@"Test"];
    [query fromPinWithName:@"Results"];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *aContents, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        self.localCountLabel.text=[@(aContents.count)stringValue];
        NSLog(@"Local : self.contents Count: %@", @(self.contents.count));
    }];
}

- (IBAction)getOnlineItems:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Test"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *aContents, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        self.remoteCountLabel.text=[@(aContents.count)stringValue];
    }];
}

- (void)queryShareFromParse {
    NSLog(@"--[%s:%d]",__PRETTY_FUNCTION__,__LINE__);
    PFQuery *query = [PFQuery queryWithClassName:@"Test"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *aContents, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        if (aContents.count>0) {
            NSLog(@"aContent Count: %@", @(aContents.count));
            NSLog(@"self.contents Count: %@", @(self.contents.count));
            [PFObject pinAll:aContents withName:@"Results"];
        }
        [self queryShareFromParse_UsingLocalDataStore];
    }];
}

- (void)queryShareFromParse_UsingLocalDataStore {
    NSLog(@"--[%s:%d]",__PRETTY_FUNCTION__,__LINE__);
    PFQuery *query = [PFQuery queryWithClassName:@"Test"];
    [query fromLocalDatastore];
    [query fromPinWithName:@"Results"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *aContents, NSError *error) {
        if (error){
            NSLog(@"Error: %@", error);
            return;
        }
        self.contents=[aContents mutableCopy];
        NSLog(@"Local : self.contents Count: %@", @(self.contents.count));
    }];
}

- (IBAction)deleteObjectEventually:(id)sender {
    NSLog(@"self.contents Count: %@", @(self.contents.count));
    PFObject *pfObject=self.contents[0];
    BFTask *t = [pfObject deleteEventually];
    [t continueWithBlock:^id(BFTask *task) {
        NSLog(@"task: %@", task);
        return nil;
    }];
    NSError *error;
//    [pfObject unpinWithName:@"Results" error:&error];
    NSLog(@"Unpin error: %@", error);
    [self.contents removeObject:self.contents[0]];
}

@end
