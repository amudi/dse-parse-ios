//
//  AMGParseSection.m
//  parseApp
//
//  Created by Alan Morales on 1/9/15.
//  Copyright (c) 2015 Facebook Inc. All rights reserved.
//

#import "AMGParseSection.h"
#import "AMGParseSample.h"

@interface AMGParseSection ()
@property (nonatomic) NSMutableArray *mutableSamples;
@end

@implementation AMGParseSection

static NSMutableArray *sections = nil;

- (instancetype)init {
    return [self initWithName:@"Default Section Name"];
}

- (instancetype)initWithName:(NSString *)sectionName {
    self = [super init];
    
    if (self) {
        _name = sectionName;
        _mutableSamples = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSArray *)samples {
    return _mutableSamples;
}

- (void)addSample:(AMGParseSample *)sampleWrapper {
    [self.mutableSamples addObject:sampleWrapper];
}
@end
