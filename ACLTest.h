//
//  ACLTest.h
//  parseApp
//
//  Created by Alan Morales on 12/29/14.
//  Copyright (c) 2014 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject+Subclass.h>
#import <Parse/PFSubclassing.h>

@interface ACLTest : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property (retain) NSNumber *value;
@end
