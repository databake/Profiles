//
//  GBSyncOperationTests.m
//  Profiles
//
//  Created by Graham Barker on 30/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GBSyncOperation.h"
#import "GBCoreData.h"

@interface GBSyncOperationTests : XCTestCase

@property (nonatomic) NSOperationQueue *parseQueue;
@property (strong, nonatomic) GBCoreData *persistenceController;

@property (copy, nonatomic) NSData *fortyWebPageData;
@property (copy, nonatomic) NSData *twentyOneWebPageData;
@property (copy, nonatomic) NSData *nineWebPageData;
@property (copy, nonatomic) NSData *nineAlteredWebPageData;

@property (assign, nonatomic) BOOL operationDidComplete;

@end

@implementation GBSyncOperationTests

#pragma mark -

- (GBCoreData *)persistenceController
{
    if (_persistenceController == nil) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TESTSync.sqlite"];
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

- (void)activateParseOperationWithProfileData:(NSData *)profileData;
{
    GBSyncOperation *parseOperation ;
    parseOperation = [[GBSyncOperation alloc] initWithData:profileData
                                                 sharedPSC:self.persistenceController.context.persistentStoreCoordinator];
    self.parseQueue = [NSOperationQueue new];
    [self.parseQueue addOperation:parseOperation];
    [self.parseQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.parseQueue && [keyPath isEqualToString:@"operationCount"]) {
        if (self.parseQueue.operationCount == 0) {
            [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)hideActivityIndicator
{
    self.operationDidComplete = YES;
}

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

- (NSData *)nineAlteredWebPageData
{
    if (!_nineAlteredWebPageData) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"whoswho9altered" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
        _nineAlteredWebPageData = [NSData dataWithContentsOfURL:url];
    }
    return _nineAlteredWebPageData;
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

- (NSUInteger)getProfleCount
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.persistenceController.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entityDescription;
    request.includesSubentities = NO;
    
    NSError *error;
    NSUInteger profileCount = [self.persistenceController.context countForFetchRequest:request error:&error];
    return profileCount;
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Tests

- (void)testThatOperationQueueInstantiates
{
    GBSyncOperation *parseOperation ;
    parseOperation = [[GBSyncOperation alloc] initWithData:nil
                                                 sharedPSC:self.persistenceController.context.persistentStoreCoordinator];
    XCTAssertNotNil(parseOperation, @"The parse operation cannot be instantiated");
}

- (void)testThat40ProfilesArePersisted
{
    [self activateParseOperationWithProfileData:self.fortyWebPageData];
    XCTAssertFalse([self waitForCompletion:1 flag:self.operationDidComplete], @"The Parse operation did not complete in time");
    NSUInteger profileCount = [self getProfleCount];
    XCTAssertTrue(profileCount == 40, @"Expected 40 but got %lu", (unsigned long)profileCount);
}

- (void)testThatMissingProfilesAreDeleted
{
    [self activateParseOperationWithProfileData:self.nineWebPageData];
    XCTAssertFalse([self waitForCompletion:1 flag:self.operationDidComplete], @"The Parse operation did not complete in time");
    NSUInteger profileCount = [self getProfleCount];
    XCTAssertTrue(profileCount == 9, @"Expected 9 but got %lu", (unsigned long)profileCount);
}

- (void)testThatAdditionalProfilesAreAdded
{
    [self activateParseOperationWithProfileData:self.twentyOneWebPageData];
    XCTAssertFalse([self waitForCompletion:1 flag:self.operationDidComplete], @"The Parse operation did not complete in time");
    NSUInteger profileCount = [self getProfleCount];
    XCTAssertTrue(profileCount == 21, @"Expected 21 but got %lu", (unsigned long)profileCount);
}

- (void)testThatChangesInTheWebPageAreRefelectedInTheProfiles
{
    [self activateParseOperationWithProfileData:self.nineAlteredWebPageData];
    XCTAssertFalse([self waitForCompletion:1 flag:self.operationDidComplete], @"The Parse operationd id not complete in time");
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.persistenceController.context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == [c] %@", @"Graham Barker"];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.predicate = predicate;
    request.entity = entityDescription;
    request.includesSubentities = NO;
    
    NSError *error;
    NSUInteger profileCountMatchingGraham = [self.persistenceController.context countForFetchRequest:request error:&error];
    XCTAssertTrue(profileCountMatchingGraham == 1, @"Expected 1 but got %lu", (unsigned long)profileCountMatchingGraham);
    NSUInteger profileCount = [self getProfleCount];
    XCTAssertTrue(profileCount == 9, @"Expected 9 but got %lu", (unsigned long)profileCount);
}

@end
