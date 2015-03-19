#import <Foundation/Foundation.h>
#import "LUKeychainErrorHandler.h"

extern NSString *LUKeychainAccessErrorDomain;

typedef NS_ENUM(NSInteger, LUKeychainAccessError) {
  LUKeychainAccessInvalidArchiveError
};

typedef NS_ENUM(NSInteger, LUKeychainAccessAccessibility) {
  LUKeychainAccessAttrAccessibleAfterFirstUnlock,
  LUKeychainAccessAttrAccessibleAfterFirstUnlockThisDeviceOnly,
  LUKeychainAccessAttrAccessibleAlways,
  LUKeychainAccessAttrAccessibleAlwaysThisDeviceOnly,
  LUKeychainAccessAttrAccessibleWhenUnlocked,
  LUKeychainAccessAttrAccessibleWhenUnlockedThisDeviceOnly
};

@interface LUKeychainAccess : NSObject

@property (nonatomic, assign) LUKeychainAccessAccessibility accessibilityState;
@property (nonatomic, strong) id<LUKeychainErrorHandler> errorHandler;
@property (nonatomic, assign) NSString *service;

// Public Methods
+ (LUKeychainAccess *)standardKeychainAccess;
- (BOOL)deleteAll;

// Getters
- (BOOL)boolForKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;

// Setters
- (void)registerDefaults:(NSDictionary *)dictionary;
- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (void)setData:(NSData *)data forKey:(NSString *)key;
- (void)setDouble:(double)value forKey:(NSString *)key;
- (void)setFloat:(float)value forKey:(NSString *)key;
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (void)setObject:(id)value forKey:(NSString *)key;
- (void)setString:(NSString *)inputString forKey:(NSString *)key;

@end
