//
//  NSManagedObject+GBAdditions.h
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (GBAdditions)

+ (NSString *)GBCoreDataAdditionsEntityName;
+ (instancetype)GBCoreDataAdditionsInsertNewObjectIntoContext:(NSManagedObjectContext *)context;

@end
