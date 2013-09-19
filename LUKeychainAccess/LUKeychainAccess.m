#import "LUKeychainAccess.h"

NSString *LUKeychainAccessErrorDomain = @"LUKeychainAccessErrorDomain";

@interface LUKeychainAccess ()

@property (nonatomic, strong) NSError *lastError;

@end

@implementation LUKeychainAccess

#pragma mark - Public Methods

+ (LUKeychainAccess *)standardKeychainAccess {
  return [[self alloc] init];
}

- (id)init {
  self = [super init];
  if (!self) return nil;

  _accessibilityState = LUKeychainAccessAttrAccessibleWhenUnlocked;

  return self;
}

- (BOOL)deleteAll {
  NSMutableDictionary *query = [NSMutableDictionary dictionary];
  query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
  OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);

  if (status != noErr) {
    self.lastError = [self errorFromOSStatus:status];
    return NO;
  }

  return YES;
}

#pragma mark - Error Handling

- (void)clearLastError {
  self.lastError = nil;
}

#pragma mark - Getters

- (BOOL)boolForKey:(NSString *)key {
  return [[self objectForKey:key] boolValue];
}

- (NSData *)dataForKey:(NSString *)key {
  NSMutableDictionary *query = [self queryDictionaryForKey:key];
  query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
  query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;

  CFTypeRef result;
  OSStatus osError = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

  if (osError != noErr) {
    self.lastError = [self errorFromOSStatus:osError];
    return nil;
  }

  return CFBridgingRelease(result);
}

- (double)doubleForKey:(NSString *)key {
  return [[self objectForKey:key] doubleValue];
}

- (float)floatForKey:(NSString *)key {
  return [[self objectForKey:key] floatValue];
}

- (NSInteger)integerForKey:(NSString *)key {
  return [[self objectForKey:key] integerValue];
}

- (NSString *)stringForKey:(NSString *)key {
  NSData *data = [self dataForKey:key];

  if (!data) return nil;

  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (id)objectForKey:(NSString *)key {
  NSData *data = [self dataForKey:key];

  @try {
    if (data) {
      return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
  } @catch (NSException *e) {
    self.lastError = [NSError errorWithDomain:LUKeychainAccessErrorDomain
                                         code:LUKeychainAccessInvalidArchiveError
                                     userInfo:@{NSLocalizedDescriptionKey: [e description]}];
  }

  return nil;
}

#pragma mark - Setters

- (void)registerDefaults:(NSDictionary *)dictionary {
  for (NSString *key in [dictionary allKeys]) {
    if (![self objectForKey:key]) {
      if ([dictionary[key] isKindOfClass:[NSString class]]) {
        [self setString:dictionary[key] forKey:key];
      } else {
        [self setObject:dictionary[key] forKey:key];
      }
    }
  }
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
  [self setObject:@(value) forKey:key];
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
  if (!data) {
    [self deleteObjectForKey:key];
    return;
  }

  NSMutableDictionary *query = [self queryDictionaryForKey:key];
  query[(__bridge id)kSecValueData] = data;

  OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);

  if (status == errSecDuplicateItem) {
    NSMutableDictionary *updateQuery = [NSMutableDictionary dictionary];
    updateQuery[(__bridge id)kSecValueData] = data;

    status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateQuery);
  }

  if (status != noErr) {
    self.lastError = [self errorFromOSStatus:status];
  }
}

- (void)setDouble:(double)value forKey:(NSString *)key {
  [self setObject:@(value) forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString *)key {
  [self setObject:@(value) forKey:key];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
  [self setObject:@(value) forKey:key];
}

- (void)setString:(NSString *)inputString forKey:(NSString *)key {
  [self setData:[inputString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
}

- (void)setObject:(id)value forKey:(NSString *)key {
  [self setData:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:key];
}

#pragma mark - Private Methods

- (CFTypeRef)accessibilityStateCFType {
  switch (self.accessibilityState) {
    case LUKeychainAccessAttrAccessibleAfterFirstUnlock:
      return kSecAttrAccessibleAfterFirstUnlock;

    case LUKeychainAccessAttrAccessibleAfterFirstUnlockThisDeviceOnly:
      return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;

    case LUKeychainAccessAttrAccessibleAlways:
      return kSecAttrAccessibleAlways;

    case LUKeychainAccessAttrAccessibleAlwaysThisDeviceOnly:
      return kSecAttrAccessibleAlwaysThisDeviceOnly;

    case LUKeychainAccessAttrAccessibleWhenUnlocked:
      return kSecAttrAccessibleWhenUnlocked;

    case LUKeychainAccessAttrAccessibleWhenUnlockedThisDeviceOnly:
      return kSecAttrAccessibleWhenUnlockedThisDeviceOnly;

    default:
      return kSecAttrAccessibleWhenUnlocked;
  }
}

- (void)deleteObjectForKey:(NSString *)key {
  NSMutableDictionary *query = [self queryDictionaryForKey:key];
  OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);

  if (status != noErr) {
    self.lastError = [self errorFromOSStatus:status];
  }
}

- (NSError *)errorFromOSStatus:(OSStatus)status {
  return [NSError errorWithDomain:NSOSStatusErrorDomain
                             code:status
                         userInfo:@{NSLocalizedDescriptionKey : [self errorMessageFromOSStatus:status]}];
}

- (NSString *)errorMessageFromOSStatus:(OSStatus)status {
  switch (status) {
    case errSecUnimplemented:
      return @"Function or operation not implemented.";

    case errSecParam:
      return @"One or more parameters passed to a function where not valid.";

    case errSecAllocate:
      return @"Failed to allocate memory.";

    case errSecNotAvailable:
      return @"No keychain is available. You may need to restart your computer.";

    case errSecDuplicateItem:
      return @"The specified item already exists in the keychain.";

    case errSecItemNotFound:
      return @"The specified item could not be found in the keychain.";

    case errSecInteractionNotAllowed:
      return @"User interaction is not allowed.";

    case errSecDecode:
      return @"Unable to decode the provided data.";

    case errSecAuthFailed:
      return @"The user name or passphrase you entered is not correct.";

    default:
      return @"No error.";
  }
}

- (NSMutableDictionary *)queryDictionaryForKey:(NSString *)key {
  NSAssert(key != nil, @"A non-nil key must be provided.");

  NSMutableDictionary *query = [NSMutableDictionary dictionary];
  query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
  query[(__bridge id)kSecAttrAccessible] = (__bridge id)[self accessibilityStateCFType];

  NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
  query[(__bridge id)kSecAttrAccount] = encodedIdentifier;
  
  return query;
}

@end
