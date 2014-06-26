//
//  GBCoreData.h
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const GBPSCDidInitialize;

@interface GBCoreData : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

- (instancetype)initWithStoreURL:(NSURL *)storeURL model:(NSManagedObjectModel *)model;
- (instancetype)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL;

- (NSManagedObjectContext *)newPrivateChildContext;

- (NSManagedObjectContext *)newChildContext;

- (void)saveContextAndWait:(BOOL)wait completion:(void (^)(NSError *error))completion;

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(void (^)(NSError *error))errorBlock;

- (void)deleteObject:(NSManagedObject *)object saveContextAndWait:(BOOL)saveAndWait completion:(void (^)(NSError *error))completion;

@end
