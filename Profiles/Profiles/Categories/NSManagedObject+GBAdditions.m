//
//  NSManagedObject+GBAdditions.m
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "NSManagedObject+GBAdditions.h"

@implementation NSManagedObject (GBAdditions)

+ (NSString *)GBCoreDataAdditionsEntityName
{    
    return NSStringFromClass(self);
}

+ (instancetype)GBCoreDataAdditionsInsertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self GBCoreDataAdditionsEntityName] inManagedObjectContext:context];
}

@end
