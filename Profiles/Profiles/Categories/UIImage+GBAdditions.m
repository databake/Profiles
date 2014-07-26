//
//  UIImage+GBAdditions.m
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "UIImage+GBAdditions.h"

@implementation UIImage (GBAdditions)

- (CGRect)rectForCenteredProfileImage:(CGSize)size
{
    CGFloat scale = MAX(size.width/self.size.width, size.height/self.size.height);
    CGFloat width = self.size.width * scale;
    CGFloat height = self.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    return imageRect;
}

- (UIImage *)roundedImageScaledToSize:(CGSize)size
{
    CGRect imageRect = [self rectForCenteredProfileImage:size];
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 1.0);
    CGRect rect = CGRectMake(0, 0, imageRect.size.width, imageRect.size.height);
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [roundedRectanglePath addClip];
    [self drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
