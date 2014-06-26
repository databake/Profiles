//
//  GBParseOperation.h
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GBSyncOperation : NSOperation

@property (copy, readonly) NSSet *profileData;

/**
 *  The designated initializer (NS_DEGISNATED_INITILIZER) for the sync operation
 *
 *  @param parseDataSet Curently unused, should be used in a real app
 *  @param psc          The persistentStoreCoordintor used in the sync
 *
 *  @return An initialized Sync Operation
 */
- (instancetype)initWithData:(NSSet *)parseDataSet sharedPSC:(NSPersistentStoreCoordinator *)psc;

@end
