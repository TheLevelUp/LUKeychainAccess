#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedUnarchiver (Additions)

+ (nullable id)lu_unarchiveObjectWithData:(NSData *)data
__attribute__((deprecated("Please use lu_unarchiveObjectOfClass:withData")));

+(nullable id)lu_unarchiveObjectOfClass:(Class)cls withData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
