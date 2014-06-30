//
//  UIImage+Download.h
//  HTMLParsing
//
//  Created by Graham Barker on 23/06/2014.
//  Copyright (c) 2014 Swipe Stack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Download)

+ (void)loadFromURL:(NSURL*)url callback:(void (^)(UIImage *image))callback;

@end
