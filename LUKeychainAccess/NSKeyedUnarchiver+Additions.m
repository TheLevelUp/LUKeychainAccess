#import "NSKeyedUnarchiver+Additions.h"

@implementation NSKeyedUnarchiver (Additions)

+ (nullable id)lu_unarchiveObjectOfClass:(nonnull Class)objectClass withData:(NSData *)data {
  NSError *error;
  id result;

  if (@available(iOS 11, watchOS 4, *)) {
    result = [self unarchivedObjectOfClass:objectClass fromData:data error:&error];
  } else {
    error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:nil];
  }

  if(error) {
    [NSException raise:@"Unarchiver Error" format:@"NSKeyedUnarchiver encountered %@", error];
  }

  return result;
}

+ (nullable id)lu_unarchiveObjectWithData:(NSData *)data {
  if (@available(iOS 11, watchOS 4, *)) {
    return [self lu_unarchiveObjectOfClass:NSObject.class withData:data];
  } else {
    @try {
      return [self unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
      [NSException raise:@"Unarchiver Error" format:@"NSKeyedUnarchiver encountered %@", exception];
    }
  }
}

@end
