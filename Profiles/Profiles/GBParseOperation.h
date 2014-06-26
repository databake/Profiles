//
//  GBParseOperation.h
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GBParseOperation : NSOperation

@property (copy, readonly) NSSet *profileData;

- (instancetype)initWithData:(NSSet *)parseDataSet sharedPSC:(NSPersistentStoreCoordinator *)psc;


@end
