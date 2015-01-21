//
//  AMGParseSample.h
//  parseApp
//
//  Created by Alan Morales on 1/9/15.
//  Copyright (c) 2015 Facebook Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMGParseSample : NSObject

@property (nonatomic, copy) NSString *sampleName;
- (instancetype)initWithName:(NSString *)name;
- (void)execute:(NSInteger)sampleIndex;

@end
