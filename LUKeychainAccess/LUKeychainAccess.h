////
////  LUKeychainAccess.h
////  LUKeychainAccess
////
////  Created by Costa Walcott on 5/15/15.
////  Copyright (c) 2015 SCVNGR. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "LUKeychainErrorHandler.h"
//#import "LUKeychainServices.h"
//#import "LUKeychainAccessAccessibility.h"
//
////! Project version number for LUKeychainAccess.
//FOUNDATION_EXPORT double LUKeychainAccessVersionNumber;
//
////! Project version string for LUKeychainAccess.
//FOUNDATION_EXPORT const unsigned char LUKeychainAccessVersionString[];
//
//NS_ASSUME_NONNULL_BEGIN
////
////extern NSString *LUKeychainAccessErrorDomain;
////
////typedef NS_ENUM(NSInteger, LUKeychainAccessError) {
////  LUKeychainAccessInvalidArchiveError
////};
////
////@interface LUKeychainAccess : NSObject
////
////@property (nonatomic, copy) NSString *accessGroup;
////@property (nonatomic, assign) LUKeychainAccessAccessibility accessibilityState;
////@property (nonatomic, strong, nullable) NSDictionary *additionalQueryParams;
////@property (nonatomic, strong, nullable) id<LUKeychainErrorHandler> errorHandler;
////@property (nonatomic, copy) NSString *service;
////
////// Public Methods
////+ (LUKeychainAccess *)standardKeychainAccess;
////- (BOOL)deleteAll;
////- (void)deleteObjectForKey:(NSString *)key;
//
//// Getters
//
///**
// Returns the root object of one of the given classes from the given archive, previously encoded by one of the "set"
// methods (setBool, setFloat etc.).
//
// @param key The key that was previously used to archive the data.
// @param set The set of classes needed to unarchive the root object.
//
// @warning Classes of NSString, NSDictionary, NSArray, and NSNumber are supplied by default, all other classes
// must be passed in.
//
// @return The previously archived object, nil if the key or classes are not valid or the data can't be decoded.
// Calls `handleError:` with errors from NSKeyedUnarchiver.
//// */
////- (nullable id)objectForKey:(NSString *)key ofClasses:(NSSet *)set;
////- (BOOL)boolForKey:(NSString *)key;
////- (nullable NSData *)dataForKey:(NSString *)key;
////- (double)doubleForKey:(NSString *)key;
////- (float)floatForKey:(NSString *)key;
////- (NSInteger)integerForKey:(NSString *)key;
////- (nullable id)objectForKey:(NSString *)key ofClass:(Class)cls;
////- (nullable id)recursivelyFindObjectForKey:(NSString *)key fromClass:(Class)cls;
////- (nullable NSString *)stringForKey:(NSString *)key;
////
////// Setters
////- (void)registerDefaults:(NSDictionary<NSString *, id> *)dictionary;
////- (void)setBool:(BOOL)value forKey:(NSString *)key;
////- (void)setData:(nullable NSData *)data forKey:(NSString *)key;
////- (void)setDouble:(double)value forKey:(NSString *)key;
////- (void)setFloat:(float)value forKey:(NSString *)key;
////- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
////- (void)setObject:(nullable id)value forKey:(NSString *)key;
////- (void)setString:(nullable NSString *)inputString forKey:(NSString *)key;
//
////Deprecated
////- (nullable id)objectForKey:(NSString *)key
////__attribute__((deprecated("Please use objectForKey:ofClass:")));
//
////@end
//
//NS_ASSUME_NONNULL_END
