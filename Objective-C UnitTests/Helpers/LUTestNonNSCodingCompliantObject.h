#import <Foundation/Foundation.h>

@interface LUTestNonNSCodingCompliantObject: NSObject {}

@property(nonatomic, readwrite) float testProperty1;
@property(nonatomic, readwrite) NSString *testProperty2;

@end
