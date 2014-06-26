//
//  GBProfile.h
//  Profiles
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBProfile : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *role;
@property (copy, nonatomic) NSString *bio;
@property (assign, nonatomic) CGSize imageSize;
@property (copy, nonatomic) NSData *thumbnailImage;

@end
