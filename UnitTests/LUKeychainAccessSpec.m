#import <LUKeychainAccess/LUKeychainAccess.h>
#import <Kiwi/Kiwi.h>
#import "LUTestErrorHandler.h"
#import "LUTestNonNSCodingCompliantObject.h"
#import "LUTestNSCodingCompliantObject.h"
#import "NSKeyedArchiver+Additions.h"

SPEC_BEGIN(LUKeychainAccessSpec)

describe(@"LUKeychainAccess", ^{
  __block LUKeychainAccess *keychainAccess;
  __block LUKeychainServices *keychainServices;
  __block LUTestErrorHandler *errorHandler;
  NSString *testGroup = @"test_group";
  NSDictionary *testAdditionalParams = @{ @"test":@"test" };

  // Helpers
  id (^errorReturningBlock)(NSArray *) = ^id(NSArray *params) {
    __autoreleasing NSError **error;
    [(NSValue *)[params lastObject] getValue:&error];
    *error = [NSError errorWithDomain:LUKeychainAccessErrorDomain code:errSecDuplicateItem userInfo:nil];

    return [KWValue valueWithBool:NO];
  };

  beforeEach(^{
    errorHandler = [[LUTestErrorHandler alloc] init];

    keychainServices = [LUKeychainServices nullMock];
    [LUKeychainServices stub:@selector(keychainServices) andReturn:keychainServices];

    keychainAccess = [LUKeychainAccess standardKeychainAccess];
    keychainAccess.errorHandler = errorHandler;
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
    it(@"deletes all items from the keychain", ^{
      [[keychainServices should] receive:@selector(deleteAllItemsWithError:)];

      [keychainAccess deleteAll];
    });

    context(@"if the delete fails", ^{
      beforeEach(^{
        [keychainServices stub:@selector(deleteAllItemsWithError:) withBlock:errorReturningBlock];
      });

      it(@"notifies the error handler", ^{
        [keychainAccess deleteAll];

        [[errorHandler.lastError shouldNot] beNil];
      });
    });
  });

  describe(@"deleteObjectForKey:", ^{
    NSString *testKeyToDelete = @"test_key_to_delete";

    it(@"deletes the item with the given key from the keychain", ^{
      [[keychainServices should] receive:@selector(deleteItemWithKey:error:)
                           withArguments:testKeyToDelete, KWAny.any];

      [keychainAccess deleteObjectForKey:testKeyToDelete];
    });

    context(@"if the delete fails", ^{
      beforeEach(^{
        [keychainServices stub:@selector(deleteItemWithKey:error:) withBlock:errorReturningBlock];
      });

      it(@"notifies the error handler", ^{
        [keychainAccess deleteObjectForKey:testKeyToDelete];
      });
    });
  });

  // Getters

  describe(@"accessGroup", ^{
    beforeEach(^{
      [keychainServices stub:@selector(accessGroup) andReturn:testGroup];
    });

    it(@"returns the accessGroup of keychain services", ^{
      [[keychainAccess.accessGroup should] equal:testGroup];
    });
  });

  describe(@"additionalQueryParams", ^{
    beforeEach(^{
      [keychainServices stub:@selector(additionalQueryParams) andReturn:testAdditionalParams];
    });

    it(@"returns the additionalQueryParams of keychain services", ^{
      [[keychainAccess.additionalQueryParams should] equal:testAdditionalParams];
    });
  });

  describe(@"boolForKey:", ^{
    NSString *key = @"boolTest";

    it(@"returns the boolValue of the object stored at the key", ^{
      BOOL testBool = YES;
      [keychainAccess stub:@selector(objectForKey:ofClass:) andReturn:@(testBool) withArguments:key, NSNumber.class];

      [[theValue([keychainAccess boolForKey:key]) should] equal:theValue(testBool)];
    });
  });

  describe(@"dataForKey:", ^{
    NSData *expectedResult = [@"value" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = @"dataTest";

    it(@"returns the data stored in keychain at the key", ^{
      [[keychainServices should] receive:@selector(dataForKey:error:)
                               andReturn:expectedResult
                           withArguments:key, KWAny.any];

      [[[keychainAccess dataForKey:key] should] equal:expectedResult];
    });

    context(@"if the services command fails", ^{
      beforeEach(^{
        [keychainServices stub:@selector(dataForKey:error:) withBlock:^id(NSArray *params) {
          errorReturningBlock(params);
          return nil;
        }];
      });

      it(@"notifies the error handler", ^{
        [keychainAccess dataForKey:key];

        [[errorHandler.lastError shouldNot] beNil];
      });
    });
  });

  describe(@"doubleForKey:", ^{
    NSString *key = @"doubleTest";

    it(@"returns the doubleValue of the object stored at the key", ^{
      double testDouble = 123.0;
      [keychainAccess stub:@selector(objectForKey:ofClass:) andReturn:@(testDouble) withArguments:key, NSNumber.class];

      [[theValue([keychainAccess doubleForKey:key]) should] equal:theValue(testDouble)];
    });
  });

  describe(@"floatForKey:", ^{
    NSString *key = @"floatTest";

    it(@"returns the floatValue of the object stored at the key", ^{
      float testFloat = 123.0;
      [keychainAccess stub:@selector(objectForKey:ofClass:) andReturn:@(testFloat) withArguments:key, NSNumber.class];

      [[theValue([keychainAccess floatForKey:key]) should] equal:theValue(testFloat)];
    });
  });

  describe(@"integerForKey:", ^{
    NSString *key = @"integerTest";

    it(@"returns the integerValue of the object stored at the key", ^{
      NSInteger testInteger = 123;
      [keychainAccess stub:@selector(objectForKey:ofClass:) andReturn:@(testInteger) withArguments:key, NSNumber.class];

      [[theValue([keychainAccess integerForKey:key]) should] equal:theValue(testInteger)];
    });
  });

  describe(@"stringForKey:", ^{
    NSString *key = @"stringTest";

    it(@"returns a UTF-8 encoded string from the data stored at the key", ^{
      NSString *testString = @"testString";
      [keychainAccess stub:@selector(dataForKey:)
                 andReturn:[testString dataUsingEncoding:NSUTF8StringEncoding]
             withArguments:key];

      [[[keychainAccess stringForKey:key] should] equal:testString];
    });
  });

  describe(@"objectForKey:ofClass:", ^{
    NSString *key = @"objectTest";

    it(@"returns the unarchived object from the data stored at the key", ^{
      NSArray *testObject = @[@1, @2];
      [keychainAccess stub:@selector(dataForKey:)
                 andReturn:[NSKeyedArchiver lu_archivedDataWithRootObject:testObject]
             withArguments:key];

      [[[keychainAccess objectForKey:key ofClass:[NSArray class]] should] equal:testObject];
    });

    context(@"when the object is not NSCoding compliant", ^{
      it(@"throws an exception", ^{
        LUTestNonNSCodingCompliantObject *testObject = [[LUTestNonNSCodingCompliantObject alloc] init];
        testObject.testProperty1 = 2;
        testObject.testProperty2 = @"Test";

        [[theBlock(^{
          [keychainAccess setObject:testObject forKey:key];
        }) should] raiseWithName:@"Archiver Error"];
      });
    });

    context(@"when the object is not NSSecureCoding compliant", ^{
      it(@"continues to store the archived data of the object with the key", ^{
        LUTestNSCodingCompliantObject *testObject = [[LUTestNSCodingCompliantObject alloc] init];
        testObject.testProperty1 = 2;
        testObject.testProperty2 = @"Test";

        [[keychainAccess should] receive:@selector(setData:forKey:)
                           withArguments:[NSKeyedArchiver lu_archivedDataWithRootObject:testObject], key];

        [keychainAccess setObject:testObject forKey:key];
      });
    });
  });

  describe(@"recursivelyFindObjectForKey:fromClass:", ^{
    NSString *key = @"objectTest";
    NSArray *testObject = @[@1, @2];

    context(@"when the object has been added", ^{
      it(@"it finds the object recursively", ^{
        [keychainAccess stub:@selector(dataForKey:)
                   andReturn:[NSKeyedArchiver lu_archivedDataWithRootObject:testObject]
               withArguments:key];

        [[[keychainAccess objectForKey:key ofClass:[testObject class]] should] beNil];
        [[[keychainAccess recursivelyFindObjectForKey:key fromClass:[testObject class]] should] equal:testObject];
      });
    });

    context(@"when the object has not been added", ^{
      it(@"returns nil", ^{
        [[[keychainAccess objectForKey:key ofClass:[testObject class]] should] beNil];
        [[[keychainAccess recursivelyFindObjectForKey:key fromClass:[testObject class]] should] beNil];
      });
    });
  });

  // Setters

  describe(@"registerDefaults:", ^{
    beforeEach(^{
      [keychainAccess stub:@selector(objectForKey:ofClass:)];
      [keychainAccess stub:@selector(setString:forKey:)];
      [keychainAccess stub:@selector(setObject:forKey:)];
    });

    it(@"sets strings using setString: instead of setObject:", ^{
      NSString *newValue = @"newValue";
      [[keychainAccess should] receive:@selector(setString:forKey:) withArguments:newValue, @"newKey"];
      [keychainAccess registerDefaults:@{@"newKey": newValue}];
    });

    it(@"sets other data types via setObject:", ^{
      [[keychainAccess should] receive:@selector(setObject:forKey:) withArguments:@1, @"newKey"];
      [keychainAccess registerDefaults:@{@"newKey" : @1}];
    });

    it(@"doesn't overwrite existing values", ^{
      [keychainAccess clearStubs];
      [keychainAccess stub:@selector(objectForKey:ofClass:) andReturn:@"existingValue" withArguments:@"existingKey", NSNumber.class];

      [[keychainAccess shouldNot] receive:@selector(setObject:forKey:) withArguments:@YES, @"existingKey"];
      [keychainAccess registerDefaults:@{@"existingKey" : @YES}];

      [keychainAccess clearStubs];
      [keychainAccess stub:@selector(stringForKey:) andReturn:@"existingValue" withArguments:@"existingKey"];
      [[keychainAccess shouldNot] receive:@selector(setString:forKey:) withArguments:@"newValue", @"existingKey"];

      [keychainAccess registerDefaults:@{@"existingKey" : @"newValue"}];
    });

    it(@"is able to check existing values recursively", ^{
      [LUKeychainServices stub:@selector(keychainServices) andReturn:[LUKeychainServices new]];
      keychainAccess = [LUKeychainAccess standardKeychainAccess];

      [keychainAccess setObject:@NO forKey:@"existingBool"];
      [keychainAccess setObject:@[@"existingValue"] forKey:@"existingArray"];
      [keychainAccess setObject:[NSSet setWithArray:@[@"existingValue"]] forKey:@"existingSet"];
      [keychainAccess setObject:@{@"key":@"existingValue"} forKey:@"existingDic"];
      [keychainAccess setString:@"existingValue" forKey:@"existingString"];

      NSDictionary *dictionary = @{@"existingBool": @YES,
                                   @"newBool": @YES,
                                   @"existingArray": @[@"newValue"],
                                   @"newArray": @[@"newValue"],
                                   @"existingSet": [NSSet setWithArray:@[@"newValue"]],
                                   @"newSet": [NSSet setWithArray:@[@"newValue"]],
                                   @"existingDic": @{@"key": @"newValue"},
                                   @"newDic": @{@"key": @"newValue"},
                                   @"existingString":@"newValue",
                                   @"newString":@"newValue"
      };

      [keychainAccess registerDefaults:dictionary];

      [[theValue([keychainAccess boolForKey:@"existingBool"]) should] beNo];
      [[theValue([keychainAccess boolForKey:@"newBool"]) should] beYes];
      [[[keychainAccess objectForKey:@"existingArray" ofClass:[NSArray class]] should] equal:@[@"existingValue"]];
      [[[keychainAccess objectForKey:@"newArray" ofClass:[NSArray class]] should] equal:@[@"newValue"]];
      [[[keychainAccess objectForKey:@"existingSet" ofClass:[NSSet class]] should]
       equal:[NSSet setWithArray:@[@"existingValue"]]];
      [[[keychainAccess objectForKey:@"newSet" ofClass:[NSSet class]] should]
       equal:[NSSet setWithArray:@[@"newValue"]]];
      [[[keychainAccess objectForKey:@"existingDic" ofClass:[NSDictionary class]] should]
       equal:@{@"key":@"existingValue"}];
      [[[keychainAccess objectForKey:@"newDic" ofClass:[NSDictionary class]] should] equal:@{@"key":@"newValue"}];
      [[[keychainAccess stringForKey:@"existingString"] should] equal:@"existingValue"];
      [[[keychainAccess stringForKey:@"newString"] should] equal:@"newValue"];
    });

    it(@"sets the value for new keys", ^{
      [[keychainAccess should] receive:@selector(setObject:forKey:) withArguments:@YES, @"newKey"];
      [keychainAccess registerDefaults:@{@"newKey" : @YES}];
    });

    it(@"can set multiple keys", ^{
      [[keychainAccess should] receive:@selector(setObject:forKey:) withArguments:@YES, @"foo"];
      [[keychainAccess should] receive:@selector(setObject:forKey:) withArguments:@100, @"bar"];
      [keychainAccess registerDefaults:@{@"foo" : @YES, @"bar" : @100}];
    });
  });

  describe(@"setAccessGroup:", ^{
    it(@"sets the access group on the keychain services", ^{
      [[keychainServices should] receive:@selector(setAccessGroup:) withArguments:testGroup];
      keychainAccess.accessGroup = testGroup;
    });
  });

  describe(@"setAdditionalQueryParams:", ^{
    it(@"sets the additionalQueryParams dictionary on the keychain services", ^{
      [[keychainServices should] receive:@selector(setAdditionalQueryParams:) withArguments:testAdditionalParams];
      keychainAccess.additionalQueryParams = testAdditionalParams;
    });
  });

  describe(@"setBool:forKey:", ^{
    NSString *key = @"boolTest";

    it(@"stores the object version of the value with the key", ^{
      BOOL testBool = NO;
      [[keychainAccess should] receive:@selector(setObject:forKey:) withArguments:@(testBool), key];

      [keychainAccess setBool:testBool forKey:key];
    });
  });

  describe(@"setData:forKey:", ^{
    NSString *key = @"dataTest";

    context(@"when the data is nil", ^{
      it(@"deletes the data at the key", ^{
        [[keychainServices should] receive:@selector(deleteItemWithKey:error:) withArguments:key, KWAny.any];

        [keychainAccess setData:nil forKey:key];
      });
    });

    context(@"when the data is non-nil", ^{
      NSData *testData = [@"testData" dataUsingEncoding:NSUTF8StringEncoding];

      it(@"attempts to add the data to the Keychain", ^{
        [[keychainServices should] receive:@selector(addData:forKey:error:) withArguments:testData, key, KWAny.any];

        [keychainAccess setData:testData forKey:key];
      });

      context(@"when the item already exists in the keychain", ^{
        beforeEach(^{
          [keychainServices stub:@selector(addData:forKey:error:) withBlock:errorReturningBlock];
        });

        it(@"updates the item with the new value", ^{
          [[keychainServices should] receive:@selector(updateData:forKey:error:)
                               withArguments:testData, key, KWAny.any];

          [keychainAccess setData:testData forKey:key];
        });

        context(@"if the services command fails", ^{
          beforeEach(^{
            [keychainServices stub:@selector(updateData:forKey:error:) withBlock:errorReturningBlock];
          });

          it(@"notifies the error handler", ^{
            [keychainAccess setData:testData forKey:key];

            [[errorHandler.lastError shouldNot] beNil];
          });
        });
      });
    });
  });

  describe(@"setDouble:forKey:", ^{
    NSString *key = @"doubleTest";

    it(@"stores the object version of the value with the key", ^{
      double testDouble = 123.0f;
      [[keychainAccess should] receive:@selector(setObject:forKey:) withArguments:@(testDouble), key];

      [keychainAccess setDouble:testDouble forKey:key];
    });
  });

  describe(@"setFloat:forKey:", ^{
    NSString *key = @"floatTest";

    it(@"stores the object version of the value with the key", ^{
      float testFloat = 123.0;
      [[keychainAccess should] receive:@selector(setObject:forKey:) withArguments:@(testFloat), key];

      [keychainAccess setFloat:testFloat forKey:key];
    });
  });

  describe(@"setInteger:forKey:", ^{
    NSString *key = @"integerTest";

    it(@"stores the object version of the value with the key", ^{
      NSInteger testInteger = 123;
      [[keychainAccess should] receive:@selector(setObject:forKey:) withArguments:@(testInteger), key];

      [keychainAccess setInteger:testInteger forKey:key];
    });
  });

  describe(@"setString:forKey:", ^{
    NSString *key = @"stringTest";

    it(@"stores the string encoded as UTF-8 with the key", ^{
      NSString *testString = @"testString";
      [[keychainAccess should] receive:@selector(setData:forKey:)
                         withArguments:[testString dataUsingEncoding:NSUTF8StringEncoding], key];

      [keychainAccess setString:testString forKey:key];
    });
  });

  describe(@"setObject:forKey:", ^{
    NSString *key = @"objectTest";

    it(@"stores the archived data of the object with the key", ^{
      NSArray *testObject = @[@1, @2];
      [[keychainAccess should] receive:@selector(setData:forKey:)
                         withArguments:[NSKeyedArchiver lu_archivedDataWithRootObject:testObject], key];

      [keychainAccess setObject:testObject forKey:key];
    });

    context(@"when the object is not NSCoding compliant", ^{
      it(@"throws an exception", ^{
        LUTestNonNSCodingCompliantObject *testObject = [[LUTestNonNSCodingCompliantObject alloc] init];
        testObject.testProperty1 = 2;
        testObject.testProperty2 = @"Test";

        [[theBlock(^{
          [keychainAccess setObject:testObject forKey:key];
        }) should] raiseWithName:@"Archiver Error"];
      });
    });

    context(@"when the object is not NSSecureCoding compliant", ^{
      it(@"continues to store the archived data of the object with the key", ^{
        LUTestNSCodingCompliantObject *testObject = [[LUTestNSCodingCompliantObject alloc] init];
        testObject.testProperty1 = 2;
        testObject.testProperty2 = @"Test";

        [[keychainAccess should] receive:@selector(setData:forKey:)
                           withArguments:[NSKeyedArchiver lu_archivedDataWithRootObject:testObject], key];

        [keychainAccess setObject:testObject forKey:key];
      });
    });
  });
});

SPEC_END
