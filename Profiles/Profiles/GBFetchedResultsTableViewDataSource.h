//
//  GBFetchedResultsTableViewDataSource.h
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GBFetchedResultsTableViewDataSource;

@protocol GBFetchedResultsTableViewDataSourceDelegate <NSObject>

- (void)dataSource:(GBFetchedResultsTableViewDataSource *)dataSource configureCell:(id)cell withObject:(id)object;

- (void)dataSource:(GBFetchedResultsTableViewDataSource *)dataSource deleteObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@end


@interface GBFetchedResultsTableViewDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

/**
 The `NSFetchedResultsController` to be used by the data source.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/**
 The reuse identifier of the cell being modified by the data source.
 */
@property (nonatomic, copy) NSString *reuseIdentifier;

/**
 A Boolean value that determines whether the receiver will update automatically when the model changes.
 */
@property (nonatomic) BOOL paused;

/**
 The object that acts as the delegate of the receiving data source.
 */
@property (nonatomic, weak) id<GBFetchedResultsTableViewDataSourceDelegate> delegate;

/**
 Returns a fetched results table data source initialized with the given arguments.
 
 @param tableView The table view using this data source.
 @param fetchedResultsController The fetched results controller the data source should use.
 
 @return The newly-initialized table data source.
 */
- (id)initWithTableView:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

/**
 Returns the currently selected item from the table.
 
 @return The selected item. If multiple items are selected it returns the first item.
 */
- (id)selectedItem;

/**
 Asks the data source to return the number of rows in the section.
 
 @param section An index number identifying a section for the internally managed table view.
 
 @return The number of rows in `section`. If section doesn't exist returns 0.
 */
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;

/**
 Asks the data source to return the total number of rows in all sections.
 
 @return Total number of rows.
 */
- (NSUInteger)numberOfRowsInAllSections;

/**
 Returns the item object at the specified index path.
 
 @param path The index path that specifies the section and row of the cell.
 
 @return The item object at the corresponding index path or `nil` if the index path is out of range.
 */
- (id)itemAtIndexPath:(NSIndexPath *)path;

/**
 Returns the index path of a given object.
 
 @param object An object in the receiver's fetch results.
 
 @return The index path of `object` in the receiver's fetch results, or nil if `object` could not be found.
 */
- (NSIndexPath *)indexPathForObject:(id)object;

@end
