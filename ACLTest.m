//
//  ACLTest.m
//  parseApp
//
//  Created by Alan Morales on 12/29/14.
//  Copyright (c) 2014 Facebook Inc. All rights reserved.
//

#import "ACLTest.h"
#import <Parse/PFObject+Subclass.h>

@implementation ACLTest

@dynamic value;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"ACLTest";
}
@end
