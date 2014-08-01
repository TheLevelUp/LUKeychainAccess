#import "LUKeychainAccess.h"
#import "LUKeychainServices.h"

NSString *LUKeychainAccessErrorDomain = @"LUKeychainAccessErrorDomain";

@interface LUKeychainAccess ()

@property (nonatomic, strong) LUKeychainServices *keychainServices;

@end

@implementation LUKeychainAccess

#pragma mark - Public Methods

+ (LUKeychainAccess *)standardKeychainAccess {
  return [[self alloc] init];
}

- (id)init {
  self = [super init];
  if (!self) return nil;

  _keychainServices = [LUKeychainServices keychainServices];

  return self;
}

- (BOOL)deleteAll {
  NSError *error;
  BOOL result = [self.keychainServices deleteAllItemsWithError:&error];

  if (!result) {
    [self handleError:error];
    return NO;
  }

  return YES;
}

#pragma mark - Properties

- (LUKeychainAccessAccessibility)accessibilityState {
  return self.keychainServices.accessibilityState;
}

- (void)setAccessibilityState:(LUKeychainAccessAccessibility)accessibilityState {
  self.keychainServices.accessibilityState = accessibilityState;
}

- (NSString *)service {
  return self.keychainServices.service;
}

- (void)setService:(NSString *)service {
  self.keychainServices.service = service;
}

#pragma mark - Getters

- (BOOL)boolForKey:(NSString *)key {
  return [[self objectForKey:key] boolValue];
}

- (NSData *)dataForKey:(NSString *)key {
  NSError *error;
  NSData *data = [self.keychainServices dataForKey:key error:&error];

  if (!data) {
    [self handleError:error];
    return nil;
  }

  return data;
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
    NSString *errorMessage = [NSString stringWithFormat:@"Error while calling objectForKey: with key %@: %@", key, [e description]];
    NSError *error = [NSError errorWithDomain:LUKeychainAccessErrorDomain
                                         code:LUKeychainAccessInvalidArchiveError
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
    [self handleError:error];
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

  NSError *error;
  BOOL success = [self.keychainServices addData:data forKey:key error:&error];
  if (!success && error.code == errSecDuplicateItem) {
    error = nil;
    success = [self.keychainServices updateData:data forKey:key error:&error];
  }

  if (!success) {
    [self handleError:error];
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
  NSError *error;
  if (![self.keychainServices deleteItemWithKey:key error:&error]) {
    [self handleError:error];
  }
}

- (void)handleError:(NSError *)error {
  if (self.errorHandler) {
    [self.errorHandler keychainAccess:self receivedError:error];
  }
}

@end
