// A wrapper for Keychain Services using the Facade pattern: http://en.wikipedia.org/wiki/Facade_pattern
#import "LUKeychainAccess.h"

@interface LUKeychainServices : NSObject

@property (nonatomic, assign) LUKeychainAccessAccessibility accessibilityState;

+ (instancetype)keychainServices;
- (BOOL)addData:(NSData *)data forKey:(NSString *)key error:(NSError **)error;
- (NSData *)dataForKey:(NSString *)key error:(NSError **)error;
- (BOOL)deleteAllItemsWithError:(NSError **)error;
- (BOOL)deleteItemWithKey:(NSString *)key error:(NSError **)error;
- (BOOL)updateData:(NSData *)data forKey:(NSString *)key error:(NSError **)error;

@end
