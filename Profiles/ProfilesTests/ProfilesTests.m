//
//  ProfilesTests.m
//  ProfilesTests
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GBDataAccessManager.h"

@interface ProfilesTests : XCTestCase

@end

@implementation ProfilesTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatWeCanFetchProfiles
{
    [[GBDataAccessManager manager] fetchProfileListWithCompletionHandler:^(NSArray *profiles, NSError *error) {
        XCTAssertNil(error, @"Should not error");
        XCTAssertNotNil(profiles, @"The profiles array should not be nil");
    }];
    
}


@end
