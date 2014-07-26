//
//  UIImage+Download.m
//  HTMLParsing
//
//  Created by Graham Barker on 23/06/2014.
//  Copyright (c) 2014 Swipe Stack Ltd. All rights reserved.
//

#import "UIImage+Download.h"
#import "UIImage+GBAdditions.h"

@implementation UIImage (Download)

+ (void)loadFromURL:(NSURL*)url callback:(void (^)(UIImage *image))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        __block UIImage *roundedSizedImage = [image roundedImageScaledToSize:CGSizeMake(60, 60)];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(roundedSizedImage);
        });
    });
}


@end
