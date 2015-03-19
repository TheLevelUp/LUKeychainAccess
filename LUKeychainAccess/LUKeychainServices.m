#import <Security/Security.h>
#import "LUKeychainServices.h"

@implementation LUKeychainServices

+ (instancetype)keychainServices {
  return [[self alloc] init];
}

- (id)init {
  self = [super init];
  if (!self) return nil;

  _accessibilityState = LUKeychainAccessAttrAccessibleWhenUnlocked;

  return self;
}

- (BOOL)addData:(NSData *)data forKey:(NSString *)key error:(NSError **)error {
  NSMutableDictionary *query = [self queryDictionaryForKey:key];
  query[(__bridge id)kSecAttrAccessible] = (__bridge id)[self accessibilityStateCFType];
  query[(__bridge id)kSecValueData] = data;

  OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
  if (status != noErr) {
    if (error) *error = [self errorFromOSStatus:status descriptionFormat:@"SecItemAdd with key %@", key];
    return NO;
  }

  return YES;
}

- (NSData *)dataForKey:(NSString *)key error:(NSError **)error {
  NSMutableDictionary *query = [self queryDictionaryForKey:key];
  query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
  query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;

  CFTypeRef cfResult;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &cfResult);
  if (status != noErr) {
    if (error) *error = [self errorFromOSStatus:status descriptionFormat:@"SecItemCopyMatching with key %@", key];
    return nil;
  }

  id data = CFBridgingRelease(cfResult);
  if (![data isKindOfClass:[NSData class]]) return nil;

  return data;
}

- (BOOL)deleteAllItemsWithError:(NSError **)error {
  NSMutableDictionary *query = [NSMutableDictionary dictionary];
  query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

  OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
  if (status != noErr) {
    if (error) *error = [self errorFromOSStatus:status descriptionFormat:@"SecItemDelete with no key"];
    return NO;
  }

  return YES;
}

- (BOOL)deleteItemWithKey:(NSString *)key error:(NSError **)error {
  NSMutableDictionary *query = [self queryDictionaryForKey:key];

  OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
  if (status != noErr) {
    if (error) *error = [self errorFromOSStatus:status descriptionFormat:@"SecItemDelete with key %@", key];
    return NO;
  }

  return YES;
}

- (BOOL)updateData:(NSData *)data forKey:(NSString *)key error:(NSError **)error {
  NSMutableDictionary *query = [self queryDictionaryForKey:key];
  query[(__bridge id)kSecValueData] = data;

  NSMutableDictionary *updateQuery = [NSMutableDictionary dictionary];
  updateQuery[(__bridge id)kSecValueData] = data;
  updateQuery[(__bridge id)kSecAttrAccessible] = (__bridge id)[self accessibilityStateCFType];

  OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateQuery);
  if (status != noErr) {
    if (error) *error = [self errorFromOSStatus:status descriptionFormat:@"SecItemUpdate with key %@ and data %@", key, data];
    return NO;
  }

  return YES;
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

- (NSError *)errorFromOSStatus:(OSStatus)status descriptionFormat:(NSString *)descriptionFormat, ... {
  va_list args;
  va_start(args, descriptionFormat);

  NSString *callerDescription = [[NSString alloc] initWithFormat:descriptionFormat arguments:args];

  va_end(args);

  NSString *description = [NSString stringWithFormat:@"Error while calling %@: %@", callerDescription, [self errorMessageFromOSStatus:status]];

  return [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:@{NSLocalizedDescriptionKey: description}];
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

  NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
  query[(__bridge id)kSecAttrAccount] = encodedIdentifier;

  if (self.service) {
    query[(__bridge id)kSecAttrService] = self.service;
  }

  return query;
}

@end
