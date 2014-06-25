//
//  GBDataAccessManager.h
//  Profiles
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBDataAccessManager : NSObject

+ (GBDataAccessManager *)manager;

/**
 *  Use this method to scrap the web page and extract Employee Profiles.
 *
 *  @param Callback that returns an array of profiles and/or an error
 */
- (void)fetchProfileListWithCompletionHandler:(void(^)(NSArray *profiles, NSError *error))handler;


- (void)fetchProfileImageForURL:(NSString *)url block:(void(^)(UIImage *image))block;

@end
