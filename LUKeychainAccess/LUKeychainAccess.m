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

#pragma mark - Getters

- (BOOL)boolForKey:(NSString *)key {
  return [[self objectForKey:key] boolValue];
}

- (BOOL)boolForKey:(NSString *)key service:(NSString*)service {
    return [[self objectForKey:key service:service] boolValue];
}

- (NSData *)dataForKey:(NSString *)key {
    return [self dataForKey:key service:nil];
}

- (NSData *)dataForKey:(NSString *)key service:(NSString*)service {
    NSError *error;
    NSData *data = [self.keychainServices dataForKey:key error:&error];

    if (!data) {
        [self handleError:error];
        return nil;
    }

    return data;
}

- (double)doubleForKey:(NSString *)key {
  return [self doubleForKey:key service:nil];
}

- (double)doubleForKey:(NSString *)key service:(NSString*)service {
    return [[self objectForKey:key service:service] doubleValue];
}

- (float)floatForKey:(NSString *)key {
  return [self floatForKey:key service:nil];
}

- (float)floatForKey:(NSString *)key service:(NSString*)service {
    return [[self objectForKey:key service:service] floatValue];
}

- (NSInteger)integerForKey:(NSString *)key {
  return [self integerForKey:key service:nil];
}

- (NSInteger)integerForKey:(NSString *)key service:(NSString*)service {
    return [[self objectForKey:key service:service] integerValue];
}

- (NSString *)stringForKey:(NSString *)key {
    return [self stringForKey:key service:nil];
}

- (NSString *)stringForKey:(NSString *)key service:(NSString*)service {
  NSData *data = [self dataForKey:key service:service];

  if (!data) return nil;

  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (id)objectForKey:(NSString *)key {
  return [self objectForKey:key service:nil];
}

- (id)objectForKey:(NSString *)key service:(NSString*)service {
    NSData *data = [self dataForKey:key service:service];

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
    [self setBool:value forKey:key service:nil];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key service:(NSString*)service {
    [self setObject:@(value) forKey:key service:service];
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
    [self setData:data forKey:key service:nil];
}

- (void)setData:(NSData *)data forKey:(NSString *)key service:(NSString*)service {
    if (!data) {
        [self deleteObjectForKey:key service:service];
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
  [self setDouble:value forKey:key service:nil];
}

- (void)setDouble:(double)value forKey:(NSString *)key service:(NSString*)service {
  [self setObject:@(value) forKey:key service:service];
}

- (void)setFloat:(float)value forKey:(NSString *)key {
  [self setFloat:value forKey:key service:nil];
}

- (void)setFloat:(float)value forKey:(NSString *)key service:(NSString*)service {
  [self setObject:@(value) forKey:key service:service];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
  [self setInteger:value forKey:key service:nil];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key service:(NSString*)service {
  [self setObject:@(value) forKey:key service:service];
}

- (void)setString:(NSString *)inputString forKey:(NSString *)key {
  [self setString:inputString forKey:key service:nil];
}

- (void)setString:(NSString *)inputString forKey:(NSString *)key service:(NSString*)service {
  [self setData:[inputString dataUsingEncoding:NSUTF8StringEncoding] forKey:key service:service];
}

- (void)setObject:(id)value forKey:(NSString *)key {
    [self setObject:value forKey:key service:nil];
}

- (void)setObject:(id)value forKey:(NSString *)key service:(NSString*)service {
    [self setData:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:key service:service];
}

#pragma mark - Private Methods

- (void)deleteObjectForKey:(NSString *)key {
    [self deleteObjectForKey:key service:nil];
}

- (void)deleteObjectForKey:(NSString *)key service:(NSString*)service {
    NSError *error;
    if (![self.keychainServices deleteItemWithKey:key service:service error:&error]) {
        [self handleError:error];
    }
}

- (void)handleError:(NSError *)error {
  if (self.errorHandler) {
    [self.errorHandler keychainAccess:self receivedError:error];
  }
}

@end
