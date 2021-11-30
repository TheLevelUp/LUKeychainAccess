#import "NSKeyedUnarchiver+Additions.h"

@implementation NSKeyedUnarchiver (Additions)

+ (nullable id)lu_unarchiveObjectOfClass:(Class)cls withData:(NSData *)data {
  if (@available(iOS 11, *)) {
    NSError *error;
    id result = [self unarchivedObjectOfClass:cls fromData:data error:&error];

    if(error) {
      [NSException raise:@"Unarchiver Error" format:@"NSKeyedUnarchiver encountered %@", error];
    }

    return result;
  } else {
    @try {
      return [self unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
      [NSException raise:@"Unarchiver Error" format:@"NSKeyedUnarchiver encountered %@", exception];
    }
  }
}

#pragma mark - Deprecated

+ (nullable id)lu_unarchiveObjectWithData:(NSData *)data {
  return [self lu_unarchiveObjectOfClass:NSObject.class withData:data];
}

@end
