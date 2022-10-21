#import "LUTestErrorHandler.h"

@implementation LUTestErrorHandler

- (void)keychainAccess:(LUKeychainAccess *)keychainAccess receivedError:(NSError *)error {
  self.lastError = error;
}

@end
