//
//  UIImage+GBAdditions.h
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GBAdditions)

+ (UIImage *)roundImageWithImage:(UIImage *)original scaledToFillSize:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;
+ (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original;


@end
