//
//  GBMasterViewController.h
//  Profiles
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class GBDetailViewController;
@class GBFetchedResultsTableViewDataSource;

@interface GBMasterViewController : UITableViewController

@property (strong, nonatomic) GBDetailViewController *detailViewController;
- (NSFetchedResultsController *)fetchedResultsController;
@end
