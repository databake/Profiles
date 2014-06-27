//
//  WebPageParserTests.m
//  Profiles
//
//  Created by Graham Barker on 27/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GBSpecificWebPageParser.h"
#import "GBCoreData.h"

@interface WebPageParserTests : XCTestCase

@property (strong, nonatomic) GBSpecificWebPageParser *sut;
@property (strong, nonatomic) GBCoreData *persistenceController;
@property (strong, nonatomic) NSManagedObjectContext *localContext;

@end

@implementation WebPageParserTests

- (GBCoreData *)persistenceController
{
    if (_persistenceController == nil) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TESTCoreData.sqlite"];
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GBProfilesDataModel" withExtension:@"momd"];
        _persistenceController = [[GBCoreData alloc] initWithStoreURL:storeURL modelURL:modelURL];
        if (_persistenceController == nil) {
            NSAssert(NO, @"ERROR: Persistence controller could not be created");
        }
    }
    return _persistenceController;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)setUp
{
    [super setUp];
    _localContext = self.persistenceController.context;
    self.sut = [[GBSpecificWebPageParser alloc] initWithBatchSize:10 forURL:[NSURL URLWithString:@"http://www.theappbusiness.com/our-%20team"] context:self.localContext];
}

- (void)tearDown
{
    //remove the test DB
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Setup

- (void)testThatItLoads
{
    XCTAssertNotNil(self.sut, @"View not initiated properly");
}

- (void)testThatNoURLThrows
{
    XCTAssertThrows([[GBSpecificWebPageParser alloc] initWithBatchSize:10 forURL:[NSURL URLWithString:@""] context:self.localContext], @"Didn't throw");
}

- (void)testThatLessThan1BatchSizeThrows
{
    XCTAssertThrows([[GBSpecificWebPageParser alloc] initWithBatchSize:NO forURL:[NSURL URLWithString:@"gobbledegook"] context:self.localContext], @"Didn't throw");
}

- (void)testThatLessMissingContextThrows
{
    XCTAssertThrows([[GBSpecificWebPageParser alloc] initWithBatchSize:NO forURL:[NSURL URLWithString:@"gobbledegook"] context:nil], @"Didn't throw");
}

#pragma mark - delegate



@end
