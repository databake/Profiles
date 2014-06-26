//
//  GBFetchedResultsTableViewDataSource.m
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "GBFetchedResultsTableViewDataSource.h"

@interface GBFetchedResultsTableViewDataSource ()

@property (weak, nonatomic) UITableView *tableView;

@end

@implementation GBFetchedResultsTableViewDataSource

- (id)initWithTableView:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    NSParameterAssert(tableView);
    NSParameterAssert(fetchedResultsController);
    
    self = [super init];
    if (self) {
        _tableView = tableView;
        _fetchedResultsController = fetchedResultsController;
        [self setupFetchedResultsController:fetchedResultsController];
    }
    return self;
}

- (void)setupFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    fetchedResultsController.delegate = self;
    BOOL fetchSuccess = [fetchedResultsController performFetch:NULL];
    NSAssert(fetchSuccess, @"Fetch request does not include sort descriptor that uses the section name.");
    [self.tableView reloadData];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath);
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController{
    
    if (_fetchedResultsController != fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        [self setupFetchedResultsController:fetchedResultsController];
    }
}

- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    if (paused) {
        self.fetchedResultsController.delegate = nil;
    } else {
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:NULL];
        [self.tableView reloadData];
    }
}

- (id)selectedItem
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    return indexPath ? [self itemAtIndexPath:indexPath] : nil;
}

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section
{
    if (section < [self.fetchedResultsController.sections count]) {
        return [self.fetchedResultsController.sections[section] numberOfObjects];
    }
    
    return 0;
}

- (NSUInteger)numberOfRowsInAllSections
{
    NSUInteger totalRows = 0;
    NSUInteger totalSections = [self.fetchedResultsController.sections count];
    
    for (NSUInteger section = 0; section < totalSections; section++) {
        totalRows = totalRows + [self numberOfRowsInSection:section];
    }
    
    return totalRows;
}

- (NSIndexPath *)indexPathForObject:(id)object
{
    NSParameterAssert(object);
    return [self.fetchedResultsController indexPathForObject:object];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self numberOfRowsInSection:(NSUInteger)section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier forIndexPath:indexPath];
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate dataSource:self configureCell:cell withObject:object];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            [self.delegate dataSource:self deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]
                          atIndexPath:indexPath];
            break;
        }
            
        default:
            NSAssert(NO, @"Missing UITableViewCellEditingStyle case");
            break;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
            
        default:
            NSAssert(NO, @"Missing NSFechedResultsChange case");
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        default:
            NSAssert(NO, @"Missing NSFechedResultsChange case");
            break;
    }
}


@end
