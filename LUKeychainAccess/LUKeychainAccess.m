#import "LUKeychainAccess.h"

@implementation LUKeychainAccess

#pragma mark - Public Methods

+ (LUKeychainAccess *)standardKeychainAccess {
  return [[self alloc] init];
}

#pragma mark - Getters

- (BOOL)boolForKey:(NSString *)key {
  return [[self objectForKey:key] boolValue];
}

- (NSData *)dataForKey:(NSString *)key {
  if (!key) {
    return nil;
  }

  NSMutableDictionary *query = [self queryDictionaryForKey:key];
  query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
  query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;

  CFTypeRef result;
  OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

  if (error == noErr) {
    return CFBridgingRelease(result);
  }

  return nil;
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

  if (data) {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  }

  return nil;
}

- (id)objectForKey:(NSString *)key {
  NSData *data = [self dataForKey:key];

  if (data) {
    @try {
      return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *e) {
      NSLog(@"Unarchive of %@ failed: %@", key, e);
    }
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

  OSStatus addStatus = SecItemAdd((__bridge CFDictionaryRef)query, NULL);

  if (addStatus == errSecDuplicateItem) {
    NSMutableDictionary *updateQuery = [NSMutableDictionary dictionary];
    updateQuery[(__bridge id)kSecValueData] = data;

    SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateQuery);
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

- (void)deleteObjectForKey:(NSString *)key {
  if (key == nil) {
    return;
  }

  NSMutableDictionary *query = [self queryDictionaryForKey:key];
  SecItemDelete((__bridge CFDictionaryRef)query);
}

- (NSMutableDictionary *)queryDictionaryForKey:(NSString *)key {
  NSMutableDictionary *query = [NSMutableDictionary dictionary];
  query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

  NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
  query[(__bridge id)kSecAttrAccount] = encodedIdentifier;
  
  return query;
}

@end
