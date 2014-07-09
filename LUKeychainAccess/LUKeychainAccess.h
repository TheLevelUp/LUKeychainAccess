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

// Public Methods
+ (LUKeychainAccess *)standardKeychainAccess;
- (BOOL)deleteAll;

// Getters
- (BOOL)boolForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key service:(NSString*)service;
- (NSData *)dataForKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key service:(NSString*)service;
- (double)doubleForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key service:(NSString*)service;
- (float)floatForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key service:(NSString*)service;
- (NSInteger)integerForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key service:(NSString*)service;
- (id)objectForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key service:(NSString*)service;
- (NSString *)stringForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key service:(NSString*)service;

// Setters
- (void)registerDefaults:(NSDictionary *)dictionary;
- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (void)setBool:(BOOL)value forKey:(NSString *)key service:(NSString*)service;
- (void)setData:(NSData *)data forKey:(NSString *)key;
- (void)setData:(NSData *)data forKey:(NSString *)key service:(NSString*)service;
- (void)setDouble:(double)value forKey:(NSString *)key;
- (void)setDouble:(double)value forKey:(NSString *)key service:(NSString*)service;
- (void)setFloat:(float)value forKey:(NSString *)key;
- (void)setFloat:(float)value forKey:(NSString *)key service:(NSString*)service;
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (void)setInteger:(NSInteger)value forKey:(NSString *)key service:(NSString*)service;
- (void)setObject:(id)value forKey:(NSString *)key;
- (void)setObject:(id)value forKey:(NSString *)key service:(NSString*)service;
- (void)setString:(NSString *)inputString forKey:(NSString *)key;
- (void)setString:(NSString *)inputString forKey:(NSString *)key service:(NSString*)service;

@end
