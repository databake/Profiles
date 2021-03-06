//
//  GBMasterViewController.m
//  Profiles
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "GBMasterViewController.h"
#import "GBDetailViewController.h"
#import "GBCoreData.h"
#import "GBFetchedResultsTableViewDataSource.h"
#import "NSManagedObject+GBAdditions.h"
#import "Profile.h"
#import "GBSyncOperation.h"
#import "UIImage+Download.h"
#import "UIImage+GBAdditions.h"
#import "GBProfileTableViewCell.h"

static inline NSString *BBRuntimeEnvironment(NSString *varName)
{
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    return [environment objectForKey:varName];
}

@interface GBMasterViewController () <GBFetchedResultsTableViewDataSourceDelegate>

@property (strong, nonatomic) GBCoreData *persistenceController;
@property (nonatomic) NSOperationQueue *parseQueue;
@property (strong, nonatomic) GBFetchedResultsTableViewDataSource *tableDataSource;
@property (strong, nonatomic) UIBarButtonItem *activityIndicator;

@end

@implementation GBMasterViewController


- (BOOL)isRunningUnitTests
{
    return ([BBRuntimeEnvironment(@"TARGET") isEqualToString:@"TEST"]);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)startObservingManagedObjectContext
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
}

- (void)activateParseOperation
{
    GBSyncOperation *parseOperation ;
    parseOperation = [[GBSyncOperation alloc] initWithData:nil
                                                 sharedPSC:self.persistenceController.context.persistentStoreCoordinator];
    self.parseQueue = [NSOperationQueue new];
    [self.parseQueue addOperation:parseOperation];
    [self.parseQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];
}

- (void)presentActivityIndicator
{
    UIActivityIndicatorView *activityIndicator =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
	_activityIndicator = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	self.navigationItem.rightBarButtonItem = self.activityIndicator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (![self isRunningUnitTests]) {
        self.detailViewController = (GBDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
        [self presentActivityIndicator];
        [self setupTableDataSource];
        [self startObservingManagedObjectContext];
        [self activateParseOperation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - FetchedResultsController

- (void)setupTableDataSource
{
    NSAssert(self.persistenceController.context, @"Did you forget to set managed object context?");
    self.tableDataSource = [[GBFetchedResultsTableViewDataSource alloc] initWithTableView:self.tableView
                                                                 fetchedResultsController:[self fetchedResultsController]];
    self.tableDataSource.delegate = self;
    self.tableDataSource.reuseIdentifier = @"Cell";
    self.tableView.dataSource = self.tableDataSource;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Profile GBCoreDataAdditionsEntityName]];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.persistenceController.context sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![fetchedResultsController performFetch:&error]) {
	    NSAssert2(NO, @"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    return fetchedResultsController;
}

#pragma mark - GBFetchedResultsTableViewDataSourceDelegate

- (void)dataSource:(GBFetchedResultsTableViewDataSource *)dataSource
     configureCell:(id)cell
        withObject:(id)object {
    
    GBProfileTableViewCell *tableCell = (GBProfileTableViewCell *)cell;
    Profile *profile = (Profile *)object;
    tableCell.nameLabel.text = profile.name;
    tableCell.roleLabel.text = profile.role;
    tableCell.bioLabel.text = profile.bio;

    UIImageView *imageView = tableCell.profileImageView;

    if (!profile.profileImage && profile.url) {
        __weak typeof(self) weakSelf = self;
        [UIImage loadFromURL:[NSURL URLWithString:profile.url] callback:^(UIImage *image) {
            profile.profileImage = UIImagePNGRepresentation(image);
            [weakSelf save];
        }];
    } else {
        imageView.image = [UIImage imageWithData:profile.profileImage];
    }
}

- (void)dataSource:(GBFetchedResultsTableViewDataSource *)dataSource
      deleteObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath {
    
    [self.persistenceController.context deleteObject:object];
    [self save];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Profile *profile = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = profile.name;
    }
}

#pragma mark - Saving

- (void)save
{
    __weak typeof(self) weakSelf = self;
    [self.persistenceController saveContextAndWait:NO completion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            NSAssert1(NO, @"ERROR: Data could not be saved %@", [error localizedDescription]);
            [strongSelf presentFatalErrorAlertView];
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Profile *profile = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:profile.name];
    }
}

- (void)presentFatalErrorAlertView
{
    NSString *title;
    title = NSLocalizedString([NSString stringWithFormat:@"Sorry"], nil);
    NSString *message;
    message = NSLocalizedString([NSString stringWithFormat:@"There has been a fatal error. Please close the app."], nil);
    NSString *buttonTitle;
    buttonTitle = NSLocalizedString([NSString stringWithFormat:@"OK"], nil);
    
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:buttonTitle
                      otherButtonTitles:nil] show];
}

#pragma mark - Coredata stack

- (GBCoreData *)persistenceController
{
    if (_persistenceController == nil) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Profiles.sqlite"];
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

- (void)updateMainContext:(NSNotification *)notification
{
    assert([NSThread isMainThread]);
    [self.persistenceController.context mergeChangesFromContextDidSaveNotification:notification];
}

- (void)mergeChanges:(NSNotification *)notification
{
    if (notification.object != self.persistenceController.context) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

- (void)hideActivityIndicator
{
    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)self.activityIndicator.customView;
    [indicatorView stopAnimating];
    self.navigationItem.rightBarButtonItem = nil;
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



@end
