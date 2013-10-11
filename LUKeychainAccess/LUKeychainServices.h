// A wrapper for Keychain Services using the Facade pattern: http://en.wikipedia.org/wiki/Facade_pattern

@interface LUKeychainServices : NSObject

+ (instancetype)keychainServices;
- (OSStatus)secItemAdd:(NSDictionary *)query;
- (OSStatus)secItemCopyMatching:(NSDictionary *)query result:(id *)result;
- (OSStatus)secItemDelete:(NSDictionary *)query;
- (OSStatus)secItemUpdate:(NSDictionary *)query updateQuery:(NSDictionary *)updateQuery;

@end
