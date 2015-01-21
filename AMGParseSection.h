//
//  AMGParseSection.h
//  parseApp
//
//  Created by Alan Morales on 1/9/15.
//  Copyright (c) 2015 Facebook Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMGParseSample.h"

@interface AMGParseSection : NSObject

@property (nonatomic, copy) NSString *name;
- (NSArray *) samples;
- (instancetype)initWithName:(NSString *)sectionName;
- (void)addSample:(AMGParseSample *)sampleWrapper;

@end
