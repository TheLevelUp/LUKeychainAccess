#import "NSKeyedUnarchiver+Additions.h"

@implementation NSKeyedUnarchiver (Additions)

+ (nullable id)lu_unarchiveObjectOfClasses:(NSSet*)set withData:(NSData *)data {
  if (@available(iOS 11, *)) {
    NSError *error;
    NSSet *_set = [NSSet setWithArray:@[NSString.class, NSDictionary.class, NSArray.class, NSNumber.class]];
    NSSet *combinedSet = [_set setByAddingObjectsFromSet:set];
    id result = [self unarchivedObjectOfClasses:combinedSet fromData:data error:&error];

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

+ (nullable id)lu_unarchiveObjectOfClass:(Class)cls withData:(NSData *)data {
  return [self lu_unarchiveObjectOfClasses:[NSSet setWithObject:cls] withData:data];
}

#pragma mark - Deprecated

+ (nullable id)lu_unarchiveObjectWithData:(NSData *)data {
  return [self lu_unarchiveObjectOfClass:NSObject.class withData:data];
}

@end
