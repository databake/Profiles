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
#import "Profile.h"

@interface WebPageParserTests : XCTestCase<GBSpecificWebPageParserDelegate>

@property (strong, nonatomic) GBSpecificWebPageParser *sut;
@property (strong, nonatomic) GBCoreData *persistenceController;
@property (strong, nonatomic) NSManagedObjectContext *localContext;

@property (assign, nonatomic) BOOL delegateCallParsedBatch;
@property (assign, nonatomic) BOOL delegateCallCompleteWithBatch;
@property (assign, nonatomic) NSUInteger profileCount;

@property (strong, nonatomic) NSMutableArray *profileData;

@property (copy, nonatomic) NSData *fortyWebPageData;
@property (copy, nonatomic) NSData *twentyOneWebPageData;
@property (copy, nonatomic) NSData *nineWebPageData;

@end

@implementation WebPageParserTests

#pragma mark -

- (NSData *)fortyWebPageData
{
    if (!_fortyWebPageData) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"whoswho" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
        _fortyWebPageData = [NSData dataWithContentsOfURL:url];
    }
    return _fortyWebPageData;
}

- (NSData *)twentyOneWebPageData
{
    if (!_twentyOneWebPageData) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"whoswho21" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
        _twentyOneWebPageData = [NSData dataWithContentsOfURL:url];
    }
    return _twentyOneWebPageData;
    
}

- (NSData *)nineWebPageData
{
    if (!_nineWebPageData) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"whoswho9" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
        _nineWebPageData = [NSData dataWithContentsOfURL:url];
    }
    return _nineWebPageData;
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

- (BOOL)waitForCompletion:(NSTimeInterval)timeOutSecs flag:(BOOL)flag
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeOutSecs];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0) {
            break;
        }
    } while (!flag) ;
    
    return flag;
}

#pragma mark - Delegate Methods

- (void)parser:(GBSpecificWebPageParser *)parser didParseBatch:(NSArray *)batch
{
    self.delegateCallParsedBatch = YES;
    self.profileCount += batch.count;
    [self.profileData addObjectsFromArray:batch];
}

- (void)parser:(GBSpecificWebPageParser *)parser didCompleteWithBatch:(NSArray *)batch
{
    self.delegateCallCompleteWithBatch = YES;
    self.profileCount += batch.count;
    [self.profileData addObjectsFromArray:batch];
}

#pragma mark - Test

- (void)setUp
{
    [super setUp];
    _profileData = [NSMutableArray array];
    _localContext = self.persistenceController.context;
    self.sut = [[GBSpecificWebPageParser alloc] initWithBatchSize:10 forURL:[NSURL URLWithString:@"http://www.theappbusiness.com/our-%20team"] context:self.localContext];
    [self.sut setDelegate:self];
}

- (void)tearDown
{
    self.fortyWebPageData = nil;
    self.sut = nil;
    
    NSPersistentStoreCoordinator *psc = self.persistenceController.context.persistentStoreCoordinator;
    NSArray *stores = [psc persistentStores];
    
    for(NSPersistentStore *store in stores) {
        [psc removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    
    psc = nil;
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

- (void)testThatMissingContextThrows
{
    XCTAssertThrows([[GBSpecificWebPageParser alloc] initWithBatchSize:NO forURL:[NSURL URLWithString:@"gobbledegook"] context:nil], @"Didn't throw");
}

#pragma mark - Delegate Tests

- (void)testThatDelegateParsedBatchMethodIsCalled
{
    [self.sut startParsingInContext:self.persistenceController.context withData:self.fortyWebPageData];
    XCTAssertTrue([self waitForCompletion:2 flag:self.delegateCallParsedBatch], @"The delegate method didParseBatch was not called");
}

- (void)testThatDelegateCompleteWithBatchIsCalled
{
    [self.sut startParsingInContext:self.persistenceController.context withData:self.fortyWebPageData];    
    XCTAssertTrue([self waitForCompletion:2 flag:self.delegateCallCompleteWithBatch], @"The delegate methoid didCompleteWithBatch was not called");
}

- (void)testThatParsingExtracts40Profiles
{
    [self.sut startParsingInContext:self.persistenceController.context withData:self.fortyWebPageData];
    XCTAssertTrue(self.profileCount == 40, @"The Parser extracted %u profiles, expetected 40", self.profileCount);
}

- (void)testThatParsingExtractsNoProfiles
{
    [self.sut startParsingInContext:self.persistenceController.context withData:nil];
    XCTAssertTrue(self.profileCount == 0, @"The Parser extracted %u profiles, expetected 0", self.profileCount);
}

- (void)testThatParsingExtracts21Profiles
{
    [self.sut startParsingInContext:self.persistenceController.context withData:self.twentyOneWebPageData];
    XCTAssertTrue(self.profileCount == 21, @"The Parser extracted %u profiles, expetected 21", self.profileCount);
}

- (void)testThatParsingExtracts9Profiles
{
    [self.sut startParsingInContext:self.persistenceController.context withData:self.nineWebPageData];
    XCTAssertTrue(self.profileCount == 9, @"The Parser extracted %u profiles, expetected 9", self.profileCount);
}

- (void)testThatParserExtractsNames
{
    [self.sut startParsingInContext:self.persistenceController.context withData:self.nineWebPageData];
    Profile *firstProfile = self.profileData.firstObject;
    XCTAssertNotNil(firstProfile.name, @"The first profile is missing the name");
    Profile *lastProfile = self.profileData.lastObject;
    XCTAssertNotNil(lastProfile.name, @"The last profile is missing the name");
}

@end
