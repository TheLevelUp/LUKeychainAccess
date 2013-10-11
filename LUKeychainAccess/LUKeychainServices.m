#import "LUKeychainServices.h"

@implementation LUKeychainServices

+ (instancetype)keychainServices {
  return [[self alloc] init];
}

- (OSStatus)secItemAdd:(NSDictionary *)query {
  return SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

- (OSStatus)secItemCopyMatching:(NSDictionary *)query result:(id *)result {
  CFTypeRef cfResult;
  OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, &cfResult);

  if (result) {
    if (error == noErr) {
      *result = CFBridgingRelease(cfResult);
    } else {
      *result = nil;
    }
  }

  return error;
}

- (OSStatus)secItemDelete:(NSDictionary *)query {
  return SecItemDelete((__bridge CFDictionaryRef)query);
}

- (OSStatus)secItemUpdate:(NSDictionary *)query updateQuery:(NSDictionary *)updateQuery {
  return SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateQuery);
}

@end
