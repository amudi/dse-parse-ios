//
//  AMGParseSampleSource.h
//  parseApp
//
//  Created by Alan Morales on 1/12/15.
//  Copyright (c) 2015 Facebook Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMGParseSampleSource : NSObject

typedef enum {
    SIGN_UP,
    LOGIN,
    ANON_LOGIN,
    VC_LOGIN,
    FB_LOGIN,
    TWITTER_LOGIN,
    SAVE_INSTALLATION,
    ANALYTICS_TEST,
    ACL_NEW_FIELD,
    ACL_EXISTING_FIELD,
    ACL_TEST_QUERY,
    SAVE_USER_PROPERTY,
    REFRESH_USER,
    QUERY_FIRST_OBJECT,
    QUERY_FIRST_OBJECT_USING_CLASS,
    QUERY_COMPOUND,
    LDS_PINNING,
    CLOUD_CODE_POINTER_TEST,
    BC_AD_DATES_SAVING,
    BC_AD_DATES_RETRIEVING
} ParseSampleEnum;

+ (instancetype)sharedSource;
- (NSArray *)sections;
- (void)executeSample:(NSInteger)sampleIndex;
@end
