//
//  GBParseOperation.m
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//
/*
    Abstract:
 
 */

#import "GBSyncOperation.h"
#import "Profile.h"
#import "TFHpple.h"

static NSUInteger const kSizeOfProfileBatch = 10;
static NSString *const GBWebPageURL = @"http://www.theappbusiness.com/our-%20team";

@interface GBSyncOperation ()

@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSMutableArray *currentParseBatch;
@property (nonatomic) NSMutableArray *latestParseNamesList;

@end

@implementation GBSyncOperation

- (instancetype)initWithData:(NSSet *)parseDataSet sharedPSC:(NSPersistentStoreCoordinator *)psc
{
    self = [super init];
    if (self) {
        _profileData = [parseDataSet copy];
        self.currentParseBatch = [NSMutableArray array];
        self.latestParseNamesList = [NSMutableArray array];
        self.sharedPSC = psc;
    }
    return self;
}

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = ent;
    fetchRequest.propertiesToFetch =  @[@"name", @"url", @"role", @"bio"];
    [fetchRequest setResultType:NSDictionaryResultType];
    return fetchRequest;
}

- (void)addProfilesToList:(NSArray *)profiles
{
    NSFetchRequest *fetchRequest;
    fetchRequest = [self fetchRequest];
    NSError *error = nil;
    Profile *profile = nil;
    
    for (profile in profiles) {
        [self.latestParseNamesList addObject:profile.name];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND url = %@", profile.name, profile.url];
        NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedItems.count == 0) {
            [self.managedObjectContext insertObject:profile];
        } else {
#pragma message "TECH DEBT: Update changed profiles is not feasible without a unique identifier"
        }
    }
    
    [self saveContext:&error];    
}

- (void)saveContext:(NSError **)error_p
{
    if ([self.managedObjectContext hasChanges]) {
        
        if (![self.managedObjectContext save:&(*error_p)]) {
            NSLog(@"Unresolved error %@, %@", *error_p, [*error_p userInfo]);
            abort();
        }
    }
}

#pragma message "TECH DEBT: Usually the responsibility for identifing deleted entites, is with the server"
- (void)removeMissingProfiles
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.resultType = NSManagedObjectResultType;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"NOT (name in %@)", self.latestParseNamesList];
    NSError *error = nil;
    NSArray *profilesToDelete = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Profile *profile in profilesToDelete) {
        [self.managedObjectContext deleteObject:profile];
    }
    
    [self saveContext:&error];
}

- (void)main
{
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;

    [self parseWebPage];
    
    if ([self.currentParseBatch count] > 0) {
        [self addProfilesToList:self.currentParseBatch];
    }
    
    [self removeMissingProfiles];
}

- (NSArray *)fetchProfileNodes
{
    NSURL *profilesUrl = [NSURL URLWithString:GBWebPageURL];
    NSData *profilessHtmlData = [NSData dataWithContentsOfURL:profilesUrl];
    TFHpple *profilesParser = [TFHpple hppleWithHTMLData:profilessHtmlData];
    NSString *profilesXpathQueryString = @"//div[@class='col col2']";
    NSArray *profilesNodes = [profilesParser searchWithXPathQuery:profilesXpathQueryString];
    return profilesNodes;
}

#pragma message "TECH DEBT: In a real app, this method would be replaced with a more robust solution"
- (void)parseWebPage
{
    NSArray *profilesNodes = [self fetchProfileNodes];

    for (TFHppleElement *element in profilesNodes) {

        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];

        Profile *profile = [[Profile alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];

        TFHppleElement *urlElement = [element.children objectAtIndex:0];
        profile.url = [[urlElement firstChild] objectForKey:@"src"];
        
        TFHppleElement *nameElement = [element.children objectAtIndex:1];
        profile.name = [[nameElement firstChild] content];
        
        TFHppleElement *roleElement = [element.children objectAtIndex:2];
        profile.role = [[roleElement firstChild] content];
        
        TFHppleElement *bioElement = [element.children objectAtIndex:3];
        profile.bio = [[bioElement firstChild] content];
        
        [self.currentParseBatch addObject:profile];
        if ([self.currentParseBatch count] >= kSizeOfProfileBatch) {
            [self addProfilesToList:self.currentParseBatch];
            self.currentParseBatch = [NSMutableArray array];
        }
        
    }
}


@end
