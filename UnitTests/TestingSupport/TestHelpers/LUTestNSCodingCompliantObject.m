#import "LUTestNSCodingCompliantObject.h"

@implementation LUTestNSCodingCompliantObject

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
  LUTestNSCodingCompliantObject *copy = [[LUTestNSCodingCompliantObject alloc] init];
  copy.testProperty1 = self.testProperty1;
  copy.testProperty2 = self.testProperty2;
  return copy;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
  [coder encodeObject:@(self.testProperty1) forKey:@"testProperty1"];
  [coder encodeObject:self.testProperty2 forKey:@"testProperty2"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder {
  if (self = [super init]) {
    self.testProperty1 = [[decoder decodeObjectForKey:@"testProperty1"] floatValue];
    self.testProperty2 = [[decoder decodeObjectForKey:@"testProperty2"] stringValue];
  }

  return self;
}

@end
