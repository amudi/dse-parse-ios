//
//  AMGParseSampleSource.m
//  parseApp
//
//  Created by Alan Morales on 1/12/15.
//  Copyright (c) 2015 Facebook Inc. All rights reserved.
//

#import "AMGParseSampleSource.h"
#import "ACLTest.h"
#import "AMGParseSection.h"
#import "AMGParseSample.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation AMGParseSampleSource
static NSMutableArray *mutableSections = nil;


+ (instancetype)sharedSource {
    static AMGParseSampleSource *sharedSource;
    
    if (!sharedSource) {
        sharedSource = [[self alloc] initPrivate];
    }
    
    return sharedSource;
}

- (instancetype)init {
    [NSException raise:@"Singleton" format:@"Use [AMGParseSampleSource sharedSource]"];
    
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    [self setupSections];
    
    return self;
}

- (NSArray *)sections {
    if (mutableSections == nil) {
        [self setupSections];
    }
    
    return mutableSections;
}

/*
 *
 *  This is where you set up UI for new sections and samples
 *
 */
- (void)setupSections {
    mutableSections = [[NSMutableArray alloc] init];
    NSArray *sections = @[@"Login", @"Events / Analytics", @"ACL", @"PFObjects", @"Queries", @"LDS", @"Pointers", @"Random"];
    
    NSDictionary *samples =
    @{
      @"Login" : @[@"Sign Up", @"Log In", @"Anonymous Login", @"View Controller Login", @"Facebook", @"Twitter"],
      @"Events / Analytics" : @[@"Save Installation", @"Save Event"],
      @"ACL" : @[@"Add New Field", @"Update Existing Field", @"ACL Test Query"],
      @"PFObjects" : @[@"Save PFUser Property", @"Refresh User"],
      @"Queries" : @[@"Get First Object", @"Get First, using class", @"Compound Query Test"],
      @"LDS" : @[@"ACL Pinning Test"],
      @"Pointers": @[@"Cloud Code Pointer Test"],
      @"Random" : @[@"BC / AD Dates Saving", @"BC / AD Dates Retrieving"]
      };
    
    for (NSString *section in sections) {
        AMGParseSection *sectionWrapper = [[AMGParseSection alloc] initWithName:section];
        
        NSArray *currentSamples = [samples objectForKey:section];
        for (NSString *sample in currentSamples) {
            AMGParseSample *sampleWrapper = [[AMGParseSample alloc] initWithName:sample];
            
            [sectionWrapper addSample:sampleWrapper];
        }
        
        [mutableSections addObject:sectionWrapper];
    }
}

/*
 *
 *  This is where you put the code for new samples. Please also update AMGParseSampleSource.h enum
 *
 */
