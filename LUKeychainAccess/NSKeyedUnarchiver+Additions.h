#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedUnarchiver (Additions)

+ (nullable id)lu_unarchiveObjectWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
