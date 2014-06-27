//
//  GBSpecificWebPageParser.h
//  Profiles
//
//  Created by Graham Barker on 26/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBSpecificWebPageParser;

@protocol GBSpecificWebPageParserDelegate <NSObject>

- (void)parser:(GBSpecificWebPageParser *)parser didParseBatch:(NSArray *)batch;
- (void)parser:(GBSpecificWebPageParser *)parser didCompleteWithBatch:(NSArray *)batch;

@end

@interface GBSpecificWebPageParser : NSObject

@property (assign, nonatomic, readonly) NSUInteger batchSize;
@property (copy, nonatomic, readonly) NSURL *pageURL;
@property (strong, nonatomic, readonly) NSMutableArray *currentParseBatch;

@property (weak, nonatomic) id <GBSpecificWebPageParserDelegate> delegate;

- (instancetype)initWithBatchSize:(NSUInteger)batch forURL:(NSURL *)specificPageURL context:(NSManagedObjectContext *)context;

- (void)startParsing;

@end