- (void)executeSample:(NSInteger)sampleIndex {
    switch (sampleIndex) {

        case SIGN_UP: {
            NSLog(@"Sign Up!");
            if (![PFUser currentUser]) {
                PFUser *user = [PFUser user];
                user.username = @"alan";
                user.email = @"alan@alan.com";
                user.password = @"alan";
                [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"Signed up!");
                    [self logUser: user];
                }];
                
            } else {
                NSLog(@"User already exists!");
                [self logUser:[PFUser currentUser]];
            }
            break;
        }
            
        case LOGIN: {
            NSLog(@"Login!");
            if (![PFUser currentUser]) {
                NSString *userName = @"alan";
                NSString *password = @"alan";
                
                [PFUser logInWithUsernameInBackground:userName password:password block:^(PFUser *user, NSError *error) {
                    if (user) {
                        NSLog(@"logged in successfully!");
                    } else {
                        NSLog(@"No user logged in!");
                    }
                }];
            } else {
                NSLog(@"Already logged in, not doing it");
            }
            break;
        }
            
        case ANON_LOGIN: {
            NSLog(@"Parse Anonymous Login");
            [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
                if (error == nil) {
                    NSLog(@"Anonymous Login Success!");
                    [self logUser:user];
                } else {
                
                }
            }];
            break;
        }
            
        // Handled by the Table View Controller
        case VC_LOGIN: {break;}
        
        case FB_LOGIN: {
            NSLog(@"Starting Facebook Auth");
            
            // Set permissions required from the facebook user account
            NSArray *permissionsArray = @[@"user_about_me", @"user_friends"];
            
            // Login PFUser using Facebook
            [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
                NSLog(@"Came back from loginWithPermissions! Name is %@", user[@"displayName"]);
                
                if (!user) {
                    NSString *errorMessage = nil;
                    if (!error) {
                        errorMessage = @"Uh oh. The user cancelled the Facebook login.";
                    } else {
                        NSLog(@"Uh oh. An error occurred: %@", error);
                        errorMessage = [error localizedDescription];
                    }
                    [self alertWithMessage:errorMessage title:@"Facebook Login Error"];
                } else {
                    if (user.isNew) {
                        NSLog(@"User with facebook signed up and logged in!");
                    } else {
                        NSLog(@"User with facebook logged in!");
                    }
                    
                    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
                    
                    [params setObject:@"id,gender,first_name,last_name,birthday" forKey:@"fields"];
                    
                    [FBRequestConnection startWithGraphPath:@"me/friends" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        ////// do stuff with the friends. here we get only friends that use the app if permissions are asked via Safari > facebook.com
                        NSArray* friends = [result objectForKey:@"data"];
                        NSLog(@"Found: %lu friends", friends.count);
                        for (NSDictionary<FBGraphUser>* friend in friends) {
                            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
                        }
                    }];
                }
            }];
            break;
        }
            
        case TWITTER_LOGIN: {
            if ([PFUser currentUser]) {
                [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                     if (!error) {
                         if (succeeded) {
                             [self alertWithMessage:@"Authorization Successful!" title:@"Twitter Login"];
                         }
                         else {
                             [self alertWithMessage:@"Authorization Cancelled!" title:@"Twitter Login"];
                         }
                     }
                     else
                     {
                         [self alertWithMessage:[error localizedDescription] title:@"Twitter Login"];
                     }
                 }];
            }
            else {
                NSLog(@"Creating user with twitter credentials");
                [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
                     if (!error) {
                         if (user) {
                             [self alertWithMessage:@"Authorization Successful!" title:@"Twitter Login"];
                         } else {
                             [self alertWithMessage:@"Authorization Cancelled!" title:@"Twitter Login"];
                         }
                     } else {
                         [self alertWithMessage:[error localizedDescription] title:@"Twitter Login"];
                     }
                 }];
            }
            
            break;
        }
            
        case SAVE_INSTALLATION: {
            NSLog(@"Saving Parse Installation");
            
            // Store the deviceToken in the current Installation and save it to Parse.
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation saveInBackground];
            
            [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Installation saved! check dashboard!");
            }];
            break;
        }
         
        case ANALYTICS_TEST: {
            NSLog(@"Starting Custom Analytics Test!");
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            NSString *todayString = [dateFormatter stringFromDate:today];
            
            NSDictionary *dimensions = @{
                                         @"type":@"Open Routebschrijving",
                                         @"timestring":todayString
                                         };
            
            //[PFAnalytics trackEvent:@"action" dimensions:dimensions];
            [PFAnalytics trackEventInBackground:@"action" dimensions:dimensions block:^(BOOL succeeded, NSError *error) {
                NSLog(@"Tracking Event Finished! Succeeded? %@", succeeded);
            }];
            
            NSLog(@"Custom Analytics Test Done!");
            break;
        }
            
        case ACL_NEW_FIELD: {
            [self roleTestWithField:@"new"];
            break;
        }
            
        case ACL_EXISTING_FIELD: {
            [self roleTestWithField:@"existing"];
            break;
        }
            
        case ACL_TEST_QUERY: {
            PFQuery *aclTestQuery = [PFQuery queryWithClassName:@"ACLTest"];
            [aclTestQuery whereKey:@"createdAt" lessThan:[NSDate date]];
            [aclTestQuery setCachePolicy:kPFCachePolicyCacheElseNetwork];
            [aclTestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"Callback!");
                if (error) {
                    [self alertWithMessage:[error description] title:@"ACL Query"];
                } else {
                    NSLog(@"Finding!");
                    for (PFObject *object in objects) {
                        NSLog(@"Found %@ = %@", object.objectId, object[@"value"]);
                    }
                }
            }];
            break;
        }
            
        case SAVE_USER_PROPERTY: {
            NSLog(@"Save user property");
            if ([PFUser currentUser]) {
                [PFUser currentUser][@"location"] = @"Chicago, IL";
                [[PFUser currentUser] saveInBackground];
                NSLog(@"Done Saving property");
            }
            break;
        }
        
        case REFRESH_USER: {
            NSLog(@"Refresh User");
            if ([PFUser currentUser]) {
                [[PFUser currentUser] fetch];
                NSLog([PFUser currentUser][@"location"]);
            }
            break;
        }
            
        case QUERY_FIRST_OBJECT: {
            PFQuery *aclq = [PFQuery queryWithClassName:@"ACLTest"];
            NSError *error;
            PFObject *first = [aclq getFirstObject:&error];
            
            NSLog(@"First id %@", [first objectId]);
            break;
        }
            
        case QUERY_FIRST_OBJECT_USING_CLASS: {
            PFQuery *aclq = [ACLTest query];
            NSError *error;
            PFObject *first = [aclq getFirstObject:&error];
            NSLog(@"First id %@", [first objectId]);
            ACLTest *result = (ACLTest *)first;
            NSLog(@"Device es %@", result);
            break;
        }
            
        case QUERY_COMPOUND: {
            [self alertWithMessage:@"Not Implemented" title:@"Compound Query Test"];
            break;
        }
            
        case LDS_PINNING: {
            PFQuery *aclq = [PFQuery queryWithClassName:@"ACLTest"];
            [aclq findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error == nil) {
                    NSLog(@"Find In Background is back!");
                    for (PFObject *object in objects) {
                        NSLog(@"Found %@ = %@", object.objectId, object[@"value"]);
                    }
                    [PFObject pinAllInBackground:objects withName:@"ACLTestObjects" block:^(BOOL succeeded, NSError *error) {
                        if (error == nil) {
                            NSLog(@"Success when pinning %lu objects to local datastore", (unsigned long)[objects count]);
                        } else {
                            NSLog(@"There was an error when pinning: %@", [error description]);
                        }
                    }];
                } else {
                    NSLog(@"There was an error pulling objects in background: %@", [error description]);
                }
            }];
            
            break;
        }
            
        case CLOUD_CODE_POINTER_TEST: {
            NSLog(@"Cloud code pointer test");
            [PFCloud callFunctionInBackground:@"createObjectWithPointer" withParameters:@{} block:^(id object, NSError *error) {
                PFObject *objectWithPointer = (PFObject *)object;
                
                NSLog(@"randomColumn Value %@", objectWithPointer[@"randomColumn"]);
                PFObject *aclTest = objectWithPointer[@"aclTestObject"];
                NSLog(@"aclTest isDataAvailable %@", aclTest.isDataAvailable);
            }];
            break;
        }
            
        case BC_AD_DATES_SAVING: {
            NSLog(@"Testing BC/AD Dates");
            
            NSString *dateFormat = @"MMMM d, yyyy GGG";
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:dateFormat];
            
            NSArray *dateA = @[@"March 15, 44 BC",@"April 15, 62 AD",@"June 15, 101 AD"];
            NSMutableDictionary *dateMD = [NSMutableDictionary dictionaryWithCapacity:3];
            
            NSLog(@"Show strings and resulting dates");
            for (NSString *string in dateA) {
                NSDate *date = [dateFormatter dateFromString:string];
                NSLog(@"NSDate instance for string '%@' = %@\n       formatted = %@",string,date,[dateFormatter stringFromDate:date]);
                [dateMD setObject:date forKey:string];
            }
            
            // Saving to Parse
            /*
            for (NSString *key in dateMD) {
                NSDate *old_date = [dateMD objectForKey:key];
                
                
                PFObject *acBcTest = [[PFObject alloc] initWithClassName:@"ACBCDate"];
                acBcTest[@"name"] = [NSString stringWithFormat:@"%@%@", @"test_", key];
                acBcTest[@"savedDate"] = old_date;
                
                NSLog(@"Before Saving %@", acBcTest[@"savedDate"]);
                [acBcTest saveInBackground];
            }
            */
            
            break;
        }
            
        case BC_AD_DATES_RETRIEVING: {
            NSLog(@"Retrieving ACBCDates");
            PFQuery *acBcQuery = [PFQuery queryWithClassName:@"ACBCDate"];

            NSString *dateFormat = @"MMMM d, yyyy GGG";
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:dateFormat];
            [acBcQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    for (PFObject *parseDate in objects) {
                        NSLog(@"%@ : %@", parseDate[@"name"], [dateFormatter stringFromDate:parseDate[@"savedDate"]]);
                    }
                } else {
                    NSLog(@"There was an error retrieving dates: %@", [error description]);
                }
            }];
            
            break;
        }

        default:
            NSLog(@"Unknown sample code to exeute!");
            break;
    }
}

- (void)roleTestWithField:(NSString*)field {
    NSLog(@"Role Testing with %@ field", field);
    
    if ([PFUser currentUser]) {
        NSString* fieldName = @"description";
        
        if ([field  isEqual: @"new"]) {
            fieldName = @"fbTest";
        }
        
        PFObject *exception = [PFObject objectWithClassName:@"Exception"];
        exception[fieldName] = @"fbTest";
        [exception saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
            if (error) {
                NSLog(@"Error saving Exception: %@", error);
            } else {
                NSLog(@"Saved succesfully, check the data browser");
            }
        }];
    } else {
        [self alertWithMessage:@"You have to Sign Up first!" title:[NSString stringWithFormat:@"Role Test With Field '%@d'", field]];
    }
}

- (void)logUser:(PFUser*) fetched {
    NSLog(@"Current user is %@", fetched[@"username"]);
}

- (void)alertWithMessage:(NSString *)message title:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Got It", nil];
    
    [alert show];
}

@end
