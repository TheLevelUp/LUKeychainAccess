#import <Foundation/Foundation.h>

@interface LUTestNSCodingCompliantObject: NSObject<NSCoding> {}

@property(nonatomic, readwrite) float testProperty1;
@property(nonatomic, readwrite) NSString *testProperty2;

@end
