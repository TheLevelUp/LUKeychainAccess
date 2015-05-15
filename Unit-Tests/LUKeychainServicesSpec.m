@import LUKeychainAccess;
#import "Kiwi.h"

SPEC_BEGIN(LUKeychainServicesSpec)

describe(@"LUKeychainServices", ^{
  __block LUKeychainServices *keychainServices;

  beforeEach(^{
    keychainServices = [LUKeychainServices keychainServices];

    [keychainServices deleteAllItemsWithError:nil];
  });

  NSString *key = @"key1", *anotherKey = @"key2";
  NSData *data = [@"data" dataUsingEncoding:NSUTF8StringEncoding], *anotherData = [@"data2" dataUsingEncoding:NSUTF8StringEncoding];

  describe(@"modifying and retrieving data", ^{
    beforeEach(^{
      [keychainServices addData:data forKey:key error:nil];
    });

    it(@"adds and retrieves data from the Keychain", ^{
      [[[keychainServices dataForKey:key error:nil] should] equal:data];
    });

    it(@"updates data from the keychain", ^{
      [keychainServices updateData:anotherData forKey:key error:nil];

      [[[keychainServices dataForKey:key error:nil] should] equal:anotherData];
    });
  });

  describe(@"deleting items", ^{
    beforeEach(^{
      [keychainServices addData:data forKey:key error:nil];
      [keychainServices addData:anotherData forKey:anotherKey error:nil];
    });

    it(@"deletes items with a given key", ^{
      [keychainServices deleteItemWithKey:key error:nil];

      NSError *error;
      [[[keychainServices dataForKey:key error:&error] should] beNil];
      [[theValue(error.code) should] equal:theValue(errSecItemNotFound)];

      [[[keychainServices dataForKey:anotherKey error:nil] should] equal:anotherData];
    });

    it(@"deletes all items in the keychain", ^{
      [keychainServices deleteAllItemsWithError:nil];

      NSError *error;
      [[[keychainServices dataForKey:key error:&error] should] beNil];
      [[theValue(error.code) should] equal:theValue(errSecItemNotFound)];

      error = nil;
      [[[keychainServices dataForKey:anotherKey error:&error] should] beNil];
      [[theValue(error.code) should] equal:theValue(errSecItemNotFound)];
    });
  });
});

SPEC_END
