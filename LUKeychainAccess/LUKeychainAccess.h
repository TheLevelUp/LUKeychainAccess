#import <Foundation/Foundation.h>
#import "LUKeychainErrorHandler.h"
#import "LUKeychainServices.h"
#import "LUKeychainAccessAccessibility.h"

//! Project version number for LUKeychainAccess.
FOUNDATION_EXPORT double LUKeychainAccessVersionNumber;

//! Project version string for LUKeychainAccess.
FOUNDATION_EXPORT const unsigned char LUKeychainAccessVersionString[];

NS_ASSUME_NONNULL_BEGIN

extern NSString *LUKeychainAccessErrorDomain;

typedef NS_ENUM(NSInteger, LUKeychainAccessError) {
  LUKeychainAccessInvalidArchiveError
};

@interface LUKeychainAccess : NSObject

@property (nonatomic, assign) LUKeychainAccessAccessibility accessibilityState;
@property (nonatomic, strong, nullable) id<LUKeychainErrorHandler> errorHandler;
@property (nonatomic, assign) NSString *service;
@property (nonatomic, assign) NSString *accessGroup;

// Public Methods
+ (LUKeychainAccess *)standardKeychainAccess;
- (BOOL)deleteAll;

// Getters
- (BOOL)boolForKey:(NSString *)key;
- (nullable NSData *)dataForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (nullable id)objectForKey:(NSString *)key;
- (nullable NSString *)stringForKey:(NSString *)key;

// Setters
- (void)registerDefaults:(NSDictionary<NSString *, id> *)dictionary;
- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (void)setData:(nullable NSData *)data forKey:(NSString *)key;
- (void)setDouble:(double)value forKey:(NSString *)key;
- (void)setFloat:(float)value forKey:(NSString *)key;
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (void)setObject:(nullable id)value forKey:(NSString *)key;
- (void)setString:(nullable NSString *)inputString forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
