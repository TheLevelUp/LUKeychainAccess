#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedArchiver (Additions)

+ (NSData *)lu_archivedDataWithRootObject:(nonnull id)object;

@end

NS_ASSUME_NONNULL_END
