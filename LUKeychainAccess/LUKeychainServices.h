//
//  LUKeychainAccess.h
//  LUKeychainAccess
//
//  Created by Costa Walcott on 5/15/15.
//  Copyright (c) 2015 SCVNGR. All rights reserved.
//

// A wrapper for Keychain Services using the Facade pattern: http://en.wikipedia.org/wiki/Facade_pattern

#import <Foundation/Foundation.h>
#import "LUKeychainAccessAccessibility.h"

@interface LUKeychainServices : NSObject

@property (nonatomic, copy) NSString *accessGroup;
@property (nonatomic, assign) LUKeychainAccessAccessibility accessibilityState;
@property (nonatomic, strong) NSDictionary *additionalQueryParams;
@property (nonatomic, copy) NSString *service;

+ (instancetype)keychainServices;
- (BOOL)addData:(NSData *)data forKey:(NSString *)key error:(NSError **)error;
- (NSData *)dataForKey:(NSString *)key error:(NSError **)error;
- (BOOL)deleteAllItemsWithError:(NSError **)error;
- (BOOL)deleteItemWithKey:(NSString *)key error:(NSError **)error;
- (BOOL)updateData:(NSData *)data forKey:(NSString *)key error:(NSError **)error;

@end
