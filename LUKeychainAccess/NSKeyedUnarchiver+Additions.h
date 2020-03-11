#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedUnarchiver (Additions)

+ (nullable id)lu_unarchiveObjectOfClass:(nonnull Class)objectClass
                                withData:(NSData *)data
NS_SWIFT_NAME(unarchiveObject(class:data:)) API_AVAILABLE(ios(11), watchos(4));

+ (nullable id)lu_unarchiveObjectWithData:(NSData *)data
NS_SWIFT_NAME(unarchiveObject(data:));

@end

NS_ASSUME_NONNULL_END
