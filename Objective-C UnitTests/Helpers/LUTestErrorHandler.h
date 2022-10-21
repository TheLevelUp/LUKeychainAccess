@import LUKeychainAccess;

@interface LUTestErrorHandler : NSObject <LUKeychainErrorHandler>

@property (nonatomic, strong) NSError *lastError;

@end
