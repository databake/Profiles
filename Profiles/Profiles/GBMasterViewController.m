//
//  GBMasterViewController.m
//  Profiles
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "GBMasterViewController.h"
#import "GBDetailViewController.h"
#import "GBDataAccessManager.h"
#import "GBProfile.h"

@interface GBMasterViewController () {
    NSArray *_objects;
}
@end

@implementation GBMasterViewController

- (void)fetchData
{
    [[GBDataAccessManager manager] fetchProfileListWithCompletionHandler:^(NSArray *profiles, NSError *error) {
        _objects = profiles;
        [self.tableView reloadData];
        
    }];
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self fetchData];
    self.detailViewController = (GBDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    GBProfile *profile = _objects[indexPath.row];
    cell.textLabel.text = profile.name;
    cell.detailTextLabel.text = profile.role;
    [[GBDataAccessManager manager] fetchProfileImageForURL:profile.url block:^(UIImage *image) {
        cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width /2 ;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.image = image;
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GBProfile *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object.description];
    }
}

@end
