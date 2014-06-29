//
//  GBSpecificWebPageParser.m
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "GBSpecificWebPageParser.h"
#import "TFHpple.h"
#import <CoreData/CoreData.h>
#import "Profile.h"

@interface GBSpecificWebPageParser ()

@property (strong, nonatomic) NSMutableArray *currentParseBatch;
@property (strong, nonatomic) NSManagedObjectContext *localContext;

@end


@implementation GBSpecificWebPageParser

- (instancetype)initWithBatchSize:(NSUInteger)batch forURL:(NSURL *)specificPageURL context:(NSManagedObjectContext *)context
{
    NSParameterAssert(batch >= 1);
    NSParameterAssert(specificPageURL.absoluteString.length > 0);
    NSParameterAssert(context);
    
    self = [super init];
    if (self) {
        _batchSize = batch;
        _pageURL = specificPageURL;
        _currentParseBatch = [NSMutableArray array];
        _localContext = context;
    }
    return self;
}


- (NSArray *)fetchProfileNodesForData:(NSData *)profilessHtmlData
{
    TFHpple *profilesParser = [TFHpple hppleWithHTMLData:profilessHtmlData];
    NSString *profilesXpathQueryString = @"//div[@class='col col2']";
    NSArray *profilesNodes = [profilesParser searchWithXPathQuery:profilesXpathQueryString];
    return profilesNodes;
}

- (void)startParsing
{
    [self startParsingInContext:self.localContext];
}

- (void)startParsingInContext:(NSManagedObjectContext *)context;
{
    NSData *profilessHtmlData = [NSData dataWithContentsOfURL:self.pageURL];
    [self startParsingInContext:context withData:profilessHtmlData];
}


#pragma message "TECH DEBT: In a real app, this method would be replaced with a more robust solution"
- (void)startParsingInContext:(NSManagedObjectContext *)context withData:(NSData *)htmlData
{
    NSArray *profilesNodes = [self fetchProfileNodesForData:htmlData];
    
    for (TFHppleElement *element in profilesNodes) {
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:context];
        
        Profile *profile = [[Profile alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];
        
        TFHppleElement *urlElement = [element.children objectAtIndex:0];
        profile.url = [[urlElement firstChild] objectForKey:@"src"];
        
        TFHppleElement *nameElement = [element.children objectAtIndex:1];
        profile.name = [[nameElement firstChild] content];
        
        TFHppleElement *roleElement = [element.children objectAtIndex:2];
        profile.role = [[roleElement firstChild] content];
        
        TFHppleElement *bioElement = [element.children objectAtIndex:3];
        profile.bio = [[bioElement firstChild] content];
        
        [self.currentParseBatch addObject:profile];
        if ([self.currentParseBatch count] >= self.batchSize) {
            if ([self.delegate respondsToSelector:@selector(parser:didParseBatch:)] ) {
                [self.delegate performSelector:@selector(parser:didParseBatch:) withObject:self withObject:[self.currentParseBatch copy]];
            }
            self.currentParseBatch = [NSMutableArray array];
        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(parser:didCompleteWithBatch:)]) {
        [self.delegate performSelector:@selector(parser:didCompleteWithBatch:) withObject:self withObject:[self.currentParseBatch copy]];
    }
}


@end
