#import <Foundation/Foundation.h>
#import "LUKeychainErrorHandler.h"
#import "LUKeychainServices.h"
#import "LUKeychainAccessAccessibility.h"

//! Project version number for LUKeychainAccess.
FOUNDATION_EXPORT double LUKeychainAccessVersionNumber;

//! Project version string for LUKeychainAccess.
FOUNDATION_EXPORT const unsigned char LUKeychainAccessVersionString[];

extern NSString *LUKeychainAccessErrorDomain;

typedef NS_ENUM(NSInteger, LUKeychainAccessError) {
  LUKeychainAccessInvalidArchiveError
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
