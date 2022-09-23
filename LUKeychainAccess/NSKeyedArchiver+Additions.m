//#import "NSKeyedUnarchiver+Additions.h"
//
//@implementation NSKeyedArchiver (Additions)
//
//+ (NSData *)lu_archivedDataWithRootObject:(nullable id)object {
//  if (!object) return nil;
//
//  if (@available(iOS 11, *)) {
//    NSError *error;
//    NSData *result = [self archivedDataWithRootObject:object
//                                requiringSecureCoding:false
//                                                error:&error];
//    if (error) {
//      [NSException raise:@"Archiver Error" format:@"NSKeyedUnarchiver encountered %@", error];
//    }
//
//    return result;
//  } else {
//    @try {
//      return [self archivedDataWithRootObject:object];
//    } @catch (NSException *exception) {
//      [NSException raise:@"Archiver Error" format:@"NSKeyedUnarchiver encountered %@", exception];
//    }
//  }
//}
//
//@end
