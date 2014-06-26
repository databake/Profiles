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

- (BOOL)isEqualToProfile:(GBProfile *)profile
{
    if (!profile) {
        return NO;
    }
    
    BOOL haveEqualURLs = (!self.url && !profile.url) || [self.url isEqualToString:profile.url];
    
    return haveEqualURLs;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[GBProfile class]]) {
        return NO;
    }
    
    return [self isEqualToProfile:(GBProfile *)object];
}

- (NSUInteger)hash
{
    return [self.url hash];
}

@end
