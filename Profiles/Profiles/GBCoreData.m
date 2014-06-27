//
//  GBCoreData.m
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "GBCoreData.h"

NSString *const GBPSCDidInitialize = @"GBPersistenceControllerDidInitialize";

@interface GBCoreData ()

@property (strong, nonatomic, readwrite) NSManagedObjectContext *context;
@property (strong, nonatomic) NSManagedObjectContext *writerContext;
@property (strong, nonatomic) NSURL *storeURL;
@property (strong, nonatomic) NSManagedObjectModel *model;

@end

@implementation GBCoreData

- (instancetype)initWithStoreURL:(NSURL *)storeURL model:(NSManagedObjectModel *)model
{
    
    self = [super init];
    if (self) {
        _storeURL = storeURL;
        _model = model;
        if (![self setupCoreDataStack]) {
            return nil;
        }
    }
    
    return self;
}

- (instancetype)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL
{
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSAssert(model, @"ERROR: NSManagedObjectModel is nil");
    
    return [self initWithStoreURL:storeURL model:model];
}

- (BOOL)setupCoreDataStack
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    NSAssert(persistentStoreCoordinator, @"ERROR: NSPersistentStoreCoordinator is nil");
    
    NSDictionary *persistentStoreOptions = @{
                                             NSInferMappingModelAutomaticallyOption:@YES,
                                             NSMigratePersistentStoresAutomaticallyOption:@YES
                                             };
    NSError *persistentStoreError;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                  configuration:nil
                                                                                            URL:self.storeURL
                                                                                        options:persistentStoreOptions
                                                                                          error:&persistentStoreError];
    if (persistentStore == nil) {
        
        NSError *removeSQLiteFilesError = nil;
        if ([self removeSQLiteFilesAtStoreURL:self.storeURL error:&removeSQLiteFilesError]) {
            
            persistentStoreError = nil;
            persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                       configuration:nil
                                                                                 URL:self.storeURL
                                                                             options:persistentStoreOptions
                                                                               error:&persistentStoreError];
        } else {
            
            NSAssert(NO, @"ERROR: Could not remove SQLite files");
            return NO;
        }
        
        if (persistentStore == nil) {
            
            NSAssert2(NO, @"ERROR: NSPersistentStore is nil: %@\n%@", [persistentStoreError localizedDescription], [persistentStoreError userInfo]);
            return NO;
        }
    }
    
    self.writerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.writerContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    if (self.writerContext == nil) {
        
        NSAssert(NO, @"ERROR: NSManagedObjectContext is nil");
        return NO;
    }
    
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.context setParentContext:self.writerContext];
    if (self.context == nil) {
        
        NSAssert(NO, @"ERROR: NSManagedObjectContext is nil");
        return NO;
    }
    
    [self persistenceStackInitialized];
    
    return YES;
}

- (BOOL)removeSQLiteFilesAtStoreURL:(NSURL *)storeURL error:(NSError * __autoreleasing *)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeDirectory = [storeURL URLByDeletingLastPathComponent];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:storeDirectory
                                          includingPropertiesForKeys:nil
                                                             options:0
                                                        errorHandler:nil];
    
    NSString *storeName = [storeURL.lastPathComponent stringByDeletingPathExtension];
    for (NSURL *url in enumerator) {
        
        if (![url.lastPathComponent hasPrefix:storeName]) {
            continue;
        }
        
        NSError *fileManagerError = nil;
        if (![fileManager removeItemAtURL:url error:&fileManagerError]) {
            
            if (error != NULL) {
                *error = fileManagerError;
            }
            
            return NO;
        }
    }
    
    return YES;
}

- (void)saveContextAndWait:(BOOL)wait completion:(void (^)(NSError *error))completion
{
    if (self.context == nil) {
        return;
    }
    
    if ([self.context hasChanges] || [self.writerContext hasChanges]) {
        
        [self.context performBlockAndWait:^{
            
            NSError *mainContextSaveError = nil;
            if (![self.context save:&mainContextSaveError]) {
                
                NSAssert2(NO, @"ERROR: Could not save managed object context -  %@\n%@", [mainContextSaveError localizedDescription], [mainContextSaveError userInfo]);
                if (completion) {
                    completion(mainContextSaveError);
                }
                return;
            }
            
            if ([self.writerContext hasChanges]) {
                
                if (wait) {
                    [self.writerContext performBlockAndWait:[self savePrivateWriterContextBlockWithCompletion:completion]];
                } else {
                    [self.writerContext performBlock:[self savePrivateWriterContextBlockWithCompletion:completion]];
                }
            }
        }];
    }
}

- (void(^)())savePrivateWriterContextBlockWithCompletion:(void (^)(NSError *))completion
{
    void (^savePrivate)(void) = ^{
        
        NSError *privateContextError = nil;
        if (![self.writerContext save:&privateContextError]) {
            
            NSAssert2(NO, @"ERROR: Could not save managed object context - %@\n%@", [privateContextError localizedDescription], [privateContextError userInfo]);
            if (completion) {
                completion(privateContextError);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    };
    
    return savePrivate;
}

#pragma mark - Child NSManagedObjectContext

- (NSManagedObjectContext *)newPrivateChildContext
{
    NSManagedObjectContext *privateChildManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [privateChildManagedObjectContext setParentContext:self.context];
    
    return privateChildManagedObjectContext;
}

- (NSManagedObjectContext *)newChildContext
{
    NSManagedObjectContext *childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [childManagedObjectContext setParentContext:self.context];
    
    return childManagedObjectContext;
}

#pragma mark - NSNotificationCenter

- (void)persistenceStackInitialized
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postPersistenceStackInitializedNotification];
        });
    } else {
        [self postPersistenceStackInitializedNotification];
    }
}

- (void)postPersistenceStackInitializedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GBPSCDidInitialize object:self];
}

#pragma mark - Execute Fetch Request

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(void (^)(NSError *error))errorBlock
{
    NSError *error;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    if(error && errorBlock) {
        errorBlock(error);
        return nil;
    }
    
    return results;
}

#pragma mark - Delete Object

- (void)deleteObject:(NSManagedObject *)object saveContextAndWait:(BOOL)saveAndWait completion:(void (^)(NSError *error))completion
{
    [self.context deleteObject:object];
    [self saveContextAndWait:saveAndWait completion:completion];
}
@end
