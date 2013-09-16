#import "Kiwi.h"
#import "LUKeychainAccess.h"

SPEC_BEGIN(LUKeychainAccessSpec)

describe(@"LUKeychainAccess", ^{
  __block LUKeychainAccess *keychainAccess;

  beforeEach(^{
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
      [keychainAccess setBool:YES forKey:@"boolTest"];
      [keychainAccess setString:@"test string" forKey:@"stringTest"];
      [keychainAccess setObject:@[@1, @2] forKey:@"objectTest"];
    });

    it(@"deletes all objects stored in the Keychain", ^{
      [keychainAccess deleteAll];

      [[theValue([keychainAccess boolForKey:@"boolTest"]) should] beNo];
      [[keychainAccess stringForKey:@"stringTest"] shouldBeNil];
      [[keychainAccess objectForKey:@"objectTest"] shouldBeNil];
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
    NSData *testData = [@"testData" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = @"dataTest";

    beforeEach(^{
      NSMutableDictionary *query = [NSMutableDictionary dictionary];
      query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

      NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
      query[(__bridge id)kSecAttrAccount] = encodedIdentifier;
      query[(__bridge id)kSecValueData] = testData;

      SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    });

    afterEach(^{
      NSMutableDictionary *query = [NSMutableDictionary dictionary];
      query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

      NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
      query[(__bridge id)kSecAttrAccount] = encodedIdentifier;

      SecItemDelete((__bridge CFDictionaryRef)query);
    });

    it(@"returns the data stored in keychain at the key", ^{
      [[[keychainAccess dataForKey:key] should] equal:testData];
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
  });

  // Setters

  describe(@"registerDefaults:", ^{
    NSDictionary *existingDefaults = @{@"existingKey" : @"existingValue"};
    NSArray *newDefaultKeys = @[@"newKey", @"foo", @"bar"];

    beforeEach(^{
      for (NSString *newKey in newDefaultKeys) {
        [keychainAccess setObject:nil forKey:newKey];
      }

      for (NSString *key in [existingDefaults allKeys]) {
        [[keychainAccess stubAndReturn:existingDefaults[key]] objectForKey:key];
      }
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
    NSData *testData = [@"testData" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = @"dataTest";

    context(@"when the data is nil", ^{
      beforeEach(^{
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

        NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
        query[(__bridge id)kSecAttrAccount] = encodedIdentifier;
        query[(__bridge id)kSecValueData] = testData;

        SecItemAdd((__bridge CFDictionaryRef)query, NULL);
      });

      it(@"deletes the data at the key", ^{
        [keychainAccess setData:nil forKey:key];

        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

        NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
        query[(__bridge id)kSecAttrAccount] = encodedIdentifier;
        query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
        query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;

        CFTypeRef result;
        OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

        [[theValue(error) should] equal:theValue(errSecItemNotFound)];
      });
    });

    context(@"when the data is non-nil", ^{
      it(@"stores the data in the keychain", ^{
        [keychainAccess setData:testData forKey:key];

        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

        NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
        query[(__bridge id)kSecAttrAccount] = encodedIdentifier;
        query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
        query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;

        CFTypeRef result;
        SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
        NSData *resultData = (__bridge NSData *)result;

        [[resultData should] equal:testData];
      });

      afterEach(^{
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

        NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
        query[(__bridge id)kSecAttrAccount] = encodedIdentifier;

        SecItemDelete((__bridge CFDictionaryRef)query);
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
