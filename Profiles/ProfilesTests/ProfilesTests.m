//
//  ProfilesTests.m
//  ProfilesTests
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GBMasterViewController.h"
#import "GBFetchedResultsTableViewDataSource.h"

@interface ProfilesTests : XCTestCase

@property (strong, nonatomic) GBMasterViewController *vc;

@end

@implementation ProfilesTests

- (void)setUp
{
    [super setUp];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    self.vc = [storyBoard instantiateViewControllerWithIdentifier:@"MasterViewController"];
}

- (void)tearDown
{
    self.vc = nil;
    [super tearDown];
}

#pragma mark - View Loading Tests

- (void)testThatViewLoads
{
    XCTAssertNotNil(self.vc.view, @"View not initiated properly");
}

-(void)testThatTableViewLoads
{
    XCTAssertNotNil(self.vc.tableView, @"TableView not initiated");
}

- (void)testThatControllerConformsToGBFetchedResultsTableViewDataSourceDelegate
{
    XCTAssertTrue([self.vc conformsToProtocol:@protocol(GBFetchedResultsTableViewDataSourceDelegate) ], @"View does not conform to GBFetchedResultsTableViewDataSourceDelegate protocol"); 
}

- (void)testThatTheCorrectNumberOfObjectsIsFetched
{
    NSUInteger expectedObjects = 40;
    NSUInteger actualObjects = [[self.vc.fetchedResultsController fetchedObjects] count];
    XCTAssertEqual(expectedObjects, actualObjects, @"FetchedResultsControllwe should have %d objects, but has %d", expectedObjects, actualObjects);
}

#pragma mark - TableView

- (void)testThatViewConformsToUITableViewDataSource
{
    XCTAssertTrue([self.vc conformsToProtocol:@protocol(UITableViewDataSource) ], @"View does not conform to UITableView datasource protocol");
}

- (void)testThatTableViewHasDataSource
{
    XCTAssertNotNil(self.vc.tableView.dataSource, @"Table datasource cannot be nil");
}

- (void)testThatViewConformsToUITableViewDelegate
{
    XCTAssertTrue([self.vc conformsToProtocol:@protocol(UITableViewDelegate) ], @"View does not conform to UITableView delegate protocol");
}

- (void)testTableViewIsConnectedToDelegate
{
    XCTAssertNotNil(self.vc.tableView.delegate, @"Table delegate cannot be nil");
}

- (void)testTableViewNumberOfRowsInSection
{
    NSInteger expectedRows = 0;
    XCTAssertTrue([self.vc tableView:self.vc.tableView numberOfRowsInSection:0]==expectedRows, @"Table has %ld rows but it should have %ld", (long)[self.vc tableView:self.vc.tableView numberOfRowsInSection:0], (long)expectedRows);
}

- (void)testTableViewHeightForRowAtIndexPath
{
    CGFloat expectedHeight = 59.0;
    CGFloat actualHeight = self.vc.tableView.rowHeight;
    XCTAssertEqual(expectedHeight, actualHeight, @"Cell should have %f height, but they have %f", expectedHeight, actualHeight);
}

#pragma mark - Level 1

- (void)testThatWhenThereIsOnly1ProfileOnTheWebSiteItIsRefectedInTheList
{
}

- (void)testThatRemovingASingleProfileIsReflectedInTheList
{
    
}

- (void)testThatAddingASingleProfileIsReflectedInTheList
{
    
}

#pragma mark - Level 2

#pragma mark - Level 3

- (void)testThatAfterAnInitialLoadTheAppWorksOffLine
{
    
}



- (void)testThatWeCanFetchProfiles
{
    XCTAssertFalse(NO, @"Oh my lord");
}




@end
