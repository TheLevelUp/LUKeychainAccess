#import <Foundation/Foundation.h>

@class LUKeychainAccess;

@protocol LUKeychainErrorHandler <NSObject>

- (void)keychainAccess:(LUKeychainAccess *)keychainAccess receivedError:(NSError *)error;

@end
