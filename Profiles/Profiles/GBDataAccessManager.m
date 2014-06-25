//
//  GBDataAccessManager.m
//  Profiles
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//
//    Abstract:
//
//    A make believe data access layer. In real life this would talk to core data or a server.
//
//

#import "GBDataAccessManager.h"
#import "TFHpple.h"
#import "GBProfile.h"
#import "UIImage+Download.h"

static NSString *const GBWebPageURL = @"http://www.theappbusiness.com/our-%20team";

@interface GBDataAccessManager ()

@property (strong, nonatomic) NSCache *imageCache;

@end

@implementation GBDataAccessManager

+ (GBDataAccessManager *)manager
{
    static GBDataAccessManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GBDataAccessManager alloc] init];
    });
    return manager;
}

- (void)fetchProfileImageForURL:(NSString *)url block:(void(^)(UIImage *image))block
{
    NSParameterAssert(block);
    
    UIImage *profileImage = [self.imageCache objectForKey:url];
    
    if (profileImage) {
        block(profileImage);
    } else {
        
        [UIImage loadFromURL:[NSURL URLWithString:url] callback:^(UIImage *image) {
            if (image) {
                [self.imageCache setObject:image forKey:url];
                block(image);
            }
        }];
    }

}

- (void)fetchProfileListWithCompletionHandler:(void(^)(NSArray *profiles, NSError *error))handler
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [self extractProfileNodes:^(NSArray *nodes) {
            
            NSMutableArray *profiles = [NSMutableArray array];
            NSError *error;
            
            [nodes enumerateObjectsUsingBlock:^(TFHppleElement *element, NSUInteger idx, BOOL *stop) {
                
                GBProfile *profile = [[GBProfile alloc] init];
                [profiles addObject:profile];
                
                TFHppleElement *element0 = [element.children objectAtIndex:0];
                profile.url = [[element0 firstChild] objectForKey:@"src"];
                
                CGFloat height = [[[element0 firstChild] objectForKey:@"height"] floatValue];
                CGFloat width = [[[element0 firstChild] objectForKey:@"width"] floatValue];
                profile.imageSize = CGSizeMake(width, height);
                
                TFHppleElement *element1 = [element.children objectAtIndex:1];
                profile.name = [[element1 firstChild] content];
                
                TFHppleElement *element2 = [element.children objectAtIndex:2];
                profile.role = [[element2 firstChild] content];
                
                TFHppleElement *element3 = [element.children objectAtIndex:3];
                profile.bio = [[element3 firstChild] content];
                
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(profiles, error);
            });
            
        }];
    });
}

- (void)extractProfileNodes:(void(^)(NSArray *nodes))block
{
    NSURL *profilesUrl = [NSURL URLWithString:GBWebPageURL];
    NSData *profilessHtmlData = [NSData dataWithContentsOfURL:profilesUrl];
    TFHpple *profilesParser = [TFHpple hppleWithHTMLData:profilessHtmlData];
    NSString *profilesXpathQueryString = @"//div[@class='col col2']";
    NSArray *profilesNodes = [profilesParser searchWithXPathQuery:profilesXpathQueryString];
    block(profilesNodes);
    
}

@end
