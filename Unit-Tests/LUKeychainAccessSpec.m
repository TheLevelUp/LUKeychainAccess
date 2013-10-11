#import "Kiwi.h"
#import "LUKeychainAccess.h"
#import "LUKeychainServices.h"

SPEC_BEGIN(LUKeychainAccessSpec)

describe(@"LUKeychainAccess", ^{
  __block LUKeychainAccess *keychainAccess;
  __block LUKeychainAccess *keychainServices;

  // Helpers
  OSStatus error = errSecInteractionNotAllowed;
  void (^itShouldSetLastError)(void (^)(void)) = ^(void (^blockToRun)(void)) {
    it(@"sets lastError", ^{
      blockToRun();

      NSError *lastError = [keychainAccess lastError];
      [[lastError shouldNot] beNil];
      [[theValue(lastError.code) should] equal:theValue(error)];
    });
  };

  beforeEach(^{
    keychainServices = [LUKeychainServices mock];
    [LUKeychainServices stub:@selector(keychainServices) andReturn:keychainServices];

    keychainAccess = [LUKeychainAccess standardKeychainAccess];
  });

  // Public Methods

  describe(@"standardKeychainAccess", ^{
    it(@"returns a LUKeychainAccess", ^{
      [[keychainAccess should] beKindOfClass:[LUKeychainAccess class]];
    });

    it(@"returns a new LUKeychainAccess each time", ^{
      LUKeychainAccess *keychainAccess1 = [LUKeychainAccess standardKeychainAccess];
      LUKeychainAccess *keychainAccess2 = [LUKeychainAccess standardKeychainAccess];

      [[keychainAccess1 shouldNot] equal:keychainAccess2];
    });
  });

  describe(@"deleteAll", ^{
    beforeEach(^{
      [keychainServices stub:@selector(secItemDelete:)];
    });

    it(@"deletes all items from the keychain", ^{
      [[[keychainServices should] receive] secItemDelete:@{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword}];

      [keychainAccess deleteAll];
    });

    context(@"if the delete fails", ^{
      beforeEach(^{
        [keychainServices stub:@selector(secItemDelete:) andReturn:theValue(error)];
      });

      itShouldSetLastError(^{
        [keychainAccess deleteAll];
      });
    });
  });

  // Error Handling

  describe(@"clearLastError", ^{
    it(@"clears lastError", ^{
      [keychainAccess setValue:[NSError errorWithDomain:NSOSStatusErrorDomain code:0 userInfo:nil]
                        forKey:@"lastError"];

      [keychainAccess clearLastError];

      [[keychainAccess lastError] shouldBeNil];
    });
  });

  // Getters

  describe(@"boolForKey:", ^{
    NSString *key = @"boolTest";

    it(@"returns the boolValue of the object stored at the key", ^{
      BOOL testBool = YES;
      [[keychainAccess stubAndReturn:@(testBool)] objectForKey:key];

      [[theValue([keychainAccess boolForKey:key]) should] equal:theValue(testBool)];
    });
  });

  describe(@"dataForKey:", ^{
    NSData *expectedResult = [@"value" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = @"dataTest";

    it(@"returns the data stored in keychain at the key", ^{
      [keychainServices stub:@selector(secItemCopyMatching:result:) withBlock:^id(NSArray *params) {
        NSDictionary *query = params[0];
        [[query[(__bridge id)kSecAttrAccount] should] equal:[key dataUsingEncoding:NSUTF8StringEncoding]];

        __weak id *result;
        [(NSValue *)params[1] getValue:&result];
        *result = expectedResult;

        return nil;
      }];

      [[[keychainAccess dataForKey:key] should] equal:expectedResult];
    });

    context(@"if the services command fails", ^{
      beforeEach(^{
        [keychainServices stub:@selector(secItemCopyMatching:result:) andReturn:theValue(error)];
      });

      itShouldSetLastError(^{
        [keychainAccess dataForKey:key];
      });
    });
  });

  describe(@"doubleForKey:", ^{
    NSString *key = @"doubleTest";

    it(@"returns the doubleValue of the object stored at the key", ^{
      double testDouble = 123.0;
      [[keychainAccess stubAndReturn:@(testDouble)] objectForKey:key];

      [[theValue([keychainAccess doubleForKey:key]) should] equal:theValue(testDouble)];
    });
  });

  describe(@"floatForKey:", ^{
    NSString *key = @"floatTest";

    it(@"returns the floatValue of the object stored at the key", ^{
      float testFloat = 123.0;
      [[keychainAccess stubAndReturn:@(testFloat)] objectForKey:key];

      [[theValue([keychainAccess floatForKey:key]) should] equal:theValue(testFloat)];
    });
  });

  describe(@"integerForKey:", ^{
    NSString *key = @"integerTest";

    it(@"returns the integerValue of the object stored at the key", ^{
      NSInteger testInteger = 123;
      [[keychainAccess stubAndReturn:@(testInteger)] objectForKey:key];

      [[theValue([keychainAccess integerForKey:key]) should] equal:theValue(testInteger)];
    });
  });

  describe(@"stringForKey:", ^{
    NSString *key = @"stringTest";

    it(@"returns a UTF-8 encoded string from the data stored at the key", ^{
      NSString *testString = @"testString";
      [[keychainAccess stubAndReturn:[testString dataUsingEncoding:NSUTF8StringEncoding]] dataForKey:key];

      [[[keychainAccess stringForKey:key] should] equal:testString];
    });
  });

  describe(@"objectForKey:", ^{
    NSString *key = @"objectTest";

    it(@"returns the unarchived object from the data stored at the key", ^{
      NSArray *testObject = @[@1, @2];
      [[keychainAccess stubAndReturn:[NSKeyedArchiver archivedDataWithRootObject:testObject]] dataForKey:key];

      [[[keychainAccess objectForKey:key] should] equal:testObject];
    });

    context(@"if the unarchive fails", ^{
      beforeEach(^{
        int zero = 0;
        [[keychainAccess stubAndReturn:[NSData dataWithBytes:&zero length:sizeof(zero)]] dataForKey:key];
      });

      it(@"should not raise", ^{
        [[theBlock(^{
          [keychainAccess objectForKey:key];
        }) shouldNot] raise];
      });

      it(@"sets lastError", ^{
        [keychainAccess objectForKey:key];

        NSError *error = [keychainAccess lastError];
        [[error shouldNot] beNil];
        [[theValue(error.code) should] equal:theValue(LUKeychainAccessInvalidArchiveError)];
      });
    });
  });

  // Setters

  describe(@"registerDefaults:", ^{
    beforeEach(^{
      [keychainAccess stub:@selector(objectForKey:)];
      [keychainAccess stub:@selector(setString:forKey:)];
      [keychainAccess stub:@selector(setObject:forKey:)];
    });

    it(@"sets strings using setString: instead of setObject:", ^{
      NSString *newValue = @"newValue";
      [[[keychainAccess should] receive] setString:newValue forKey:@"newKey"];
      [keychainAccess registerDefaults:@{@"newKey": newValue}];
    });

    it(@"sets other data types via setObject:", ^{
      [[[keychainAccess should] receive] setObject:@1 forKey:@"newKey"];
      [keychainAccess registerDefaults:@{@"newKey" : @1}];
    });

    it(@"doesn't overwrite existing values", ^{
      [keychainAccess clearStubs];
      [[keychainAccess stubAndReturn:@"existingValue"] objectForKey:@"existingKey"];

      [[[keychainAccess shouldNot] receive] setObject:@YES forKey:@"existingKey"];
      [keychainAccess registerDefaults:@{@"existingKey" : @YES}];
    });

    it(@"sets the value for new keys", ^{
      [[[keychainAccess should] receive] setObject:@YES forKey:@"newKey"];
      [keychainAccess registerDefaults:@{@"newKey" : @YES}];
    });

    it(@"can set multiple keys", ^{
      [[[keychainAccess should] receive] setObject:@YES forKey:@"foo"];
      [[[keychainAccess should] receive] setObject:@100 forKey:@"bar"];
      [keychainAccess registerDefaults:@{@"foo" : @YES, @"bar" : @100}];
    });
  });

  describe(@"setBool:forKey:", ^{
    NSString *key = @"boolTest";

    it(@"stores the object version of the value with the key", ^{
      BOOL testBool = NO;
      [[[keychainAccess should] receive] setObject:@(testBool) forKey:key];

      [keychainAccess setBool:testBool forKey:key];
    });
  });

  describe(@"setData:forKey:", ^{
    NSString *key = @"dataTest";

    context(@"when the data is nil", ^{
      it(@"deletes the data at the key", ^{
        [keychainServices stub:@selector(secItemDelete:) withBlock:^id(NSArray *params) {
          NSDictionary *query = params[0];
          [[query[(__bridge id)kSecAttrAccount] should] equal:[key dataUsingEncoding:NSUTF8StringEncoding]];

          return nil;
        }];
        [[keychainServices should] receive:@selector(secItemDelete:)];

        [keychainAccess setData:nil forKey:key];
      });
    });

    context(@"when the data is non-nil", ^{
      NSData *testData = [@"testData" dataUsingEncoding:NSUTF8StringEncoding];

      it(@"attempts to add the data to the Keychain", ^{
        [keychainServices stub:@selector(secItemAdd:) withBlock:^id(NSArray *params) {
          NSDictionary *query = params[0];
          [[query[(__bridge id)kSecAttrAccount] should] equal:[key dataUsingEncoding:NSUTF8StringEncoding]];
          [[query[(__bridge id)kSecValueData] should] equal:testData];

          return nil;
        }];
        [[keychainServices should] receive:@selector(secItemAdd:)];

        [keychainAccess setData:testData forKey:key];
      });

      context(@"when the item already exists in the keychain", ^{
        beforeEach(^{
          [keychainServices stub:@selector(secItemAdd:) andReturn:theValue(errSecDuplicateItem)];
        });

        it(@"updates the item with the new value", ^{
          [keychainServices stub:@selector(secItemUpdate:updateQuery:) withBlock:^id(NSArray *params) {
            NSDictionary *query = params[0];
            [[query[(__bridge id)kSecAttrAccount] should] equal:[key dataUsingEncoding:NSUTF8StringEncoding]];

            NSDictionary *updateQuery = params[1];
            [[updateQuery[(__bridge id)kSecValueData] should] equal:testData];

            return nil;
          }];
          [[keychainServices should] receive:@selector(secItemUpdate:updateQuery:)];

          [keychainAccess setData:testData forKey:key];
        });
      });

      context(@"if a services command fails", ^{
        beforeEach(^{
          [keychainServices stub:@selector(secItemAdd:) andReturn:theValue(error)];
        });

        itShouldSetLastError(^{
          [keychainAccess setData:testData forKey:key];
        });
      });
    });
  });

  describe(@"setDouble:forKey:", ^{
    NSString *key = @"doubleTest";

    it(@"stores the object version of the value with the key", ^{
      double testDouble = 123.0f;
      [[[keychainAccess should] receive] setObject:@(testDouble) forKey:key];

      [keychainAccess setDouble:testDouble forKey:key];
    });
  });

  describe(@"setFloat:forKey:", ^{
    NSString *key = @"floatTest";

    it(@"stores the object version of the value with the key", ^{
      float testFloat = 123.0;
      [[[keychainAccess should] receive] setObject:@(testFloat) forKey:key];

      [keychainAccess setFloat:testFloat forKey:key];
    });
  });

  describe(@"setInteger:forKey:", ^{
    NSString *key = @"integerTest";

    it(@"stores the object version of the value with the key", ^{
      NSInteger testInteger = 123;
      [[[keychainAccess should] receive] setObject:@(testInteger) forKey:key];

      [keychainAccess setInteger:testInteger forKey:key];
    });
  });

  describe(@"setString:forKey:", ^{
    NSString *key = @"stringTest";

    it(@"stores the string encoded as UTF-8 with the key", ^{
      NSString *testString = @"testString";
      [[[keychainAccess should] receive] setData:[testString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];

      [keychainAccess setString:testString forKey:key];
    });
  });

  describe(@"setObject:forKey:", ^{
    NSString *key = @"objectTest";

    it(@"stores the archived data of the object with the key", ^{
      NSArray *testObject = @[@1, @2];
      [[[keychainAccess should] receive] setData:[NSKeyedArchiver archivedDataWithRootObject:testObject] forKey:key];

      [keychainAccess setObject:testObject forKey:key];
    });
  });
});

SPEC_END
