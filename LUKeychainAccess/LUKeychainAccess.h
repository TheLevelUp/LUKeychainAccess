@interface LUKeychainAccess : NSObject

// Public Methods
+ (LUKeychainAccess *)standardKeychainAccess;

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
