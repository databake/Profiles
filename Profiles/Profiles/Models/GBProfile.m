//
//  GBProfile.m
//  Profiles
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "GBProfile.h"

@implementation GBProfile


- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, %@>",
            [self class],
            self,
            @{
              @"Name" : self.name,
              @"ProfileImageURL": self.url,
              @"Role": self.role
             }];
}


@end
