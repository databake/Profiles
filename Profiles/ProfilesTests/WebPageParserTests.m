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

@interface WebPageParserTests : XCTestCase<GBSpecificWebPageParserDelegate>

@property (strong, nonatomic) GBSpecificWebPageParser *sut;
@property (strong, nonatomic) GBCoreData *persistenceController;
@property (strong, nonatomic) NSManagedObjectContext *localContext;

@property (assign, nonatomic) BOOL delegateCallParsedBatch;
@property (assign, nonatomic) BOOL delegateCallCompleteWithBatch;
@property (assign, nonatomic) NSUInteger profileCount;

@property (copy, nonatomic) NSData *fullWebPageData;

@end

@implementation WebPageParserTests

- (NSData *)fullWebPageData
{
    if (!_fullWebPageData) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"whoswho" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
        _fullWebPageData = [NSData dataWithContentsOfURL:url];
    }
    return _fullWebPageData;
}

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
    [self.sut setDelegate:self];
    [self.sut startParsingInContext:self.persistenceController.context withData:self.fullWebPageData];
}

- (void)tearDown
{
    self.fullWebPageData = nil;
    self.sut = nil;
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

#pragma mark - delegate tests

- (void)testThatDelegateIsCalled
{
    XCTAssertTrue(self.delegateCallParsedBatch, @"The delegate was not called");
    XCTAssertTrue(self.delegateCallCompleteWithBatch, @"The delegate was not called");
}

- (void)testThatParsingFindsSomeProfiles
{
    XCTAssertTrue(self.profileCount == 40, @"The Parser found no profiles");
}

#pragma mark - delegate methods

- (void)parser:(GBSpecificWebPageParser *)parser didParseBatch:(NSArray *)batch
{
    self.delegateCallParsedBatch = YES;
    self.profileCount += batch.count;
}

- (void)parser:(GBSpecificWebPageParser *)parser didCompleteWithBatch:(NSArray *)batch
{
    self.delegateCallCompleteWithBatch = YES;
    self.profileCount += batch.count;
}

@end
