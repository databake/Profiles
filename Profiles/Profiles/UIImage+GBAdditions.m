//
//  UIImage+GBAdditions.m
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "UIImage+GBAdditions.h"

@implementation UIImage (GBAdditions)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:original];
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    [original drawInRect:imageView.bounds];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageView.image;
}

+ (UIImage *)roundImageWithImage:(UIImage *)original scaledToFillSize:(CGSize)size
{
    UIImage *scaledImage = [self imageWithImage:original scaledToFillSize:size];
    UIImage *roundedImage = [self imageWithRoundedCornersSize:size.width usingImage:scaledImage];
    return roundedImage;
}

@end
